#!/usr/bin/env bash
# test-maintenance-sweep.sh — Self-test cho engine quét bảo trì (scripts/maintenance-sweep.sh).
#
# Nguyên tắc F-002 / TRAPS.md mục 11: engine phải được CHỨNG MINH bắt đúng lỗi bằng negative-test
# trên một repo dựng tạm có lỗi cài sẵn, không chỉ "chạy không crash". Chạy trong job CI
# `framework-lint` VÀ được copy sang dự án đích để smoke (test-copy-framework.sh).
#
# Chạy: bash scripts/test-maintenance-sweep.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SWEEP="$ROOT/scripts/maintenance-sweep.sh"
fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
GIT=(git -c user.name=t -c user.email=t@example.com -c commit.gpgsign=false)

echo "== 1. --help thoát 0 và có hướng dẫn =="
if bash "$SWEEP" --help 2>&1 | grep -q -- '--strict'; then ok "--help in ra tuỳ chọn"; else bad "--help không in tuỳ chọn"; fi

echo "== 2. Quét chính repo này (--no-deps) — đủ 6 mảng + bảng tổng hợp, không crash =="
out="$(bash "$SWEEP" --no-deps 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || [ "$rc" -eq 1 ] && ok "thoát $rc (0 = không 🔴; 1 chỉ khi --strict)" || bad "thoát mã lạ $rc"
[ "$rc" -eq 0 ] || bad "không dùng --strict mà vẫn thoát khác 0"
for s in "## Tổng hợp phát hiện" "## 1. Git" "## 2. Dependency" "## 3. Tài liệu" "## 4. Vệ sinh" "## 5. CI" "## 6. Cổng"; do
  if printf '%s' "$out" | grep -q "$s"; then ok "có mục '$s'"; else bad "thiếu mục '$s'"; fi
done

echo "== 3. NEGATIVE: repo tạm có lỗi cài sẵn phải bị bắt đúng mức =="
bad_repo="$TMP/bad"; mkdir -p "$bad_repo/.github/workflows" "$bad_repo/.claude"
# Khoá giả DỰNG LÚC CHẠY (không viết literal vào file test — kẻo chính test này bị sweep bắt).
fake_aws="AKIA$(printf 'Q%.0s' $(seq 16))"
fake_pem="-----BEGIN ""RSA PRIVATE KEY-----"
(
  cd "$bad_repo" && "${GIT[@]}" init -q -b main
  printf 'DB_URL=x\nAWS_KEY=%s\n' "$fake_aws" > .env
  printf '%s\nabc\n' "$fake_pem" > key.pem
  printf 'name: x\non: push\njobs:\n  a:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n' > .github/workflows/ci.yml
  printf '# PROGRESS\n- Ngày cập nhật: 2020-01-01\n' > PROGRESS.md
  # Khai báo lệnh dependency: outdated xanh có dấu vết, audit ĐỎ giả lập
  printf 'deps_outdated="echo OUTDATED-DECL-MARK"\ndeps_audit="echo VULN-FOUND; exit 3"\n' > .claude/project-commands.sh
  "${GIT[@]}" add -A && "${GIT[@]}" commit -qm init
)
bout="$(CLAUDE_PROJECT_DIR="$bad_repo" bash "$SWEEP" --strict --out "$TMP/bad-report.md" 2>&1)"; brc=$?
[ "$brc" -eq 1 ] && ok "--strict thoát 1 khi có 🔴" || bad "--strict thoát $brc (mong 1). Output: $bout"
[ -s "$TMP/bad-report.md" ] && ok "--out ghi được báo cáo" || bad "--out không ghi file"
rep="$(cat "$TMP/bad-report.md" 2>/dev/null)"
chk() { if printf '%s' "$rep" | grep -q -- "$2"; then ok "$1"; else bad "$1 — không thấy '$2'"; fi; }
chk "🔴 .env trong git"                    "🔴 | Bí mật | file .env"
chk "🔴 chuỗi giống bí mật (AWS/PEM)"     "🔴 | Bí mật | .* dòng giống khoá"
chk "🟡 action chưa ghim SHA"             "🟡 | CI | 1 action chưa ghim"
chk "🟡 PROGRESS.md lỗi thời"             "🟡 | Tài liệu | PROGRESS.md lỗi thời"
chk "🟡 thiếu dependabot.yml"             "🟡 | CI | thiếu .github/dependabot.yml"
chk "lệnh deps KHAI BÁO được ưu tiên"     "OUTDATED-DECL-MARK"
chk "🔴 audit khai báo đỏ → 🔴"           "🔴 | Dependency | audit báo lỗ hổng (exit 3)"
chk "cổng khung vắng → n-a, không crash"  "docs-consistency: n-a"

echo "== 4. POSITIVE: repo tạm sạch → 0 🔴, --strict thoát 0 =="
good_repo="$TMP/good"; mkdir -p "$good_repo/.github"
(
  cd "$good_repo" && "${GIT[@]}" init -q -b main
  printf '# PROGRESS\n- Ngày cập nhật: %s\n' "$(date +%Y-%m-%d)" > PROGRESS.md
  printf 'version: 2\nupdates: []\n' > .github/dependabot.yml
  printf 'DB_URL=example\n' > .env.example
  "${GIT[@]}" add -A && "${GIT[@]}" commit -qm init
)
gout="$(CLAUDE_PROJECT_DIR="$good_repo" bash "$SWEEP" --strict --no-deps 2>&1)"; grc=$?
[ "$grc" -eq 0 ] && ok "repo sạch: --strict thoát 0" || bad "repo sạch mà --strict thoát $grc: $gout"
printf '%s' "$gout" | grep -q '🔴 0' && ok "báo cáo ghi 🔴 0" || bad "báo cáo không ghi 🔴 0"
printf '%s' "$gout" | grep -q 'Bí mật | file .env' && bad ".env.example bị báo oan là .env" || ok ".env.example không bị báo oan"

echo "== 5. Tham số lạ → thoát 2 =="
bash "$SWEEP" --bogus >/dev/null 2>&1; [ $? -eq 2 ] && ok "thoát 2" || bad "tham số lạ không thoát 2"

echo
if [ "$fails" -eq 0 ]; then echo "OK — maintenance-sweep.sh đo đúng, bắt đúng lỗi cài sẵn, không báo oan repo sạch."; else echo "FAIL — $fails kiểm hỏng."; fi
exit "$fails"
