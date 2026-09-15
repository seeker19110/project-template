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
# Đây là khuôn "bộ đếm/bộ dò tự khớp văn bản của chính thứ nó đang soi"
# (`docs/framework/quality-supplements-group2.md` §"Sổ trần cho LỐI THOÁT khỏi cổng coverage").
# Nguy hiểm của chặn oan không phải là phiền: nó dạy người ta gõ ALLOW_DANGEROUS_GIT=1 thành phản
# xạ, và lúc đó hàng rào không còn chặn được ca thật.
#
# CẨN TRỌNG khi sửa hàm dưới: bỏ NHẦM một dòng LÀ LỆNH thì hàng rào để lọt — hỏng theo chiều nguy
# hiểm, không phải chiều phiền. Bản đầu của chính lần sửa này dùng `<<-?[[:space:]]*DELIM`, và
# `echo "a << b"` khớp thành heredoc với delimiter `b` → mọi dòng SAU đó bị nuốt, nên
# `git reset --hard` ở dòng kế KHÔNG bị chặn (đo được, không phải suy đoán). Vì thế: KHÔNG cho phép
# khoảng trắng giữa `<<` và delimiter. Ca đó nay là một ca chặn bắt buộc ở `test-hooks-gate.sh` mục 7.
#
# GIỚI HẠN CÒN LẠI (nói ra, không giấu):
#   - dữ liệu KHÔNG nháy và KHÔNG heredoc vẫn bị quét — `git push -f origin claude/x && echo main`
#     vẫn chặn oan. Sửa hẳn cần tách lệnh theo `&&`/`;`/`|` rồi chỉ soi segment bắt đầu bằng `git`;
#     chưa làm vì phạm vi rộng hơn hẳn và chưa có sự cố thật.
#   - `<<-EOF` đóng bằng dòng thụt TAB: ĐÃ XỬ LÝ 2026-09-15 (audit F-301). Trước đó dòng đóng
#     thật là TAB+EOF nên không bằng `EOF`, delim không bao giờ xoá, awk nuốt hết phần còn lại và
#     `git reset --hard` đứng sau ĐI LỌT (đo được: rc=0 thay vì 2). Nay bỏ TAB đầu trước khi so,
#     CHỈ khi heredoc mở bằng `<<-`. Hai ca chốt chặn ở `test-hooks-gate.sh` mục 7 và mục 8.
#   - `cat << EOF` (có khoảng trắng — POSIX cho phép) không được nhận là heredoc nữa, nên thân nó
#     vẫn bị quét → có thể chặn oan. Đây là đánh đổi CỐ Ý: chặn oan thì người dùng thấy ngay và nói,
#     còn để lọt thì không ai biết. Chọn chiều an toàn.
# \047 = nháy đơn, \042 = nháy kép (escape bát phân của awk). Dùng chúng thay vì viết nháy thật để
# CẢ chương trình awk nằm gọn trong một cặp nháy đơn của shell — không có chỗ nào phải thoát nháy
# lồng nhau, thứ vừa khó đọc vừa dễ hỏng lặng lẽ khi ai đó sửa.
strip_heredoc_bodies() {
  awk '
    BEGIN { delim = ""; dash = 0 }
    {
      if (delim != "") {
        line = $0
        # \011 = TAB. `<<-` (CÓ gạch ngang) cho phép dòng đóng thụt bằng TAB — POSIX.
        # Không bỏ TAB trước khi so thì delim không bao giờ khớp, awk nuốt hết phần
        # còn lại của lệnh, và lệnh nguy hiểm đứng sau heredoc KHÔNG bị quét.
        if (dash) { sub(/^\011+/, "", line) }
        if (line == delim) { delim = ""; dash = 0 }
        next
      }
      if (match($0, /<<-?[\047\042]?[A-Za-z_][A-Za-z0-9_]*[\047\042]?/)) {
        d = substr($0, RSTART, RLENGTH)
        dash = (substr(d, 1, 3) == "<<-") ? 1 : 0
        sub(/^<<-?/, "", d)
        gsub(/[\047\042]/, "", d)
        delim = d
      }
      print
    }'
}
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
