# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — Khung đã hoàn thiện, đang thực thi 2 spec nâng cấp thêm (traps/codemap/cổng CI, golden+TDD)
- Default-branch SHA đã đối chiếu: `d0baf40` (`origin/main`, PR #61 đã merge; nhánh làm việc `claude/quirky-dijkstra-qahpgw` hiện trước `main` 3 commit chưa PR)
- Ngày cập nhật: 2026-09-12

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Gói A+B+C: TRAPS + CODEMAP + cổng CI | 4 PR merge; TRAPS/CODEMAP thật + cổng `check-ci-policy.sh` chạy trong CI | 🔵 Đang làm — PR-1, PR-2 xong (chưa PR/merge lên `main`, đang trên nhánh làm việc) | PR-3 (CODEMAP), PR-4 (dropins vitest) chưa làm | PR-3: `CODEMAP.template.md` + `CODEMAP.md` thật + nối `/completion` | `docs/specs/2026-09-12-traps-codemap-ci-policy.md` |
| Golden test + kỷ luật TDD | 3 PR merge; TDD lên cấp CLAUDE.md/gate, golden có luật cập nhật | ⚪ Approved, chưa bắt đầu | Chưa làm PR-A | PR-A: CLAUDE.md §3.6/§5/§7 + AGENTS.md + `/gate` + `/debug` | `docs/specs/2026-09-12-golden-tests-and-tdd.md` |
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

- Thực thi 2 spec đã Approved for implementation (2026-09-12): `docs/specs/2026-09-12-traps-codemap-ci-policy.md`
  (PR-1 `check-ci-policy.sh` ✅, PR-2 `TRAPS.md` ✅ — cả hai đã push lên nhánh làm việc, CHƯA mở PR/merge
  lên `main`) và `docs/specs/2026-09-12-golden-tests-and-tdd.md` (chưa bắt đầu).
- `docs/ops/COMPLETION-PLAN.md` (đợt trước) vẫn đóng, không liên quan 2 goal mới này.

## Tiếp theo

- PR-3 (CODEMAP.template.md + CODEMAP.md thật + nối `/completion`), rồi PR-4 (dropins vitest tương
  đương `check-ci-policy.sh`) của spec traps-codemap-ci-policy.
- Sau đó 3 PR của spec golden-tests-and-tdd (PR-A TDD → PR-B golden tài liệu → PR-C golden cơ chế thật).
- Người dùng cần quyết: mở PR lên `main` cho các commit đã làm, hay tiếp tục dồn hết vào nhánh làm
  việc rồi mở một PR tổng ở cuối.

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
- State: IN PROGRESS — 2/4 PR của spec traps-codemap-ci-policy xong (trên nhánh làm việc, chưa PR/merge)
- Việc dở và bằng chứng mới nhất: PR-1 (`scripts/check-ci-policy.sh` + `docs/ops/repository-settings.md`
  mục "Required checks — nguồn sự thật") và PR-2 (`TRAPS.md` 6 mục có thật + `TRAPS.template.md` +
  nối `/debug`/`CLAUDE.md`/`AGENTS.md`) đã commit + push lên `claude/quirky-dijkstra-qahpgw`. Bằng chứng:
  `check-docs-consistency.sh` ✅, `check-ci-policy.sh` ✅ (kèm negative test), `test-copy-framework.sh` ✅
  (chạy lại 2026-09-12, kèm xác minh thật bằng copy tay vào scratch).
- Bước tiếp theo: PR-3 (CODEMAP), PR-4 (dropins), rồi 3 PR của spec golden-tests-and-tdd.
- Quyền/quyết định cần thêm: có nên mở PR lên `main` ngay cho PR-1/PR-2, hay dồn hết rồi mở một lần?
