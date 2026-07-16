# Changelog

Mọi thay đổi đáng kể của dự án được ghi ở đây.

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/),
và dự án tuân theo [Semantic Versioning](https://semver.org/lang/vi/).

> Vì commit theo *conventional commits*, phần "Unreleased" có thể được sinh tự động sau
> (ví dụ `standard-version` / `changesets`). Trước mắt cập nhật tay khi có thay đổi đáng kể.

## [Unreleased]

### Added (Thêm)

- **Dấu bản khung ở dự án đích:** `copy-framework.sh`/`.ps1` sinh `docs/framework/FRAMEWORK-VERSION`
  (commit nguồn + ngày copy, luôn ghi đè theo lần copy gần nhất) — dự án đích biết mình đang dùng
  khung bản nào và so CHANGELOG này để quyết định khi nào copy lại.
- **`docs/framework/templates/`** — bản mẫu sạch cho 3 file làm việc của `/completion`:
  `FEATURE-MAP.template.md`, `CONVENTIONS.template.md`, `COMPLETION-PLAN.template.md`
  (tách từ khối inline trong `project-completion.md` — một nguồn sự thật, copy thẳng thay vì chép tay).

### Changed (Đổi)

-

### Fixed (Sửa)

-

### Removed (Bỏ)

-

<!--
Khi phát hành phiên bản, tạo mục mới phía trên, ví dụ:

## [0.1.0] - 2026-01-01
### Added
- Phiên bản đầu tiên.
-->
