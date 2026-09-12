# CODEMAP.md — muốn đổi X thì sửa ở đâu

> Bảng tra cứu cho chính bộ khung này (repo `project-template`). Mẫu rỗng cho dự án đích:
> `docs/framework/templates/CODEMAP.template.md`. Khác `docs/framework/README.md` (bảng ánh xạ **tên
> file cũ → mới**) và `docs/adr/` (quyết định) — file này trả lời **"chạm vào đâu, rồi chạy lại gì"**.

| Muốn | Sửa | Rồi chạy |
| --- | --- | --- |
| Thêm slash command mới | `.claude/commands/<tên>.md` **+** khai TRIGGER trong `CLAUDE.md` §1 (mục tương ứng) | `scripts/check-docs-consistency.sh` (kiểm hai chiều lệnh ↔ CLAUDE.md) |
| Thêm job cổng mới vào `ci.yml` | job mới **+** `needs:` của job `gate` **+** bản kê trong `docs/ops/repository-settings.md` (branch protection KHÔNG cần sửa — ADR-0003) | `scripts/check-ci-policy.sh` |
| Nâng/ghim phiên bản GitHub Action | `uses: <action>@<sha40> # <tag>` (lấy SHA: `git ls-remote --tags https://github.com/<action>`) | `scripts/check-ci-policy.sh` (bắt action chưa ghim SHA) |
| Đổi/thêm job trong `ci.yml` hoặc `pr-policy.yml` | `.github/workflows/{ci,pr-policy}.yml` **+** danh sách "Required checks — nguồn sự thật" trong `docs/ops/repository-settings.md` (khối ` ``` `) | `scripts/check-ci-policy.sh` (đối chiếu hai chiều job id) |
| Đổi tài liệu tham chiếu tới file khác | Đường dẫn trong backtick `` `path/to/file` `` | `scripts/check-docs-consistency.sh` (mục 1: bắt link gãy — trừ `docs/specs/**` vì spec tham chiếu file HƯỚNG TỚI TƯƠNG LAI, và trừ `ALLOW_MISSING_PATH`/`EXCLUDE_SOURCE` khai trong đầu script) |
| Đổi tên file/lệnh đã có (rename) | File thật **+** thêm dòng "tên cũ → tên mới" vào bảng ánh xạ ở `docs/framework/README.md` | `scripts/check-docs-consistency.sh` (mục 2: bắt tên cũ sót lại ngoài bảng ánh xạ) |
| Thêm/sửa mẫu tài liệu (`*.template.md`) cho dự án đích | `docs/framework/templates/<tên>.template.md` — copy nguyên cả thư mục `docs/framework/` sang đích (Layer 1) | `scripts/test-copy-framework.sh` (xác nhận copy đúng, không lồng thư mục khi chạy lại lần 2) |
| Đổi file gốc dự án đích nhận khi copy khung (`CLAUDE.md`, `PROJECT.md`…) | Danh sách `copy_if_absent "…"` trong `copy-framework.sh` **và** `Copy-IfAbsent "…"` trong `copy-framework.ps1` (hai bản khác tên hàm, phải khớp DANH SÁCH FILE) | `scripts/test-copy-framework.sh` |
| Đổi file cấu hình/stack Layer 2 (eslint, husky, workflow…) dự án đích tự merge | Danh sách `stage "…"` (`.sh`) / `Add-Dropin "…"` (`.ps1`) — đưa vào `_framework-dropins/`, KHÔNG đè file đang chạy | `scripts/test-copy-framework.sh` |
| Sửa/thêm hàng rào dropins (`app/`, `components/`, `lib/`, config Next.js…) | File dropins tương ứng ở gốc repo khung | `scripts/verify-dropins.sh` (dựng dự án Next.js sạch, copy khung vào, `lint`/`type-check`/`build`/`test` THẬT — chỗ duy nhất biên dịch dropins; xem `TRAPS.md` mục 1) |
| Thêm ngoại lệ cho cổng `check-docs-consistency.sh` (file sinh ở dự án đích, chưa tồn tại trong repo khung) | `ALLOW_MISSING_PATH` (không tồn tại ở đâu cả) hoặc `EXCLUDE_SOURCE`/`EXCLUDE_SOURCE_PREFIX` (nguồn cố ý chứa tên cũ/tham chiếu tương lai) ở đầu `scripts/check-docs-consistency.sh` | chạy lại chính script đó |
| Đổi lệnh dev tự động (auto-format, cổng chặn commit đỏ) chạy ở dự án đích | `scripts/dev-task.sh` (điểm vào ổn định, tự dò stack — KHÔNG hardcode `npm`/`ruff`/`go`… trực tiếp vào hook) | `scripts/test-copy-framework.sh` + tự chạy `dev-task.sh gate` ở một dự án mẫu |
| Sửa/thêm hook (auto-format, cổng commit, chặn lệnh git nguy hiểm) | `.claude/hooks/<tên>.sh` **+** khai trong `.claude/settings.json` VÀ `.claude/settings-shared-opusplan.json` (hai file phải khớp) | `scripts/test-hooks-gate.sh` (chứng minh hook CHẶN thật, không chỉ tồn tại) |
| Thêm/sửa subagent (Tầng 2/3) | `.claude/agents/<tên>.md` (frontmatter `name` + `description` nêu TẦNG, model, ranh giới "KHÔNG làm gì") **+** bảng nhãn `route:` trong `docs/framework/orchestration-3-tier.md` | ⚠️ **không có cổng máy nào** — chỉ `scripts/test-copy-framework.sh` kiểm thư mục có được copy; review bằng mắt |
| Sửa cơ chế/ví dụ golden test | `lib/order-summary.ts`, `lib/order-summary.golden.test.ts`, `lib/__golden__/` (dropins) **+** luật cập nhật golden ở `CLAUDE.md` §5 và `.claude/commands/gate.md` | `scripts/verify-dropins.sh` (chạy vitest thật); mẫu tài liệu: `docs/framework/templates/GOLDEN-TEST.template.md` |
| Đổi bản đồ tính năng / quy ước của chính khung | `docs/FEATURE-MAP.md`, `docs/CONVENTIONS.md` | `scripts/check-docs-consistency.sh`; đối chiếu khi audit Nhóm 12 (`/completion` Pha 1) |
| Ghi bẫy vừa mắc / tra bẫy cũ trước khi chẩn đoán | `TRAPS.md` (gốc repo khung; mẫu rỗng `docs/framework/templates/TRAPS.template.md`) | không có cổng máy — review bằng mắt khi duyệt PR |
| Đổi luật cốt lõi (giai đoạn, cổng, feature gate…) | `CLAUDE.md` **trước**, rồi soát lại `AGENTS.md` cho khớp (CLAUDE.md là nguồn sự thật) | `scripts/check-docs-consistency.sh` |
| Ghi nhận thay đổi đáng kể | `CHANGELOG.md` mục `## [Unreleased]` | — |
| Cập nhật trạng thái dự án sau mỗi mốc | `PROGRESS.md` | — |
