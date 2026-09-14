---
description: Audit tối ưu mã nguồn (brownfield) — đo baseline rồi dừng chờ duyệt
---

Đọc kỹ `docs/ops/code-optimization-audit-prompt.md` trong repo này và **làm theo đúng quy trình trong đó**.

Ràng buộc bắt buộc (chi tiết & lệnh đo cụ thể nằm ở file trên — bám đúng `quality-supplements.md` Nhóm 2 mục 9 + `existing-project-adoption.md` Bước 2–3 + `CLAUDE.md` §3 mục 7):

- Đây là **AUDIT TỐI ƯU MÃ NGUỒN** theo lối brownfield. Nguyên tắc bất biến: **KHÔNG đổi hành vi** · mỗi thay đổi có **test bảo vệ** · đi **PR riêng** · ưu tiên **giá trị cao / rủi ro thấp** · **không tối ưu non**.
- Chạy **GIAI ĐOẠN 1 (đo baseline — chỉ đọc & đo, KHÔNG sửa gì):** tự dò stack; chạy knip / depcheck / jscpd / ESLint `complexity` / bundle-analyzer (qua `npx`, **không** thêm vào dependencies); tổng hợp **BÁO CÁO AUDIT** theo 5 nhóm (dead code · trùng lặp/độ phức tạp · dependency · bundle · **tự viết lại thứ đã có** — nhãn `stdlib:` cho thứ thư viện chuẩn đã có, `native:` cho thứ nền tảng đã làm sẵn; nhóm này **không công cụ nào đo được**, phải tự rà, và là mặt sau của thang `CLAUDE.md` §3 A4), mỗi mục ghi vị trí · mức độ · đề xuất · rủi ro · đã có test che chưa; xếp theo ưu tiên; kết bằng một dòng tổng `net: -<N> dòng, -<M> dependency` — **rồi DỪNG, chờ người dùng duyệt.**
- Chỉ sang **GIAI ĐOẠN 2 (hạ dần)** sau khi được duyệt: làm từng PR nhỏ, có test bảo vệ trước, đo trước–sau, commit `refactor:`/`chore:`.

Nếu **không tìm thấy** `docs/ops/code-optimization-audit-prompt.md` (repo chưa áp khung), vẫn tiến hành theo đúng ràng buộc tóm tắt trên và báo cho người dùng biết file chưa có để cân nhắc chạy `copy-framework.sh`.

Bắt đầu **GIAI ĐOẠN 1** ngay.
