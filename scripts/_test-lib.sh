#!/usr/bin/env bash
# _test-lib.sh — thư viện dùng chung cho các script `scripts/test-*.sh` của khung.
#
# Rút ra đúng phần GIỐNG HỆT NHAU ở 8 script test-*.sh: biến đếm `fails` + hai hàm báo ca
# `ok`/`bad`. Các phần KHÁC nhau giữa các file (cách tính ROOT, set -e/-u, thông điệp kết luận
# cuối file, exit code cụ thể...) CỐ Ý không rút vào đây — mỗi file giữ nguyên phần đó.
#
# CHỈ dùng để `source`, KHÔNG tự chạy trực tiếp. Không set -e/-u/set khác ở đây: script gọi
# `source` này có thể đã set (hoặc cố ý KHÔNG set) shell option riêng — nạp lại ở đây sẽ ghi đè
# ngoài ý muốn (xem docs/CONVENTIONS.md §A: một số test cố ý không dùng `-e`).
#
# Cách dùng (đặt SAU khi đã tính $ROOT):
#   source "$ROOT/scripts/_test-lib.sh"
#   ok "..."   # in "  ✅ ..."
#   bad "..."  # in "  ❌ ...", tăng $fails

fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }
