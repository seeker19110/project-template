# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — Khung đã hoàn thiện (Definition of Complete đã nghiệm thu), sẵn sàng dùng cho dự án đích
- Default-branch SHA đã đối chiếu: `151de56` (`origin/main`, PR #52 đã merge)
- Ngày cập nhật: 2026-09-01

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Hoàn thiện khung theo COMPLETION-PLAN | 0 phát hiện Cao mở; Vừa/Thấp có kết cục ghi nhận; đạt Definition of Complete | ✅ ĐÓNG (2026-09-01) | — | Không còn goal mở; theo dõi bằng audit định kỳ nếu cần | `docs/ops/COMPLETION-PLAN.md` |

## Đã xong (tóm tắt)

- Dựng trọn bộ khung: quy trình 9 giai đoạn + cổng, luật AI (CLAUDE.md/AGENTS.md), research-first,
  slash commands (`/consult` `/gate` `/bootstrap` `/auto` `/audit-full` `/audit-optimize` `/incident`
  `/completion` `/grill` `/debug` `/ui-ux` `/adr`), điều phối 3 tầng + opusplan, drop-ins hồ sơ Web
  (Next.js/TS/Tailwind/Supabase), `copy-framework.sh`/`.ps1` + smoke test, OpenSpec (tùy chọn).
- Hàng rào tự kiểm cho chính khung: CI `framework-lint` / `docs-consistency`
  (`scripts/check-docs-consistency.sh`) / `copy-framework-smoke` / `source-hygiene` (knip) /
  `verify-dropins.yml`; case-study greenfield chạy thật đầu-cuối (vá eslint flat config, hook, dropins).
- Tái cấu trúc tên file sang tiếng Anh (nội dung tiếng Việt), bản đồ tên cũ→mới ở `docs/framework/README.md`.
- PR đã merge gần nhất: **#52** (hoàn thiện khung theo COMPLETION-PLAN, 4 đợt/22 việc W-101→W-406,
  Pha 4 re-audit hội tụ + nghiệm thu Definition of Complete PASS), **#46** (parallel subagent workflow),
  **#45** (governance & supply-chain), **#44** (hợp nhất chuẩn — standard-delivery). Mốc cũ hơn
  (#19–#32…): xem lịch sử Git của file này + CHANGELOG.

## Đang làm / chờ

- Không có việc dở. `docs/ops/COMPLETION-PLAN.md` đã đóng (22/22 việc ✅, Pha 4 nghiệm thu PASS,
  3 mục Thấp F-011/F-014/F-309 đã được người dùng xác nhận chấp nhận rủi ro 2026-09-01).

## Tiếp theo

- Chờ yêu cầu tiếp theo của người dùng: bắt đầu dự án đích mới bằng khung này (`/consult` hoặc
  `/auto`), hoặc audit định kỳ khác (`/audit-full`) nếu phát sinh nhu cầu.

## Quyết định quan trọng

- **opusplan là điểm ngọt, không đổi** — tối ưu token bằng CHIA VIỆC (subagent, cô lập ngữ cảnh),
  không "route theo độ khó". Chi tiết: `docs/framework/models-and-automation.md`.
- Giữ scaffold Web (Next.js+Supabase) làm hồ sơ mặc định; loại khác thay công cụ tương đương (KHUNG-3 PHẦN C).
- Copy-framework KHÔNG đè file có sẵn ở dự án đích (`copy_if_absent`); cấu hình stack vào `_framework-dropins/`.
- ADR: `docs/adr/` (vd `0001-stack-selection.md`).

## Rủi ro, blocker và nợ kỹ thuật

| Mục | Severity | Owner | Trigger/next action | Link |
| --- | --- | --- | --- | --- |
| F-011 `--theme-transition` dead token | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| F-014 usage-guard số thập phân | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| F-309 `dev-task.sh` fallback grep | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |

## Bàn giao phiên

- Lần cập nhật: 2026-09-01
- State: DONE (khung) — chờ việc tiếp theo
- Việc dở và bằng chứng mới nhất: không còn việc dở của COMPLETION-PLAN. Bằng chứng: `scripts/check-docs-consistency.sh`
  PASS (chạy lại 2026-09-01); nghiệm thu Pha 4 trong `docs/ops/COMPLETION-PLAN.md` (5 cổng PASS, 22/22 việc ✅).
- Bước tiếp theo: không có; chờ người dùng chọn hướng kế tiếp (dự án đích mới hoặc audit định kỳ).
- Quyền/quyết định cần thêm: không.
