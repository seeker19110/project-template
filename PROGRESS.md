# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 7 — Hoàn thiện bộ khung (thực thi kế hoạch hoàn thiện `/completion`)
- Default-branch SHA đã đối chiếu: `57c83e1` (`origin/main`)
- Ngày cập nhật: 2026-08-23

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Hoàn thiện khung theo COMPLETION-PLAN | 0 phát hiện Cao mở; Vừa/Thấp có kết cục ghi nhận; đạt Definition of Complete | BUILD | Đợt 1–4 (W-1xx…W-4xx) đang thực thi | Xong Đợt 4 → Pha 4 re-audit hội tụ | `docs/ops/COMPLETION-PLAN.md` |

## Đã xong (tóm tắt)

- Dựng trọn bộ khung: quy trình 9 giai đoạn + cổng, luật AI (CLAUDE.md/AGENTS.md), research-first,
  slash commands (`/consult` `/gate` `/bootstrap` `/auto` `/audit-full` `/audit-optimize` `/incident`
  `/completion` `/grill` `/debug` `/ui-ux` `/adr`), điều phối 3 tầng + opusplan, drop-ins hồ sơ Web
  (Next.js/TS/Tailwind/Supabase), `copy-framework.sh`/`.ps1` + smoke test, OpenSpec (tùy chọn).
- Hàng rào tự kiểm cho chính khung: CI `framework-lint` / `docs-consistency`
  (`scripts/check-docs-consistency.sh`) / `copy-framework-smoke` / `source-hygiene` (knip) /
  `verify-dropins.yml`; case-study greenfield chạy thật đầu-cuối (vá eslint flat config, hook, dropins).
- Tái cấu trúc tên file sang tiếng Anh (nội dung tiếng Việt), bản đồ tên cũ→mới ở `docs/framework/README.md`.
- PR đã merge gần nhất: **#44** (hợp nhất chuẩn — standard-delivery), **#45** (governance & supply-chain),
  **#46** (parallel subagent workflow). Các mốc cũ hơn (#19–#32…): xem lịch sử Git của file này + CHANGELOG.

## Đang làm / chờ

- Thực thi `docs/ops/COMPLETION-PLAN.md` (4 đợt W-1xx→W-4xx) trên nhánh
  `claude/software-dev-standards-jc776c` — hiện ở Đợt 4 (quản trị OSS & tài liệu đồng bộ).

## Tiếp theo

- Xong Đợt 4 → **Pha 4 re-audit hội tụ** (quét lại theo danh mục F-xxx, ghi Nhật ký hội tụ trong
  COMPLETION-PLAN, nghiệm thu theo Definition of Complete). Owner: AI + người dùng duyệt.

## Quyết định quan trọng

- **opusplan là điểm ngọt, không đổi** — tối ưu token bằng CHIA VIỆC (subagent, cô lập ngữ cảnh),
  không "route theo độ khó". Chi tiết: `docs/framework/models-and-automation.md`.
- Giữ scaffold Web (Next.js+Supabase) làm hồ sơ mặc định; loại khác thay công cụ tương đương (KHUNG-3 PHẦN C).
- Copy-framework KHÔNG đè file có sẵn ở dự án đích (`copy_if_absent`); cấu hình stack vào `_framework-dropins/`.
- ADR: `docs/adr/` (vd `0001-stack-selection.md`).

## Rủi ro, blocker và nợ kỹ thuật

| Mục | Severity | Owner | Trigger/next action | Link |
| --- | --- | --- | --- | --- |
| F-011 `--theme-transition` dead token | Thấp | AI | Chấp nhận rủi ro (chờ người dùng xác nhận khi duyệt kế hoạch) | `docs/ops/COMPLETION-PLAN.md` |
| F-014 usage-guard số thập phân | Thấp | AI | Chấp nhận rủi ro (như trên) | `docs/ops/COMPLETION-PLAN.md` |
| F-309 `dev-task.sh` fallback grep | Thấp | AI | Chấp nhận rủi ro (như trên) | `docs/ops/COMPLETION-PLAN.md` |
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |

## Bàn giao phiên

- Lần cập nhật: 2026-08-23
- State: BUILD
- Việc dở và bằng chứng mới nhất: đang thực thi Đợt 4 COMPLETION-PLAN (W-401…W-405: CODE_OF_CONDUCT,
  gộp issue template, dịch CONTRIBUTING, làm mới PROGRESS, sửa README/CHANGELOG + SUPPORT/GOVERNANCE).
- Bước tiếp theo: hoàn tất Đợt 4, chạy `/gate`, cập nhật trạng thái W-xxx trong COMPLETION-PLAN, rồi Pha 4 re-audit.
- Quyền/quyết định cần thêm: người dùng xác nhận 3 mục chấp nhận rủi ro (F-011/F-014/F-309) khi duyệt kế hoạch.
