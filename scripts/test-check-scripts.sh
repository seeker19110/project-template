#!/usr/bin/env bash
# test-check-scripts.sh — CHỨNG MINH 3 gate của chính bộ khung thật sự BẮT được lỗi, không chỉ
# chạy không crash.
#
# VÌ SAO CẦN (audit toàn diện 2026-09-12, G-001): `check-docs-consistency.sh`, `check-ci-policy.sh`,
# `check-progress-freshness.sh` chưa từng có negative-test tự động — các lượt "NT: ... → rc=1" ghi
# trong `docs/ops/COMPLETION-PLAN.md` đều chạy TAY một lần rồi bỏ, không phải cổng lặp lại được. Một
# sửa tương lai có thể vô tình làm gate mất khả năng phát hiện lỗi mà CI không hề biết (gate
# "xanh giả" — cùng khuôn F-002 mà `test-hooks-gate.sh` đã chốt chặn cho hook, giờ áp cho 3 script này).
#
# Cách làm: dựng bản sao TOÀN BỘ cây file đã track (git archive HEAD) vào thư mục scratch, git init
# lại (lịch sử mới, sạch), rồi mutate từng ca — không đụng gì vào repo thật.
#
# Chạy: bash scripts/test-check-scripts.sh
set -uo pipefail   # cố ý KHÔNG -e: một ca lỗi không được làm chết cả lượt chạy (docs/CONVENTIONS.md §A)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }

# --- Dựng bản sao cây file đã track của repo thật vào một git repo mới, sạch. ---
# Lịch sử mới hoàn toàn khác repo thật (SHA khác) — nên sau khi commit, tự sửa lại dòng
# "Default-branch SHA đã đối chiếu" trong PROGRESS.md trỏ đúng vào chính commit đó (tự tham chiếu,
# luôn là tổ tiên của chính nó), để baseline của check-progress-freshness.sh xanh như thật.
setup_repo() {   # echo ra đường dẫn thư mục scratch
  local dir="$WORK/repo-$RANDOM-$RANDOM"
  mkdir -p "$dir"
  git -C "$ROOT" archive HEAD | (cd "$dir" && tar -x)
  git -C "$dir" init -q
  git -C "$dir" -c user.email=t@t.local -c user.name=test add -A
  git -C "$dir" -c user.email=t@t.local -c user.name=test commit -q -m init
  local head_sha; head_sha="$(git -C "$dir" rev-parse HEAD)"
  sed -i.bak "s/^- Default-branch SHA đã đối chiếu:.*/- Default-branch SHA đã đối chiếu: \`$head_sha\`/" "$dir/PROGRESS.md"
  sed -i.bak2 's/^- Nhánh đang làm:.*/- Nhánh đang làm: `main`/' "$dir/PROGRESS.md"
  rm -f "$dir/PROGRESS.md.bak" "$dir/PROGRESS.md.bak2"
  git -C "$dir" -c user.email=t@t.local -c user.name=test commit -q -am "chuẩn hoá PROGRESS.md cho baseline test"
  printf '%s\n' "$dir"
}

run_check() {   # $1 = thư mục repo, $2 = tên script (đường dẫn tương đối từ scripts/)
  ( cd "$1" && bash "scripts/$2" >/dev/null 2>&1 )
  echo $?
}

## ============================================================
## 1. check-docs-consistency.sh
## ============================================================
echo "== 1. check-docs-consistency.sh =="

d="$(setup_repo)"
rc="$(run_check "$d" check-docs-consistency.sh)"
[ "$rc" = "0" ] && ok "baseline (bản sao sạch) → xanh" || bad "baseline lẽ ra phải xanh (rc=$rc)"

d="$(setup_repo)"
# Ghép chuỗi lúc chạy, KHÔNG để backtick bọc thẳng một đường dẫn có đuôi .md ngay trong SOURCE của
# chính file này — nếu không, mục 1 của check-docs-consistency.sh sẽ tưởng đây là tham chiếu backtick
# thật khi quét scripts/test-check-scripts.sh, gây cổng đỏ OAN trên chính repo thật.
fake_ref="docs/khong-ton-tai-thuc-su"; fake_ref="${fake_ref}.md"
printf '\nTham chiếu hỏng: `%s`\n' "$fake_ref" >> "$d/README.md"
rc="$(run_check "$d" check-docs-consistency.sh)"
[ "$rc" = "1" ] && ok "bắt được link gãy trong backtick (mục 1)" || bad "KHÔNG bắt được link gãy (rc=$rc) — cổng mất tác dụng"

d="$(setup_repo)"
sed -i.bak 's/^name: reviewer$/name: reviewer-sai-ten/' "$d/.claude/agents/reviewer.md" && rm -f "$d/.claude/agents/reviewer.md.bak"
rc="$(run_check "$d" check-docs-consistency.sh)"
[ "$rc" = "1" ] && ok "bắt được frontmatter name lệch tên file (mục 4a)" || bad "KHÔNG bắt được name lệch (rc=$rc)"

d="$(setup_repo)"
printf '\nroute:ghost     → ma-khong-ton-tai\n' >> "$d/docs/framework/orchestration-3-tier.md"
rc="$(run_check "$d" check-docs-consistency.sh)"
[ "$rc" = "1" ] && ok "bắt được route: trỏ agent ảo (mục 4c)" || bad "KHÔNG bắt được route trỏ agent ảo (rc=$rc)"

## ============================================================
## 2. check-ci-policy.sh
## ============================================================
echo "== 2. check-ci-policy.sh =="

d="$(setup_repo)"
rc="$(run_check "$d" check-ci-policy.sh)"
[ "$rc" = "0" ] && ok "baseline (bản sao sạch) → xanh" || bad "baseline lẽ ra phải xanh (rc=$rc)"

d="$(setup_repo)"
# Gỡ pin SHA của action đầu tiên tìm thấy trong ci.yml (CP-2).
perl -0pi -e 's/uses: ([^@\s]+)@[0-9a-f]{40}(\s*#[^\n]*)?/uses: $1\@v4/' "$d/.github/workflows/ci.yml" 2>/dev/null || \
  sed -i.bak -E '0,/uses: [^@]+@[0-9a-f]{40}/s//uses: actions\/checkout@v4/' "$d/.github/workflows/ci.yml"
rm -f "$d/.github/workflows/ci.yml.bak"
rc="$(run_check "$d" check-ci-policy.sh)"
[ "$rc" = "1" ] && ok "bắt được action chưa ghim full SHA (CP-2)" || bad "KHÔNG bắt được action chưa ghim SHA (rc=$rc)"

d="$(setup_repo)"
# ci.yml hiện không còn bước Node nào (ADR-0004 gỡ scaffold) — CP-3 vô hại nếu không có dòng
# node-version: nào để so; thêm 1 dòng giả vào job có thật để thực sự bài test được nhánh này.
printf '\n      - run: echo test\n        with:\n          node-version: "99.99.99"\n' >> "$d/.github/workflows/ci.yml"
rc="$(run_check "$d" check-ci-policy.sh)"
[ "$rc" = "1" ] && ok "bắt được node-version lệch .nvmrc (CP-3)" || bad "KHÔNG bắt được node-version lệch (rc=$rc)"

d="$(setup_repo)"
sed -i.bak 's/needs: \[framework-lint, /needs: [/' "$d/.github/workflows/ci.yml" && rm -f "$d/.github/workflows/ci.yml.bak"
rc="$(run_check "$d" check-ci-policy.sh)"
[ "$rc" = "1" ] && ok "bắt được job thiếu trong needs: của gate (CP-4)" || bad "KHÔNG bắt được job thiếu trong needs (rc=$rc)"

d="$(setup_repo)"
sed -i.bak '/^ci\.yml: framework-lint$/d' "$d/docs/ops/repository-settings.md" && rm -f "$d/docs/ops/repository-settings.md.bak"
rc="$(run_check "$d" check-ci-policy.sh)"
[ "$rc" = "1" ] && ok "bắt được job thật thiếu trong bản kê repository-settings.md (CP-1)" || bad "KHÔNG bắt được job thiếu trong bản kê (rc=$rc)"

## ============================================================
## 3. check-progress-freshness.sh
## ============================================================
echo "== 3. check-progress-freshness.sh =="

d="$(setup_repo)"
rc="$(run_check "$d" check-progress-freshness.sh)"
[ "$rc" = "0" ] && ok "baseline (bản sao sạch) → xanh" || bad "baseline lẽ ra phải xanh (rc=$rc)"

# PF-1: SHA đã đối chiếu KHÔNG phải tổ tiên của HEAD (tồn tại thật, nhưng ở nhánh khác đã rẽ nhánh).
d="$(setup_repo)"
git -C "$d" checkout -qb other-branch
echo "chỉ để tạo commit khác nhánh" >> "$d/README.md"
git -C "$d" -c user.email=t@t.local -c user.name=test commit -qam "commit trên nhánh khác"
other_sha="$(git -C "$d" rev-parse HEAD)"
git -C "$d" checkout -q -
sed -i.bak "s/^- Default-branch SHA đã đối chiếu:.*/- Default-branch SHA đã đối chiếu: \`$other_sha\`/" "$d/PROGRESS.md" && rm -f "$d/PROGRESS.md.bak"
git -C "$d" -c user.email=t@t.local -c user.name=test commit -qam "PROGRESS.md trỏ SHA nhánh khác"
rc="$(run_check "$d" check-progress-freshness.sh)"
[ "$rc" = "1" ] && ok "bắt được SHA không phải tổ tiên của HEAD (PF-1)" || bad "KHÔNG bắt được SHA sai nhánh (rc=$rc)"

# PF-2: "Nhánh đang làm" nêu tên một nhánh KHÔNG còn tồn tại trên remote (đã merge/xoá).
d="$(setup_repo)"
git init -q --bare "$WORK/origin.git"
git -C "$d" remote add origin "$WORK/origin.git"
git -C "$d" push -q origin HEAD:main 2>/dev/null
sed -i.bak 's/^- Nhánh đang làm:.*/- Nhánh đang làm: `nhanh-da-bi-xoa-mat-roi`/' "$d/PROGRESS.md" && rm -f "$d/PROGRESS.md.bak"
git -C "$d" -c user.email=t@t.local -c user.name=test commit -qam "PROGRESS.md trỏ nhánh đã xoá"
rc="$(run_check "$d" check-progress-freshness.sh)"
[ "$rc" = "1" ] && ok "bắt được nhánh 'đang làm' không còn tồn tại trên remote (PF-2)" || bad "KHÔNG bắt được nhánh đã xoá (rc=$rc)"

# Đối chứng: nhánh còn tồn tại trên remote → PHẢI xanh (không chặn oan).
d="$(setup_repo)"
git init -q --bare "$WORK/origin2.git"
git -C "$d" remote add origin "$WORK/origin2.git"
git -C "$d" checkout -qb feature-that-exists
git -C "$d" push -q origin HEAD:feature-that-exists 2>/dev/null
git -C "$d" push -q origin HEAD:main 2>/dev/null
sed -i.bak 's/^- Nhánh đang làm:.*/- Nhánh đang làm: `feature-that-exists`/' "$d/PROGRESS.md" && rm -f "$d/PROGRESS.md.bak"
git -C "$d" -c user.email=t@t.local -c user.name=test commit -qam "PROGRESS.md trỏ nhánh còn tồn tại"
git -C "$d" push -q origin HEAD:feature-that-exists 2>/dev/null
rc="$(run_check "$d" check-progress-freshness.sh)"
[ "$rc" = "0" ] && ok "KHÔNG chặn oan nhánh còn tồn tại trên remote (đối chứng PF-2)" || bad "chặn OAN nhánh còn tồn tại (rc=$rc) — false positive"

## ============================================================
echo ""
if [ "$fails" -eq 0 ]; then
  echo "OK — cả 3 gate (docs-consistency, ci-policy, progress-freshness) đều bắt đúng lỗi + không chặn oan."
else
  echo "❌ $fails ca thất bại — xem chi tiết ở trên."
fi
exit "$fails"
