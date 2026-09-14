#!/usr/bin/env bash
# maintain-cron.sh — Wrapper KHÔNG GIÁM SÁT (VPS/cron/systemd timer) cho `maintain-run.sh`.
#
# Vì sao tồn tại: `maintain-run.sh` chỉ ghi vào 3 file cục bộ (docs/ops/MAINTENANCE-*.md) và
# in ra stdout — không ai đọc được nếu chạy trên một VPS không ai mở máy. Wrapper này thêm ĐÚNG
# MỘT việc mới: đồng bộ với remote rồi ĐẨY kế hoạch/báo cáo lên một NHÁNH RIÊNG để bạn duyệt qua
# PR như bình thường — không đụng `main`, không tự merge, không tự sửa source code (CLAUDE.md §9:
# thao tác ghi không giám sát phải có hàng rào cứng, không chỉ lời hứa trong prompt).
#
# HÀNG RÀO CỨNG (không phải tùy chọn, không có cờ nào tắt được):
#   1) KHÔNG BAO GIỜ commit/push thẳng vào nhánh mặc định (main/master) — luôn qua nhánh riêng
#      `maint/auto-<ngày>` (mỗi ngày một nhánh mới, không ghi đè lịch sử nhánh cũ).
#   2) KHÔNG BAO GIỜ `git push --force`/`-f`. KHÔNG `git reset --hard`/`git clean -f*` khi có
#      thay đổi khác đang dở (kiểm working tree TRƯỚC khi chạy, dừng nếu bẩn).
#   3) CHỈ `git add` đúng 3 file docs/ops/MAINTENANCE-*.md — không `git add -A`/`git add .`, để
#      một thay đổi bất thường khác trên VPS không lỡ bị cuốn theo commit tự động.
#   4) Khoá tiến trình (flock nếu có, else file khoá + PID) — hai lần cron chồng nhau (job trước
#      chạy lâu hơn interval) không được chạy song song trên cùng một checkout.
#   5) Không bao giờ echo/log nội dung file bí mật; không truyền gì qua `eval`.
#
# Dùng (crontab ví dụ — 07:00 thứ Hai, sau workflow GitHub 06:47 UTC ở §maintenance.yml):
#   0 7 * * 1  cd /path/to/repo && scripts/maintain-cron.sh >> /var/log/maintain-cron.log 2>&1
#
# Cờ: --harness/--model/--provider/--mode chuyển thẳng cho maintain-run.sh (xem --help ở đó).
#     --base <nhánh>   nhánh nền để đồng bộ + rẽ nhánh maint/auto-* (mặc định: tự dò origin/HEAD)
#     --no-push        chạy trọn vẹn (pull + sweep + agent) nhưng KHÔNG commit/push — để test tay
#     --lock-dir <dir> nơi đặt file khoá (mặc định: thư mục tạm hệ thống, NGOÀI working tree)
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BASE=""; NO_PUSH=0; LOCK_DIR=""
PASS_ARGS=()

log() { printf '[maintain-cron] %s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2; }
die() { log "LỖI: $*"; exit "${2:-1}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --base)     BASE="${2:-}"; shift 2 ;;
    --no-push)  NO_PUSH=1; shift ;;
    --lock-dir) LOCK_DIR="${2:-}"; shift 2 ;;
    -h|--help)  sed -n '2,29p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --harness|--model|--provider|--mode) PASS_ARGS+=("$1" "${2:-}"); shift 2 ;;
    *) die "tham số lạ: $1 (xem --help)" 2 ;;
  esac
done

cd "$ROOT" || die "không cd được vào $ROOT" 2
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "không phải git repo: $ROOT" 2
for need in scripts/maintain-run.sh scripts/maintenance-sweep.sh; do
  [ -f "$need" ] || die "thiếu $need — repo chưa có agent bảo trì (chạy copy-framework.sh)" 3
done

# ── (0) Khoá tiến trình — không chạy chồng lên chính nó ─────────────────────
# Mặc định đặt NGOÀI working tree (thư mục tạm hệ thống, khoá theo đường dẫn repo) — cố ý không
# mặc định vào $ROOT/.claude: một file khoá lọt vào git status sẽ tự làm hỏng bước (1) "working
# tree phải sạch" ở NGAY LƯỢT CHẠY KẾ TIẾP, dù đã có dòng .gitignore. Không phụ thuộc quy ước
# .gitignore của mỗi checkout — an toàn cả khi ai đó quên thêm dòng đó vào .gitignore của họ.
if [ -z "${LOCK_DIR:-}" ]; then
  repo_hash="$(printf '%s' "$ROOT" | cksum | cut -d' ' -f1)"
  LOCK_DIR="${TMPDIR:-/tmp}/maintain-cron.$repo_hash"
fi
mkdir -p "$LOCK_DIR" 2>/dev/null || true
LOCK_FILE="$LOCK_DIR/.maintain-cron.lock"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$LOCK_FILE"
  flock -n 9 || die "một lượt maintain-cron khác đang chạy (khoá: $LOCK_FILE)" 4
else
  # Fallback không có flock (vd macOS mặc định): file khoá + kiểm PID còn sống không.
  if [ -f "$LOCK_FILE" ]; then
    old_pid="$(cat "$LOCK_FILE" 2>/dev/null || true)"
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      die "một lượt maintain-cron khác đang chạy (PID $old_pid, khoá: $LOCK_FILE)" 4
    fi
    log "khoá cũ trỏ tới PID đã chết ($old_pid) — dọn và tiếp tục."
  fi
  echo $$ > "$LOCK_FILE"
  trap 'rm -f "$LOCK_FILE"' EXIT
fi

# ── (1) Tiền kiểm — working tree PHẢI sạch trước khi đụng vào git ───────────
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  die "working tree BẨN (thay đổi chưa commit) — không tự ý stash/reset trên VPS không giám sát. Dọn tay rồi chạy lại." 5
fi

[ -n "$BASE" ] || BASE="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
[ -n "$BASE" ] || BASE=main
log "nhánh nền: $BASE"

git fetch origin "$BASE" --quiet || die "git fetch origin $BASE thất bại (mạng/quyền?)" 6
git checkout -q "$BASE" 2>/dev/null || git checkout -q -B "$BASE" "origin/$BASE" || die "không checkout được $BASE" 6
git reset -q --hard "origin/$BASE" || die "không đồng bộ được với origin/$BASE" 6   # an toàn: base vừa fetch, không phải nhánh có việc dở
log "đã đồng bộ $BASE = origin/$BASE ($(git rev-parse --short HEAD))"

WORK_BRANCH="maint/auto-$(date -u +%Y-%m-%d)"
if git show-ref -q --verify "refs/heads/$WORK_BRANCH"; then
  git checkout -q "$WORK_BRANCH"
  git reset -q --hard "$BASE"   # nhánh cùng ngày chạy lại lần 2 → làm lại từ base mới nhất, không cộng dồn
else
  git checkout -q -b "$WORK_BRANCH" "$BASE"
fi
log "nhánh làm việc: $WORK_BRANCH"

# ── (2) Chạy agent (quét + triage qua CLI subscription cục bộ) ──────────────
run_rc=0
bash scripts/maintain-run.sh "${PASS_ARGS[@]}" || run_rc=$?
[ "$run_rc" -eq 0 ] || log "maintain-run.sh thoát $run_rc (không phải lỗi chặn — có thể agent chỉ báo 🔴>0, hoặc CLI lỗi; xem log phía trên)"

# ── (3) Commit + push CHỈ 3 file MAINTENANCE-*.md, CHỈ vào nhánh riêng ──────
FILES=(docs/ops/MAINTENANCE-PLAN.md docs/ops/MAINTENANCE-LOG.md docs/ops/MAINTENANCE-REPORT.md)
present=()
for f in "${FILES[@]}"; do [ -f "$f" ] && present+=("$f"); done
if [ "${#present[@]}" -eq 0 ]; then
  log "agent không ghi file MAINTENANCE-* nào — không có gì để commit."
  git checkout -q "$BASE"; exit "$run_rc"
fi
git add -- "${present[@]}"
if git diff --cached --quiet; then
  log "không có thay đổi thật trong ${present[*]} — không commit."
  git checkout -q "$BASE"; exit "$run_rc"
fi

git -c user.name="maintain-cron" -c user.email="maintain-cron@localhost" \
  commit -q -m "chore(maintenance): quét bảo trì tự động $(date -u +%Y-%m-%d)

Sinh bởi scripts/maintain-cron.sh (không giám sát). KHÔNG tự merge — mở PR
để người duyệt docs/ops/MAINTENANCE-PLAN.md trước khi bất kỳ mục nào được
thực thi (CLAUDE.md §2 Feature gate)." \
  || die "git commit thất bại" 7

if [ "$NO_PUSH" -eq 1 ]; then
  log "--no-push: đã commit vào $WORK_BRANCH cục bộ, KHÔNG đẩy lên remote."
  exit "$run_rc"
fi

if ! git push -u origin "$WORK_BRANCH" --quiet; then
  log "push thất bại lần 1 — thử lại sau 5s (mạng chập chờn)"
  sleep 5
  git push -u origin "$WORK_BRANCH" --quiet || die "push thất bại sau khi thử lại — nhánh $WORK_BRANCH vẫn nằm cục bộ, không mất dữ liệu" 8
fi
log "đã đẩy $WORK_BRANCH lên origin. Mở PR để duyệt docs/ops/MAINTENANCE-PLAN.md rồi mới chạy tiếp các mục qua /gate."
git checkout -q "$BASE"
exit "$run_rc"
