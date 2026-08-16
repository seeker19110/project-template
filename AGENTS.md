# AGENTS.md

> Chuẩn mở [agents.md](https://agents.md) cho MỌI AI coding agent (Codex, Cursor, Copilot, Windsurf…).
> **Nguồn sự thật duy nhất của luật dự án là `CLAUDE.md` (gốc repo) — đọc file đó TRƯỚC KHI làm bất cứ việc gì.**
> File này chỉ tóm tắt tối thiểu để agent không hỗ trợ CLAUDE.md vẫn làm đúng; khi hai file lệch nhau, `CLAUDE.md` thắng.

## Đọc theo thứ tự

1. `CLAUDE.md` — vai trò, quy trình, cổng chất lượng, luật bất biến (bản đầy đủ).
2. `docs/framework/standard-delivery.md` — contract chuẩn duy nhất: Research/Spec, Goal loop, DoR/DoD/Complete.
3. `PROJECT.md` — *cái gì* cần xây (MVP, schema, kiến trúc, Definition of Done).
4. `PROGRESS.md` — dự án đang ở giai đoạn nào, việc tiếp theo là gì.
5. `docs/framework/` — tài liệu chuyên sâu (đọc đúng phần do contract định tuyến).

## Luật tối thiểu (bản đầy đủ + ngoại lệ: xem `CLAUDE.md`)

- **Theo giai đoạn, không bỏ giai đoạn** — trước khi chuyển giai đoạn phải đạt cổng và được người dùng xác nhận.
- **Feature gate:** research + `docs/specs/*` phải được **Approved for implementation** trước khi sửa source.
- **Goal loop:** mục tiêu nhiều PR dùng `docs/goals/*`; mỗi iteration một outcome/PR, reconcile từ `main`,
  cùng failure tối đa 3 lần, kết thúc chỉ khi Goal/Project DoD có bằng chứng.
- **Subagent song song:** chỉ tách việc độc lập; chốt contract trước; mỗi agent có file/phạm vi ghi riêng, không trùng file/artifact sinh chung. Đọc/phân tích được chạy song song; dependency dùng chung, migration, lockfile phải tuần tự. Mỗi agent báo file đổi, kiểm tra, rủi ro; agent chính review diff, tích hợp và chạy đủ build/type/lint/format/test. Chỉ dùng số agent tương ứng với lượng việc độc lập hữu ích.
- **Chống ảo giác:** không bịa hàm/thư viện/API — xác minh bằng tài liệu/mã nguồn thật; không đoán kết quả lệnh — chạy thật và đọc output; xác minh phiên bản bằng nguồn sống, không dùng trí nhớ.
- **Cổng trước khi commit:** build + type-check + lint (0 cảnh báo) + format + test liên quan đều PHẢI xanh; tự đọc lại diff; không bí mật/`console.log` debug trong code. Lệnh cụ thể: xem `CLAUDE.md` §5 / `package.json`.
- **Cổng trước khi merge:** toàn bộ test xanh, nhánh cập nhật với `main`, đối chiếu tiêu chí chấp nhận trong `PROJECT.md` — xem `CLAUDE.md` §6.
- **Git:** mỗi tính năng một nhánh (`feat/...`, `fix/...`); conventional commits; mọi thay đổi vào `main` qua PR (ưu tiên squash); KHÔNG push thẳng `main`.
- **Bảo mật:** không tin client; logic nhạy cảm ở server; truy vấn tham số hóa; không commit `.env`/bí mật.
- **Dừng và hỏi** khi: yêu cầu mơ hồ, thao tác không thể hoàn tác, breaking change, đụng bảo mật/thanh toán/dữ liệu người dùng thật (`CLAUDE.md` §9).
- **Chủ động góp ý:** thấy rủi ro/cách tốt hơn thì nêu ra kèm đề xuất — im lặng làm theo khi biết có vấn đề là vi phạm.

## Lệnh của dự án

Xem `CLAUDE.md` §10 (tech stack, lệnh dev/build/test/lint) — dự án thật sẽ điền tại đó; khi chưa điền, tự dò từ `package.json`.
