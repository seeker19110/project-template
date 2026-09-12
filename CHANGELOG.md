# Changelog

Mọi thay đổi đáng kể của dự án được ghi ở đây.

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/),
và dự án tuân theo [Semantic Versioning](https://semver.org/lang/vi/).

> Repo dùng **release-please** (`.github/workflows/release.yml`): vì commit theo *conventional
> commits*, release PR + ghi chú phát hành được sinh tự động khi phát hành. Phần "Unreleased"
> dưới đây vẫn cập nhật tay cho thay đổi đáng kể giữa các lần phát hành.

## [Unreleased]

### Added (Thêm)

- **Feature spec golden test + kỷ luật TDD (`docs/specs/2026-09-12-golden-tests-and-tdd.md`)** — *spec, CHƯA thực thi.*
  Rà thật cho thấy: **golden test chưa tồn tại như cơ chế** (chỉ 2 lần nhắc thoáng qua ở
  `01-process-and-standards.md:11` và `03-tech-selection-and-proactive-advice.md:237`, không định nghĩa,
  không nơi lưu fixture, **không luật cập nhật** — nên golden đỏ sẽ bị `vitest -u` làm xanh, tức ghi nhận
  bug thành giá trị kỳ vọng mới); và **TDD chỉ bắt buộc ở một ca hẹp trong một nhánh lệnh** ("bug có test
  tái hiện trước khi sửa" chỉ sống ở `/completion` + `/audit-full`, vắng mặt ở `CLAUDE.md` §3/§5/§6 và
  `/gate`, nên PR `fix` thường hoặc phiên `/auto` không đi qua). Spec nâng luật lên cấp khung + cổng,
  giữ vòng đỏ-xanh tổng quát là khuyến nghị, và cố ý KHÔNG ép test-trước lên scaffolding/rename/docs.
  Nguồn thượng nguồn: repo `Claude-Agents`, workflow eval-record.yml (cập nhật golden là hành động
  thủ công có người bấm nút, tách khỏi việc phát hiện lệch), `donghanh` (`*-fixtures.json`), `xboss`
  (allowlist ngoại lệ tường minh). Kế hoạch 3 PR ở §17.
- **Feature spec gói A+B+C (`docs/specs/2026-09-12-traps-codemap-ci-policy.md`)** — *spec, CHƯA thực thi.*
  Rút ba lỗ hổng có thật của khung từ lượt quét 15 repo dẫn xuất (2026-09-12): (A) không có nơi tích luỹ
  bẫy đã mắc qua thời gian → `TRAPS.template.md`; (B) thiếu bảng tra `Muốn | Sửa | Rồi chạy` giữa
  `FEATURE-MAP` ("có gì") và `CONVENTIONS` ("viết thế nào") → `CODEMAP.template.md`; (C) danh sách
  required checks của branch protection KHÔNG tồn tại ở đâu và `ci.yml` có 6 job phẳng (`framework-lint`, `docs-consistency`, `copy-framework-smoke`, `quality`, `source-hygiene`, `e2e`), 0 `needs:` —
  nên đổi tên một job id sẽ làm required check cũ không bao giờ báo cáo nữa và kẹt merge mọi PR mà
  không PR nào hiện màu đỏ → thêm một script đối chiếu hai chiều (tên dự kiến
  scripts/check-ci-policy.sh, chưa tồn tại).
  Nguồn thượng nguồn: `Claude-Agents` (TRAPS/CODEMAP), `donghanh` (policy-as-test).
  Kế hoạch 4 PR + mục CHANGELOG khi thực thi nằm trong §17–§18 của spec.
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
