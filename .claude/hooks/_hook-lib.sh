#!/usr/bin/env bash
# _hook-lib.sh — Hàm dùng chung cho các hook đọc LỆNH BASH sắp chạy.
# Được `source` bởi: block-dangerous-git.sh, pre-commit-gate.sh.
#
# VÌ SAO TÁCH RA (audit 2026-09-15, F-304): bản vá bỏ-thân-heredoc trước đây CHỈ nằm trong
# block-dangerous-git.sh. pre-commit-gate.sh không có nó, nên một lệnh `cat` viết tài liệu có
# heredoc nhắc `git commit` bị hiểu là commit thật → chạy toàn bộ `dev-task.sh gate` cho một lệnh
# cat, và ở dự án đích đang đỏ thì CHẶN OAN. Hai hook soi cùng một thứ (chuỗi lệnh Bash) nên phải
# hiểu cú pháp giống nhau; chép tay lần hai là bảo đảm chúng sẽ lệch nhau lần sau.
#
# LƯU Ý khi thêm file được `source` (TRAPS mục 19): file này nằm trong `.claude/hooks/`, mà
# `copy-framework.sh` copy NGUYÊN THƯ MỤC đó (`copy_if_absent ".claude/hooks"`) — nên nó tự đi theo,
# không cần thêm vào danh sách `cp` nào. Kiểm điều đó ở `scripts/test-copy-framework.sh`.

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
