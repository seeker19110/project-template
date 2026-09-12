#!/usr/bin/env bash
# Đối chiếu HAI CHIỀU giữa job id thật trong ci.yml/pr-policy.yml và danh sách "required checks —
# nguồn sự thật" trong docs/ops/repository-settings.md.
#
# VÌ SAO CẦN (docs/specs/2026-09-12-traps-codemap-ci-policy.md, lỗ hổng C): ci.yml có nhiều job
# PHẲNG, không `needs:` — không có job tổng hợp để gom, nên branch protection trên GitHub phải
# liệt kê ĐÚNG TÊN từng job. Trước script này, danh sách required checks KHÔNG tồn tại ở đâu trong
# repo — nên đổi tên/xoá một job id sẽ làm required check cũ không bao giờ báo cáo nữa (PR kẹt
# vĩnh viễn, không PR nào hiện đỏ để lần ra nguyên nhân), hoặc thêm job cổng mới mà quên khai báo
# (cổng chạy nhưng đỏ vẫn merge được). Cả hai hỏng theo kiểu IM LẶNG.
#
# CỐ Ý chỉ kiểm CẤU TRÚC (job id có khớp danh sách không), KHÔNG kiểm nội dung từng bước bên trong
# job — ép nội dung sẽ biến script thành vật cản mỗi lần thêm một bước kiểm mới (cùng nguyên tắc
# donghanh/scripts/ci-workflow-policy.test.ts).
#
# Đây là biến thể SHELL cho chính repo khung (không có package.json → không chạy được vitest).
# Dự án đích dùng bản vitest tương đương trong dropins: scripts/ci-workflow-policy.test.ts.
# Hai bản KHÔNG được gộp — xem CODEMAP.md khi có.
#
# Chạy: bash scripts/check-ci-policy.sh
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SETTINGS_FILE="docs/ops/repository-settings.md"
WORKFLOWS=("ci.yml" "pr-policy.yml")

fail=0

# --- 1. Trích job id THẬT từ mỗi workflow (top-level key ngay dưới `jobs:`, thụt lề 2 khoảng). ---
declare -A actual_jobs=() # key "wf:job" -> 1

for wf in "${WORKFLOWS[@]}"; do
  f=".github/workflows/$wf"
  if [ ! -f "$f" ]; then
    echo "::error::Không tìm thấy workflow $f (khai trong WORKFLOWS của script này)"
    fail=1
    continue
  fi
  in_jobs=0
  while IFS= read -r line; do
    if [[ "$line" == "jobs:" ]]; then
      in_jobs=1
      continue
    fi
    if [ "$in_jobs" -eq 1 ]; then
      # Job id: đúng 2 khoảng trắng thụt lề rồi "<id>:" (không phải khoá con của một job).
      if [[ "$line" =~ ^\ \ ([A-Za-z0-9_-]+):[[:space:]]*$ ]] || [[ "$line" =~ ^\ \ ([A-Za-z0-9_-]+):[[:space:]]+[^\ ] ]]; then
        actual_jobs["$wf:${BASH_REMATCH[1]}"]=1
      elif [[ "$line" =~ ^[A-Za-z] ]]; then
        # Về lại cột 0 (khoá cấp cao khác của workflow) → hết khối jobs.
        in_jobs=0
      fi
    fi
  done < "$f"
done

# --- 2. Trích danh sách khai báo từ khối fenced code block "```" đầu tiên trong repository-settings.md. ---
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "::error::Không tìm thấy $SETTINGS_FILE"
  exit 1
fi

declare -A declared_jobs=() # key "wf:job" -> 1
in_block=0
while IFS= read -r line; do
  if [[ "$line" == '```' ]]; then
    if [ "$in_block" -eq 0 ]; then in_block=1; continue; else break; fi
  fi
  if [ "$in_block" -eq 1 ]; then
    if [[ "$line" =~ ^([a-zA-Z0-9_.-]+\.yml):[[:space:]]*([A-Za-z0-9_-]+)[[:space:]]*$ ]]; then
      declared_jobs["${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"]=1
    fi
  fi
done < "$SETTINGS_FILE"

if [ "${#declared_jobs[@]}" -eq 0 ]; then
  echo "::error::Không đọc được mục nào trong khối 'Required checks — nguồn sự thật' của $SETTINGS_FILE"
  exit 1
fi

# --- 3. Đối chiếu hai chiều. ---
echo "== Job thật trong workflow nhưng THIẾU trong $SETTINGS_FILE =="
for key in "${!actual_jobs[@]}"; do
  if [ -z "${declared_jobs[$key]+x}" ]; then
    echo "::error::Job '$key' có trong workflow nhưng chưa khai trong $SETTINGS_FILE — thêm dòng '${key/:/: }' vào khối required checks, hoặc xác nhận job này cố ý không phải required check."
    fail=1
  fi
done

echo "== Job khai trong $SETTINGS_FILE nhưng KHÔNG còn tồn tại trong workflow =="
for key in "${!declared_jobs[@]}"; do
  if [ -z "${actual_jobs[$key]+x}" ]; then
    echo "::error::Job '$key' được khai trong $SETTINGS_FILE nhưng không còn tồn tại trong workflow — job đã đổi tên/xoá mà quên cập nhật danh sách (branch protection đang canh một tên đã chết)."
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK — job id trong ci.yml/pr-policy.yml khớp hai chiều với $SETTINGS_FILE."
fi

exit "$fail"
