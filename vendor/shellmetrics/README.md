# vendor/shellmetrics — bản sao có ghim của `shellspec/shellmetrics`

| Thuộc tính | Giá trị |
| --- | --- |
| Nguồn | https://github.com/shellspec/shellmetrics |
| Phiên bản | `0.5.0` (`VERSION=` trong chính file) |
| Commit đã lấy | `b3bfff2af6880443112cdbf2ea449440b30ab9b0` |
| SHA256 | xem `SHA256SUMS` (cổng tự kiểm trước mỗi lần chạy) |
| Giấy phép | MIT — giữ nguyên `LICENSE` cạnh file |
| Ngày lấy | 2026-09-15 |

**Vì sao vendor mà không tải lúc chạy:** cổng `scripts/check-shell-complexity.sh` phải chạy được
offline và không phụ thuộc GitHub còn sống; một cổng tự tắt (hoặc đỏ oan) vì mạng là cổng không
tin được. Đổi lại, mã bên thứ ba nằm trong repo nên **ghim SHA256**: cổng kiểm checksum trước khi
chạy, sửa/nâng cấp file mà quên cập nhật `SHA256SUMS` là CI đỏ.

**KHÔNG sửa tay `shellmetrics`.** Nâng cấp = chép bản mới từ upstream, cập nhật bảng trên +
`SHA256SUMS`, chạy lại `scripts/test-check-shell-complexity.sh` (số đo đổi thì phải xem lại trần).

`shellcheck --severity=warning` và `bash -n` chạy sạch trên file này nên nó KHÔNG được loại khỏi
hai cổng đó; nó chỉ được loại khỏi **phép đo CC** (không đo mã của người khác bằng trần của mình).
