# Changelog

Mọi thay đổi đáng kể của dự án được ghi ở đây.

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/),
và dự án tuân theo [Semantic Versioning](https://semver.org/lang/vi/).

> Repo dùng **release-please** (`.github/workflows/release.yml`): vì commit theo *conventional
> commits*, release PR + ghi chú phát hành được sinh tự động khi phát hành. Phần "Unreleased"
> dưới đây vẫn cập nhật tay cho thay đổi đáng kể giữa các lần phát hành.

## [Unreleased]

### Added (Thêm)

- **Hoàn thiện quản trị OSS (Đợt 4 COMPLETION-PLAN):** thêm `CODE_OF_CONDUCT.md`
  (Contributor Covenant v2.1 tiếng Việt), `SUPPORT.md` + `GOVERNANCE.md` thật (từ template);
  dịch `CONTRIBUTING.md` sang tiếng Việt; gộp issue template về một bộ form `.yml`
  (xóa `bug_report.md`/`feature_request.md` cũ); làm mới `PROGRESS.md` theo
  `PROGRESS.template.md`; sửa mô tả `ci.yml` trong README và ghi chú release-please ở đây.
- **`scripts/verify-dropins.sh` + workflow `verify-dropins.yml`** — dựng một dự án Next.js sạch,
  copy khung vào, làm đúng Phần D của runbook rồi chạy lint/type-check/build/test THẬT.
  Trước đây các file dropins (`app/`, `components/`, `lib/`, config) chưa từng được biên dịch
  hay lint lần nào vì repo khung không có `package.json`. Chạy hằng đêm với
  `create-next-app@latest` nên cũng là cảm biến version drift từ thượng nguồn.
- **Cổng nhất quán lệnh:** `scripts/check-docs-consistency.sh` kiểm hai chiều giữa
  `.claude/commands/*.md` và `CLAUDE.md` — lệnh mới mà quên khai TRIGGER, hoặc `CLAUDE.md`
  trỏ tới lệnh không tồn tại, đều bị CI chặn thay vì phải rà tay.
- **Dependabot theo dõi `github-actions`** — các action trong `.github/workflows/` đang dùng
  tag trôi (`@v4`, `@v3`); đây là phụ thuộc thật của chính bộ khung, trước đây không ai canh.
- **Dấu bản khung ở dự án đích:** `copy-framework.sh`/`.ps1` sinh `docs/framework/FRAMEWORK-VERSION`
  (commit nguồn + ngày copy, luôn ghi đè theo lần copy gần nhất) — dự án đích biết mình đang dùng
  khung bản nào và so CHANGELOG này để quyết định khi nào copy lại.
- **`docs/framework/templates/`** — bản mẫu sạch cho 3 file làm việc của `/completion`:
  `FEATURE-MAP.template.md`, `CONVENTIONS.template.md`, `COMPLETION-PLAN.template.md`
  (tách từ khối inline trong `project-completion.md` — một nguồn sự thật, copy thẳng thay vì chép tay).

### Changed (Đổi)

- **Workflow siết quyền tối thiểu:** mọi workflow khai `permissions:` ở cấp workflow
  (`ci.yml`, `lighthouse-ci.yml`, `codeql.yml` trước đây nhận quyền mặc định của repo).
- **`concurrency` cho workflow:** push liên tiếp vào cùng một PR hủy lượt chạy cũ;
  trên `main` không hủy, và `release.yml` xếp hàng (không hủy) để tránh release dở dang.

### Fixed (Sửa)

- **`components/theme-toggle.tsx` fail lint chính config của khung** (`react-hooks/set-state-in-effect`
  của React Compiler, qua `eslint-config-next` bản mới). Viết lại theo `useSyncExternalStore` —
  đọc `data-theme` trên `<html>` (nguồn sự thật do script no-flash đặt) thay vì `useState` +
  `useEffect`; bỏ luôn một lượt render thừa sau hydrate.
- **`app/sw.ts` không type-check được** (`TS2552: Cannot find name 'ServiceWorkerGlobalScope'`)
  vì `lib` của Next chỉ có DOM. Thêm `/// <reference lib="webworker" />` theo từng-file.

### Removed (Bỏ)

-

<!--
Khi phát hành phiên bản, tạo mục mới phía trên, ví dụ:

## [0.1.0] - 2026-01-01
### Added
- Phiên bản đầu tiên.
-->
