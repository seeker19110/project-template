# COMPREHENSIVE-AUDIT-STATUS — trạng thái quét audit toàn diện

> Chủ thể: **chính bộ khung** `project-template` (không phải app web) — xem `docs/FEATURE-MAP.md`.
> Lượt quét: bắt đầu 2026-09-12 · base `772c949` (`main`) · chạy qua `/completion` Pha 1.
> Trạng thái: ✅ Xong · 🔄 Đang dở · ⬜ Chưa quét · ➖ Không áp dụng.

| Nhóm | Tên | Trạng thái | Phát hiện | Ngày |
| --- | --- | --- | --- | --- |
| 1 | Kiến trúc & thiết kế | ✅ Xong | 1 Trung (F-010) | 2026-09-12 |
| 2 | Bảo mật | ✅ Xong | 2 Trung (F-005, F-009) | 2026-09-12 |
| 3 | Chất lượng mã & chống lỗi logic | ✅ Xong | 1 Trung (F-007) | 2026-09-12 |
| 4 | Kiểm thử & coverage | ✅ Xong | 1 Cao (F-002), 1 Trung (F-006), 1 Thấp (F-015) | 2026-09-12 |
| 5 | Hiệu năng | ➖ Không áp dụng | Khung không có runtime; ngân sách CWV/bundle thuộc dropins, đã có `lighthouse-ci.yml` + tối ưu job e2e ở PR #60 | 2026-09-12 |
| 6 | Accessibility & UI/UX | ➖ Không áp dụng | Khung không có UI; dropins có axe trong `e2e/smoke.spec.ts` + `styles/theme.css` tokens, đã verify qua `verify-dropins.sh` | 2026-09-12 |
| 7 | Dependency & chuỗi cung ứng | ✅ Xong | 1 Cao (F-001), 1 Trung (F-003) | 2026-09-12 |
| 8 | CI/CD & vận hành | ✅ Xong | 1 Trung (F-004), 1 Thấp (F-014); `main` protected=true (xác minh qua GitHub API) | 2026-09-12 |
| 9 | Tài liệu & đồng bộ code thật | ✅ Xong | 2 Thấp (F-011, F-012); `[ĐIỀN]` ở `CLAUDE.md` §5/§10 là CỐ Ý (§10 ghi rõ) | 2026-09-12 |
| 10 | Dữ liệu & migration | ✅ Xong | 0 mới (F-009 tính ở Nhóm 2); migration có version + idempotent + rollback documented | 2026-09-12 |
| 11 | Cấu hình môi trường & bí mật | 🔄 Đang dở | Đã xét: `lib/env.ts` (Zod, tách client/server, `NEXT_PUBLIC_` đúng) ✅; không có `.env` trong `git ls-files` ✅. **CHƯA xét: nội dung `.env.example` đối chiếu `lib/env.ts`** — môi trường phiên chặn đọc file `.env*` (permission denied). Cần chạy lại ở phiên có quyền đọc. | 2026-09-12 |
| 12 | Thống nhất chéo tính năng | ✅ Xong | 3 Trung (F-006, F-007, F-008), 2 Thấp (F-011, F-013) | 2026-09-12 |

## Tổng hợp mức độ

- **Cao: 2** — F-001, F-002
- **Trung: 8** — F-003, F-004, F-005, F-006, F-007, F-008, F-009, F-010
- **Thấp: 7** — F-011, F-012, F-013, F-014, F-015, F-016, F-017

### Phát hiện thêm trong lúc chạy Pha 2 (cổng tự bắt)

- **F-016 (Thấp, Nhóm 9):** `ALLOW_MISSING_PATH` trong `scripts/check-docs-consistency.sh` vẫn liệt kê
  4 file mà repo khung **giờ đã có thật** (`docs/CONVENTIONS.md`, `docs/FEATURE-MAP.md`,
  `docs/ops/COMPLETION-PLAN.md`, `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md`) → cổng không còn bảo vệ chúng.
- **F-017 (Thấp, Nhóm 4):** cổng dùng `git grep` nên **bỏ qua file chưa `git add`** → chạy local báo PASS
  oan. Xảy ra thật trong phiên này: một tham chiếu gãy trong `docs/FEATURE-MAP.md` chỉ bị bắt sau khi commit.

(Chi tiết từng phát hiện: xem BÁO CÁO AUDIT trong phiên 2026-09-12; sẽ chuyển thành `W-xxx` khi
người dùng duyệt kế hoạch ở Pha 2. Chưa duyệt → CHƯA sửa gì.)

## Phát hiện cũ đã có kết cục (không quét lại)

F-011/F-014/F-309 của lượt `COMPLETION-PLAN.md` (01/09) đã **chấp nhận rủi ro** — ID trùng số nhưng
khác lượt quét; lượt này dùng tiền tố cùng dạng, đối chiếu theo ngày.
