# Trạng thái Audit toàn diện

> AI đọc/ghi file này để biết quét tới đâu — cho phép tiếp tục qua nhiều phiên.
> Trạng thái mỗi nhóm: ⬜ Chưa quét · 🔄 Đang dở · ✅ Xong · ➖ Không áp dụng.
>
> **Chủ thể:** chính bộ khung `projects-template` (không phải app web) — xem `docs/FEATURE-MAP.md`.
> "Tính năng" = năng lực khung cung cấp cho dự án đích; code nghiệp vụ = 33 script engine trong
> `scripts/` + hệ cổng CI. `PROJECT.md` trống là **đúng chủ ý** (mẫu cho dự án đích điền), không
> phải dấu hiệu chưa có dự án — đây là lý do Bước -1 của `/audit-full` KHÔNG dừng ở repo này.

- Lần quét bắt đầu: **RESET 2026-09-15** (lượt trước: base `709cc86`, 2026-09-12 — đã trôi 51 commit)
- Base: `98ccd6f` (`origin/main`, sau PR #143)
- Hồ sơ dự án áp dụng (KHUNG-3 PHẦN C): **C5 CLI/thư viện** (tiệm cận) — tập script shell/Python
  + tài liệu, không runtime, không UI, không CSDL
- Giai đoạn: **GIAI ĐOẠN 1 (chỉ quét & đo, KHÔNG sửa gì)**

| # | Nhóm | Trạng thái | Tóm tắt phát hiện (số lượng theo mức độ) | Cập nhật lần cuối |
|---|------|-----------|-------------------------------------------|---------------------|
| 1 | Kiến trúc & thiết kế | ⬜ | | |
| 2 | Bảo mật | ⬜ | | |
| 3 | Chất lượng mã & chống lỗi logic | ⬜ | | |
| 4 | Kiểm thử & coverage | ⬜ | | |
| 5 | Hiệu năng | ⬜ | | |
| 6 | Accessibility & UI/UX | ⬜ | | |
| 7 | Dependency & chuỗi cung ứng | ⬜ | | |
| 8 | CI/CD & vận hành/observability | ⬜ | | |
| 9 | Tài liệu & đồng bộ | ⬜ | | |
| 10 | Dữ liệu & migration | ⬜ | | |
| 11 | Cấu hình môi trường & bí mật | ⬜ | | |
| 12 | Thống nhất chéo tính năng | ⬜ | | |

## Ghi chú điểm dừng (nhóm đang 🔄 dở — đã xét sub-mục nào, chưa xét sub-mục nào)
- (chưa có)

## Lượt trước (2026-09-12, base `709cc86`) — tham khảo, KHÔNG mang kết luận sang

8 nhóm ✅ · 4 nhóm ➖ (N5/N6/N10 không áp dụng sau ADR-0004). Cao 0 · Trung 4 (G-001..G-004, đã sửa
cả 4) · Thấp 0 mới. Vì đây là lượt **RESET**, mọi kết luận trên phải được **quét lại và tự chứng
minh**, không chép sang. Xem lịch sử Git của file này nếu cần tra nội dung cũ.
