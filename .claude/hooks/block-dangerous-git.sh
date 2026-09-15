#!/usr/bin/env bash
# block-dangerous-git.sh — PreToolUse hook (matcher: Bash).
#
# VÌ SAO CẦN (audit 2026-09-12, F-004): CLAUDE.md §8 CẤM một số thao tác git, nhưng trước hook này
# lệnh cấm chỉ tồn tại dưới dạng LUẬT — không có cơ chế nào thi hành. Luật không có hàng rào thì
# sẽ bị vi phạm ở phiên dài (bằng chứng thật: luật FIFO §8 bị vi phạm 19 ngày, F-001).
#
# Chặn 4 khuôn (exit 2 = chặn, thông báo về lại Claude):
#   1. force-push vào nhánh chính (`--force`/`-f`/`--force-with-lease` + main/master)
#   2. `reset --hard` (mất thay đổi chưa commit, không hoàn tác được)
#   3. `merge --abort` / `rebase --abort` (né việc giải xung đột — CLAUDE.md §8 cấm tường minh)
#   4. `push --force` lên nhánh KHÔNG phải của mình → chỉ cảnh báo (không chặn), vì rebase nhánh
#      riêng là hợp lệ theo quy ước repo.
#
# Bỏ qua có chủ đích: đặt ALLOW_DANGEROUS_GIT=1 trong môi trường (tường minh, có chủ ý).
set -uo pipefail   # cố ý KHÔNG -e: không được làm chết phiên (xem docs/CONVENTIONS.md §A)

[ "${ALLOW_DANGEROUS_GIT:-0}" = "1" ] && exit 0

payload="$(cat)"
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  # Không có jq → KHÔNG đoán lệnh từ JSON thô (sẽ khớp nhầm nội dung file/mô tả và chặn oan).
  # Fail-open nhưng NÓI RA (thống nhất pre-commit-gate.sh / auto-format.sh).
  echo "[block-dangerous-git] không có jq → không đọc được lệnh, bỏ qua kiểm tra." >&2
  exit 0
fi
[ -n "$cmd" ] || exit 0

# Bỏ DỮ LIỆU trước khi so khớp, chỉ giữ phần thực sự là lệnh. Hai dạng nhúng dữ liệu nhiều từ vào
# một lệnh shell, và cả hai đều đã gây chặn oan thật:
#
#   1. Trong dấu nháy (audit 2026-09-12): `echo 'git reset --hard ...'` bị coi là lệnh git thật.
#   2. Trong thân heredoc (2026-09-14): `git commit -F - <<EOF ... EOF && git push -u origin
#      claude/<nhánh> --force-with-lease` bị quy tắc 1 chặn vì COMMIT MESSAGE có chữ "main" đứng
#      riêng ("quay về main"), dù nhánh đích là nhánh riêng. Cùng lượt đó quy tắc 2 cũng chặn oan
#      một lệnh `python3 - <<PY` mà thân script có chuỗi `git reset --hard` làm dữ liệu test.
#
# shellcheck source=/dev/null
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_hook-lib.sh"

cmd_scan="$(printf '%s' "$cmd" | strip_heredoc_bodies | sed "s/'[^']*'//g; s/\"[^\"]*\"//g")"

block() {
  echo "🚫 Lệnh bị chặn bởi block-dangerous-git.sh: $1" >&2
  echo "   Lý do: $2" >&2
  echo "   Nếu THỰC SỰ cần: chạy lại với ALLOW_DANGEROUS_GIT=1 (và nói rõ lý do cho người dùng)." >&2
  exit 2
}

# --- 1. force-push vào nhánh chính ---
if printf '%s' "$cmd_scan" | grep -Eq '(^|[^-])git[[:space:]]+([^|&;]*[[:space:]])?push([[:space:]]|$)' \
   && printf '%s' "$cmd_scan" | grep -Eq '(^|[[:space:]])(--force|--force-with-lease(=[^[:space:]]*)?|-f)([[:space:]]|$)' \
   && printf '%s' "$cmd_scan" | grep -Eq '(^|[[:space:]:])(main|master)([[:space:]]|$)'; then
  block "force-push vào nhánh chính" "CLAUDE.md §8: không push thẳng nhánh chính; force-push xoá lịch sử của người khác."
fi

# --- 2. reset --hard ---
if printf '%s' "$cmd_scan" | grep -Eq '(^|[^-])git[[:space:]]+([^|&;]*[[:space:]])?reset([[:space:]]|$)' \
   && printf '%s' "$cmd_scan" | grep -Eq '(^|[[:space:]])--hard([[:space:]]|$)'; then
  block "git reset --hard" "Mất vĩnh viễn thay đổi chưa commit. Dùng 'git stash' hoặc 'git restore <file>' cho phạm vi hẹp."
fi

# --- 3. --abort để né giải xung đột ---
if printf '%s' "$cmd_scan" | grep -Eq '(^|[^-])git[[:space:]]+([^|&;]*[[:space:]])?(merge|rebase|cherry-pick)([[:space:]]|$)' \
   && printf '%s' "$cmd_scan" | grep -Eq '(^|[[:space:]])--abort([[:space:]]|$)'; then
  block "git ...--abort" "CLAUDE.md §8: KHÔNG BAO GIỜ --abort để né việc giải xung đột — đọc cả hai phía rồi giải."
fi

# --- 4. force-push nhánh khác: cảnh báo, không chặn ---
if printf '%s' "$cmd_scan" | grep -Eq '(^|[^-])git[[:space:]]+([^|&;]*[[:space:]])?push([[:space:]]|$)' \
   && printf '%s' "$cmd_scan" | grep -Eq '(^|[[:space:]])(--force|-f)([[:space:]]|$)'; then
  echo "⚠️  force-push (không phải nhánh chính): chỉ hợp lệ trên nhánh DO BẠN tạo. Nhánh của người khác → dùng merge commit (CLAUDE.md §8)." >&2
fi

exit 0
