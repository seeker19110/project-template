---
description: Cổng commit/merge + Báo cáo xác thực — chạy build/type-check/lint/format/test rồi xuất báo cáo; chặn nếu có mục ❌
---

Chạy **cổng chất lượng trước khi commit/merge** rồi xuất **Báo cáo xác thực**, đúng `CLAUDE.md` §5–§7. Mục tiêu: không bao giờ commit/merge khi còn mục ❌.

> `[ĐIỀN: ...]` trong CLAUDE.md §5 là cố ý — **lệnh tùy dự án**. KHÔNG giả định `npm run build`… Phải **tự dò script thật** trước (chống ảo giác, CLAUDE.md §4).

## Bước 1 — Tự dò lệnh thật (không đoán)
1. Đọc `package.json` → trường `scripts`. Suy ra trình chạy gói từ lockfile (`pnpm-lock.yaml`→pnpm, `yarn.lock`→yarn, `package-lock.json`→npm, `bun.lockb`→bun).
2. Khớp các cổng với script **thực sự tồn tại** (tên có thể khác): build (`build`), type-check (`type-check`/`typecheck`/`tsc`), lint (`lint`), format (`format:check`/`format`/`prettier --check`), test (`test`/`test:run`/`vitest run`).
3. Cổng nào **không có script tương ứng** → ghi **N/A** trong báo cáo (không bịa lệnh, không tự cài).
4. Không có `package.json` (vd repo template chưa scaffold) → báo "chưa có hàng rào để chạy", gợi ý `/bootstrap`, dừng.

## Bước 2 — Chạy & ĐỌC output thật
Chạy từng cổng dò được, **đọc kết quả thật** (không suy đoán). Phạm vi test: trước **commit** chạy test liên quan; trước **merge** chạy **toàn bộ** test (CLAUDE.md §6). Nếu người dùng gõ `/gate merge` → chế độ merge (toàn bộ test + các mục §6).

## Bước 3 — Tự rà diff (CLAUDE.md §5)
`git diff` (đã/ chưa stage): đúng mục tiêu, không sửa nhầm · xóa `console.log` debug/code chết · **không bí mật trong code** · mọi input ngoài đã validate · mọi thao tác có thể lỗi đã xử lý · commit message theo **conventional commits**.

**Nếu commit là `fix:`** (CLAUDE.md §3.6): có test tái hiện đã chạy **đỏ trước khi sửa** trong diff/lịch sử phiên này không? Có → ghi `✅` + dẫn output đỏ. Không, và đây thật sự là sửa lỗi chính tả/đổi tên cơ học/chỉ tài liệu → `n-a` (ngoại lệ hợp lệ, không phải nợ kỹ thuật). Không rơi vào ngoại lệ nào → **CẢNH BÁO, hỏi lại người dùng**: có muốn viết test tái hiện trước khi tiếp tục, hay đây thực ra nên là `chore:`/`docs:`? Không tự động chặn — chỉ `/completion`/`/audit-full` chặn cứng mục này.

**Nếu diff đổi một golden/snapshot test:** điền checklist `docs/framework/templates/GOLDEN-TEST.template.md` và dán vào PR body (diff golden + lý do thay đổi, không phải chỉ trong code). Đổi golden mà không giải thích được bằng thay đổi khác trong PR → đó là dấu hiệu hồi quy, không phải "làm xanh" — dừng, chẩn đoán trước khi cập nhật golden (`-u`).

## Bước 4 — Xuất Báo cáo xác thực (đúng mẫu §7)
```
Build ✅/❌/N/A | Type ✅/❌ (lỗi:..) | Lint ✅/❌ (cảnh báo:..) | Format ✅/❌ | Test ✅/❌ (X/Y)
Test tái hiện (nếu là fix) ✅/❌/n-a | Golden ✅/n-a
Tự review diff ✅ | Không bí mật/rác ✅ | Tiêu chí chấp nhận ✅ | DoD ✅
Rủi ro/ảnh hưởng: .. | Góp ý cải tiến: ..
KẾT LUẬN: Sẵn sàng  /  Cần xử lý: [..]
```
**Bất kỳ mục ❌ → sửa trước, chạy lại TOÀN BỘ, KHÔNG commit/merge** (CLAUDE.md §7). Lint phải **0 cảnh báo**. `Test tái hiện` là cảnh báo mềm (xem trên) — mọi mục khác vẫn chặn cứng như trước.

## Chế độ merge (`/gate merge`) — thêm các mục §6
Toàn bộ test xanh · nhánh đã cập nhật với nhánh chính, không xung đột · đối chiếu **tiêu chí chấp nhận** (`PROJECT.md`) + **DoD** · smoke test luồng chính · rà bảo mật (quyền server, không lộ dữ liệu) · nếu đổi schema: migration có phiên bản + rollback · đã rà tối ưu mã nguồn mảng vừa xong (hoặc `/audit-optimize`) · liệt kê phần hệ thống bị ảnh hưởng.

Bắt đầu **Bước 1 — tự dò lệnh thật** ngay.
