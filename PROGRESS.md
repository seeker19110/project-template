# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — Khung đã hoàn thiện; 2 spec nâng cấp (traps/codemap/cổng CI, golden+TDD) đã code xong 7/7 PR, đã mở PR tổng #62 lên `main`, đang chờ CI
- Default-branch SHA đã đối chiếu: `d0baf40` (`origin/main`, PR #61 đã merge; PR #62 mở từ `claude/quirky-dijkstra-qahpgw`, 10 commit, đang chờ CI)
- Ngày cập nhật: 2026-09-12

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Gói A+B+C: TRAPS + CODEMAP + cổng CI | 4 PR merge; TRAPS/CODEMAP thật + cổng `check-ci-policy.sh` chạy trong CI | 🔵 4/4 PR code xong, gộp vào PR #62 chờ CI | Chờ CI PR #62 rồi merge | Theo dõi CI, squash merge | `docs/specs/2026-09-12-traps-codemap-ci-policy.md` |
| Golden test + kỷ luật TDD | 3 PR merge; TDD lên cấp CLAUDE.md/gate, golden có luật cập nhật | 🔵 3/3 PR code xong, gộp vào PR #62 chờ CI | Chờ CI PR #62 rồi merge | Theo dõi CI, squash merge | `docs/specs/2026-09-12-golden-tests-and-tdd.md` |
| Hoàn thiện khung theo COMPLETION-PLAN | 0 phát hiện Cao mở; Vừa/Thấp có kết cục ghi nhận; đạt Definition of Complete | ✅ ĐÓNG (2026-09-01) | — | Không còn goal mở | `docs/ops/COMPLETION-PLAN.md` |

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

- Cả 2 spec đã Approved for implementation (2026-09-12) **XONG toàn bộ code** (7/7 PR), gộp vào
  **PR #62** (https://github.com/seeker19110/project-template/pull/62), đã `subscribe_pr_activity`.
  Còn duy nhất: **chờ CI xanh, squash merge**.
- `docs/ops/COMPLETION-PLAN.md` (đợt trước) vẫn đóng, không liên quan 2 goal này.

## Tiếp theo

- Theo dõi CI của PR #62, sửa nếu đỏ (đúng quy trình PR→merge tự động, CLAUDE.md §8), squash merge
  khi xanh, rồi quay về `main`.

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

- Lần cập nhật: 2026-09-12
- State: IN PROGRESS — cả 2 spec XONG code (7/7 PR: 4 của traps-codemap-ci-policy + 3 của
  golden-tests-and-tdd), gộp vào PR #62 lên `main`, đã subscribe, đang chờ CI.
- Việc dở và bằng chứng mới nhất: PR-1..4 (check-ci-policy.sh, TRAPS.md, CODEMAP.md,
  ci-workflow-policy.test.ts dropins) + PR-A..C (TDD bắt buộc cho bugfix lên CLAUDE.md/`gate`;
  golden test tài liệu + `GOLDEN-TEST.template.md`; golden test cơ chế thật + ví dụ
  `lib/order-summary.ts` trong dropins) — đều đã commit + push lên `claude/quirky-dijkstra-qahpgw`.
  Bằng chứng: `check-docs-consistency.sh` ✅, `check-ci-policy.sh` ✅, `test-copy-framework.sh` ✅
  (mọi assertion mới đều kèm negative test); `verify-dropins.sh` chạy đủ 6/6 bước trên Next.js
  16.3.5 sạch nhiều lượt, lần cuối 15/15 test pass (13 `ci-workflow-policy.test.ts` + 2 golden mới).
  Một sai sót tự phát hiện và tự sửa giữa đường: PR-B ghi nhầm Vitest có cờ `--ci`; PR-C xác minh
  thật (Vitest 5 không có cờ đó, cơ chế đúng là biến môi trường `CI`) và sửa lại.
- Bước tiếp theo: theo dõi CI của PR #62 (https://github.com/seeker19110/project-template/pull/62), squash merge khi xanh.
- Quyền/quyết định cần thêm: không.
