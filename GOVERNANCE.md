# Governance — Quản trị dự án

> Repo khung này vận hành theo mô hình **một người bảo trì** (single-maintainer).

## Vai trò

| Vai trò | Trách nhiệm | Quyền quyết định | Bổ nhiệm/miễn nhiệm | Dự phòng |
| --- | --- | --- | --- | --- |
| Maintainer | @seeker19110 — toàn bộ: review/merge PR, triage issue, tài liệu, CI | Quyết định cuối mọi vấn đề | Chủ repo (tự thân) | chưa có (xem bus-factor) |
| Security owner | @seeker19110 — nhận báo cáo qua kênh [SECURITY.md](SECURITY.md), điều phối vá + công bố | Chấp nhận rủi ro, thời điểm công bố | như trên | chưa có |
| Release owner | @seeker19110 — duyệt release PR do release-please tạo (`release.yml`) | Tag/phát hành | như trên | chưa có |

## Ra quyết định

- **Thường ngày** (sửa tài liệu, fix nhỏ): maintainer tự quyết, qua PR + cổng `/gate`/CI như mọi thay đổi.
- **Kiến trúc/bảo mật/dữ liệu/breaking:** bắt buộc có **ADR** (`docs/adr/`, mẫu `0000-template.md`,
  không sửa ADR cũ) trước khi merge; AI đề xuất, người dùng/maintainer chốt (CLAUDE.md §9).
- **Khẩn cấp:** theo `docs/ops/incident-response.md` — giảm thiệt hại trước, hồi cứu (post-mortem) bắt buộc cho SEV1/SEV2.
- **Khiếu nại/xung đột:** mở issue công khai; quyết định cuối thuộc maintainer. Vi phạm ứng xử: theo [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Truy cập và kế thừa

- Least privilege: CI `permissions:` tối thiểu theo workflow/job; CODEOWNERS bảo vệ đường dẫn nhạy cảm
  (gồm `.claude/`); không push thẳng `main`, mọi merge qua PR.
- **Bus-factor = 1 (rủi ro đã ghi nhận):** chưa có maintainer dự phòng. Người fork/copy khung không phụ
  thuộc repo này để vận hành. Khi có cộng tác viên tích cực, sẽ mời làm co-maintainer và cập nhật file này.

## Thẩm quyền phát hành và lỗ hổng

- Chỉ @seeker19110 được tag/phát hành (merge release PR của release-please), gỡ bản lỗi, nhận báo cáo
  lỗ hổng, quyết định embargo và nội dung công bố (mục tiêu phản hồi 72 giờ — SECURITY.md).

## Sửa đổi governance

Đề xuất qua PR sửa chính file này (kèm lý do); thay đổi lớn về cách vận hành → kèm ADR. Maintainer duyệt và merge.
