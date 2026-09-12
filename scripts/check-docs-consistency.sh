#!/usr/bin/env bash
# Kiểm tra tính nhất quán tài liệu của repo khung:
#   1. Đường dẫn file trong backtick (`path/to/file.ext`) phải tồn tại thật — trừ các file
#      được sinh ra sau này tại dự án đích, hoặc do người dùng tự tạo từ `.example.*`.
#   2. Tên file/lệnh cũ (trước lần đổi tên sang tiếng Anh, PR #24) không còn sót lại
#      ngoài bảng ánh xạ (docs/framework/README.md) và nhật ký lịch sử (PROGRESS.md).
# Chạy: bash scripts/check-docs-consistency.sh
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail=0

# Các file này CỐ Ý chứa tên cũ/đường dẫn chưa-tồn-tại trong repo này: PROGRESS.md ghi lại
# lịch sử (tên gọi đúng lúc viết), docs/framework/README.md là bảng ánh xạ tên cũ → tên mới,
# case-study-*.md tường thuật đường dẫn của một dự án demo tạm thời (không phải repo này).
EXCLUDE_SOURCE=("PROGRESS.md" "docs/framework/README.md" "docs/framework/case-study-greenfield-dry-run.md")

# Thư mục nguồn được miễn trừ theo TIỀN TỐ. `docs/specs/` là contract HƯỚNG TỚI TƯƠNG LAI: một
# feature spec mô tả file nó sẽ tạo khi được thực thi, nên tham chiếu tới file chưa tồn tại là
# BẢN CHẤT của nó, không phải lỗi. Nếu không miễn trừ, mọi spec mới đều làm cổng này đỏ và áp lực
# sẽ là viết spec mờ đi (bỏ backtick) — tức cổng làm hỏng đúng thứ nó bảo vệ.
EXCLUDE_SOURCE_PREFIX=("docs/specs/")

# Đường dẫn được nhắc tới trong docs nhưng KHÔNG đóng gói sẵn trong repo khung này:
# sinh ra tại dự án đích (`/completion`, `/audit-full`), hoặc người dùng tự tạo từ
# `.example.*`, hoặc là file chuẩn của scaffold Next.js sau khi `create-next-app`.
ALLOW_MISSING_PATH=(
  "docs/CONVENTIONS.md" "docs/FEATURE-MAP.md"
  "docs/ops/COMPLETION-PLAN.md" "docs/ops/COMPREHENSIVE-AUDIT-STATUS.md"
  "app/layout.tsx" "lib/example.test.ts"
  ".claude/project-commands.sh" ".claude/settings-sonnet.json" ".claude/usage-budget.sh"
)

is_in() { local needle="$1"; shift; for x in "$@"; do [ "$x" = "$needle" ] && return 0; done; return 1; }

grep_files() {
  git grep -l "$@" -- '*.md' '*.sh' '*.ps1' 2>/dev/null || true
}

echo "== 1. Đường dẫn file tham chiếu trong backtick =="
mapfile -t refs < <(
  git grep -hoE '`[A-Za-z0-9_./-]+\.(md|sh|ps1|json|ts|tsx|yml|cjs|mjs)`' \
    -- '*.md' '*.sh' '*.ps1' 2>/dev/null \
  | tr -d '`' | sort -u
)
for ref in "${refs[@]}"; do
  [[ "$ref" == */* ]] || continue
  [[ -e "$ref" ]] && continue
  is_in "$ref" "${ALLOW_MISSING_PATH[@]}" && continue
  # Chỉ báo lỗi nếu tham chiếu này KHÔNG xuất phát duy nhất từ file được miễn trừ.
  refFiles=$(grep_files -F -- "\`$ref\`")
  onlyExcluded=1
  for f in $refFiles; do
    f="${f#./}"
    if is_in "$f" "${EXCLUDE_SOURCE[@]}"; then continue; fi
    excludedByPrefix=0
    for pre in "${EXCLUDE_SOURCE_PREFIX[@]}"; do
      case "$f" in "$pre"*) excludedByPrefix=1 ;; esac
    done
    [ "$excludedByPrefix" -eq 1 ] || onlyExcluded=0
  done
  if [ "$onlyExcluded" -eq 0 ] || [ -z "$refFiles" ]; then
    echo "::error::Tham chiếu file không tồn tại: $ref (trong: $refFiles)"
    fail=1
  fi
done

echo "== 2. Tên file/lệnh cũ còn sót (ngoài bảng ánh xạ + nhật ký) =="
OLD_NAMES=(
  "KHUNG-1.md" "KHUNG-2.md" "KHUNG-3.md"
  "KHOI-TAO-du-an-moi.md" "AP-DUNG-vao-du-an-co-san.md" "BO-SUNG-chat-luong.md" "MODEL-va-TU-DONG.md"
  "audit-toan-dien-prompt.md" "audit-toi-uu-prompt.md"
  "thuc-thi.md" "tra-cuu.md" "kiem-tra-phien-ban.md"
  "HUONG-DAN"
)
for name in "${OLD_NAMES[@]}"; do
  hits=$(grep_files -F -- "$name")
  for f in $hits; do
    f="${f#./}"
    is_in "$f" "${EXCLUDE_SOURCE[@]}" "scripts/check-docs-consistency.sh" && continue
    echo "::error::Tên cũ \"$name\" còn sót ngoài bảng ánh xạ/nhật ký: $f"
    fail=1
  done
done

echo "== 3. Lệnh (.claude/commands) ↔ CLAUDE.md khớp hai chiều =="
# CLAUDE.md bị ép ngắn (< 200 dòng) trong khi số lệnh cứ tăng → rất dễ lệch:
# thêm lệnh mà quên khai TRIGGER, hoặc xóa/đổi tên lệnh mà CLAUDE.md vẫn trỏ tới.
# Kiểm cả hai chiều để máy bắt thay vì rà tay.

# Chiều A: mỗi file lệnh phải được CLAUDE.md nhắc tới (qua đường dẫn hoặc `/tên`).
for cmd in .claude/commands/*.md; do
  [ -e "$cmd" ] || continue
  name="$(basename "$cmd" .md)"
  if ! grep -qF -e "\`$cmd\`" -e "\`/$name\`" CLAUDE.md; then
    echo "::error::Lệnh $cmd chưa được CLAUDE.md khai (thiếu \`$cmd\` hoặc \`/$name\`)"
    fail=1
  fi
done

# Chiều B: mỗi `/tên` CLAUDE.md nhắc tới phải có file lệnh thật.
# Miễn trừ: skill dựng sẵn của Claude Code, không nằm trong .claude/commands/ của repo.
BUILTIN_COMMANDS=("code-review" "security-review" "simplify" "loop")
mapfile -t slashRefs < <(
  grep -hoE '`/[a-z][a-z0-9-]*`' CLAUDE.md | tr -d '`/' | sort -u
)
for name in "${slashRefs[@]}"; do
  is_in "$name" "${BUILTIN_COMMANDS[@]}" && continue
  [ -f ".claude/commands/$name.md" ] && continue
  echo "::error::CLAUDE.md nhắc \`/$name\` nhưng không có .claude/commands/$name.md"
  fail=1
done

if [ "$fail" -eq 0 ]; then
  echo "OK — không phát hiện link gãy, tên cũ sót lại, hay lệnh lệch với CLAUDE.md."
fi
exit "$fail"
