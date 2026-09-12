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

# --- 4. MỌI `uses:` phải ghim full commit SHA (docs/ops/supply-chain.md dòng 10). ---
# VÌ SAO (audit 2026-09-12, F-003): `actions/cache@v4` là action DUY NHẤT còn dùng tag di động
# giữa 13 action — lệch quy ước, và tag di động nghĩa là mã chạy trong CI có thể đổi dưới chân ta
# mà không có PR nào. Trước kiểm này không gì bắt được chuyện đó; dependabot chỉ nâng cái đã ghim.
echo "== Action chưa ghim full commit SHA =="
while IFS= read -r line; do
  file="${line%%:*}"; rest="${line#*:}"; lineno="${rest%%:*}"
  ref="$(printf '%s' "$line" | sed -E 's/.*uses:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//')"
  # Bỏ qua action local (./.github/...) và docker://
  case "$ref" in ./*|docker://*) continue ;; esac
  if ! printf '%s' "$ref" | grep -Eq '@[0-9a-f]{40}$'; then
    echo "::error file=$file,line=$lineno::Action '$ref' chưa ghim full commit SHA — vi phạm docs/ops/supply-chain.md. Sửa: uses: <action>@<sha40> # <tag>"
    fail=1
  fi
done < <(grep -rn "uses:" .github/workflows/*.yml | grep -v "#.*uses:")

# --- 5. `node-version:` trong workflow phải khớp .nvmrc (ADR-0002). ---
# VÌ SAO (audit 2026-09-12, F-011): phiên bản Node bị hardcode ở 5 chỗ trong workflow + .nvmrc;
# nâng một chỗ quên chỗ kia thì CI test bằng Node khác với Node dev — lệch IM LẶNG.
echo "== node-version trong workflow khớp .nvmrc =="
if [ -f .nvmrc ]; then
  nvmrc="$(tr -d ' \n\r' < .nvmrc)"
  while IFS= read -r line; do
    file="${line%%:*}"; rest="${line#*:}"; lineno="${rest%%:*}"
    val="$(printf '%s' "$line" | sed -E 's/.*node-version:[[:space:]]*//; s/[[:space:]]*$//' | tr -d "'\"")"
    case "$val" in \$\{\{*) continue ;; esac   # biểu thức matrix → bỏ qua
    if [ "$val" != "$nvmrc" ]; then
      echo "::error file=$file,line=$lineno::node-version '$val' lệch .nvmrc ('$nvmrc') — đồng bộ cả hai (ADR-0002)."
      fail=1
    fi
  done < <(grep -rn "node-version:" .github/workflows/*.yml)
else
  echo "::error::.nvmrc không tồn tại — ADR-0002 yêu cầu ghim phiên bản Node của khung."
  fail=1
fi

# --- 6. Mọi job cổng của ci.yml phải có mặt trong `needs:` của job tổng hợp `gate` (ADR-0003). ---
# VÌ SAO: `gate` chỉ mạnh bằng danh sách needs: của nó. Thêm job cổng mới mà quên đưa vào needs
# thì job đó chạy nhưng đỏ KHÔNG chặn merge (branch protection chỉ khoá `gate`) — cổng hình thức.
echo "== Job của ci.yml có trong needs: của gate =="
if grep -q "^  gate:" .github/workflows/ci.yml; then
  needs_line="$(grep -A3 "^  gate:" .github/workflows/ci.yml | grep -m1 "needs:")"
  for job in "${!actual_jobs[@]}"; do
    case "$job" in ci.yml:*) ;; *) continue ;; esac
    jid="${job#ci.yml:}"
    [ "$jid" = "gate" ] && continue
    if ! printf '%s' "$needs_line" | grep -q "\b$jid\b"; then
      echo "::error file=.github/workflows/ci.yml::Job '$jid' KHÔNG có trong needs: của job 'gate' — đỏ sẽ không chặn merge (ADR-0003)."
      fail=1
    fi
  done
else
  echo "::error file=.github/workflows/ci.yml::Thiếu job tổng hợp 'gate' — ADR-0003 yêu cầu có (required check duy nhất)."
  fail=1
fi


if [ "$fail" -eq 0 ]; then
  echo "OK — job id khớp $SETTINGS_FILE; action đã ghim SHA; node-version khớp .nvmrc; gate needs đủ job."
fi

exit "$fail"
