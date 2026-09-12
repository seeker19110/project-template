# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — audit toàn diện lượt 2026-09-12 xong (Pha 0→3); đang chờ merge đợt "siết hàng rào"
- Default-branch SHA đã đối chiếu: `772c949` (`origin/main`, PR #63)
- Nhánh đang làm: `claude/khung-du-an-mau-upgrade-7aw7n1` @ `0f9d47d` (chưa có PR)
- Ngày cập nhật: 2026-09-12

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Gói A+B+C: TRAPS + CODEMAP + cổng CI | 4 PR merge; TRAPS/CODEMAP thật + cổng `check-ci-policy.sh` chạy trong CI | ✅ ĐÓNG (2026-09-12, PR #62) | — | Không còn goal mở | `docs/specs/2026-09-12-traps-codemap-ci-policy.md` |
| Siết hàng rào (audit 2026-09-12) | 0 phát hiện Cao mở; luật có cơ chế thi hành | 🔄 MỞ | W-101 chặn bởi W-106 (cần merge vào `main`) | Mở PR → merge → merge 5 PR dependabot FIFO | `docs/ops/COMPLETION-PLAN.md` |
| Golden test + kỷ luật TDD | 3 PR merge; TDD lên cấp CLAUDE.md/gate, golden có luật cập nhật | ✅ ĐÓNG (2026-09-12, PR #62) | — | Không còn goal mở | `docs/specs/2026-09-12-golden-tests-and-tdd.md` |
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
- PR đã merge gần nhất: **#62** (TRAPS.md + CODEMAP.md + `check-ci-policy.sh` + golden test/TDD —
  2 spec `docs/specs/2026-09-12-*.md`, 7 PR gộp thành 1, rút từ lượt quét 15 repo dẫn xuất/lân cận),
  **#61** (verify-dropins ERESOLVE), **#52** (hoàn thiện khung theo COMPLETION-PLAN, 4 đợt/22 việc
  W-101→W-406, Pha 4 re-audit hội tụ + nghiệm thu Definition of Complete PASS), **#46** (parallel
  subagent workflow), **#45** (governance & supply-chain), **#44** (hợp nhất chuẩn —
  standard-delivery). Mốc cũ hơn (#19–#32…): xem lịch sử Git của file này + CHANGELOG.

## Đang làm / chờ

- **Kế hoạch hoàn thiện lượt 2026-09-12 đang MỞ:** `docs/ops/COMPLETION-PLAN.md` — 13/22 việc ✅
  (cả 2 phát hiện Cao đã xử lý), 1 việc 🔄 BLOCKED, 8 việc ⬜ có lý do hoãn ghi rõ.
- **Chờ người dùng:** (a) mở PR cho nhánh trên — bắt buộc để W-106 (`pr-policy.yml` miễn trừ bot)
  tới được `main`, vì 5 PR dependabot không thể merge trước khi nó có hiệu lực; (b) xác nhận xoá
  ~32 nhánh đã merge (W-308); (c) chọn cơ chế cho W-105 (phát hiện PR đọng).
- **Gấp:** GitHub xoá Node 20 khỏi runner **16/09/2026** → 5 PR dependabot phải merge trước đó.

## Tiếp theo

- Chờ yêu cầu tiếp theo của người dùng: bắt đầu dự án đích mới bằng khung này (`/consult` hoặc
  `/auto`), tiếp tục quét thêm repo dẫn xuất khác (gói D–I của lượt quét 2026-09-12: script `check-*`
  của `xboss`, hook `block-dangerous-git.sh`, gitleaks pre-commit, gate-agent `sc-gate-*`,
  `eval-record.yml`), hoặc audit định kỳ khác (`/audit-full`).

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
| 5 PR dependabot chưa merge (3 major công cụ bảo mật) | **Cao** | Người dùng | Mở PR cho nhánh hiện tại → merge → merge #53→#57 FIFO trước 16/09 | `docs/ops/COMPLETION-PLAN.md` W-101 |
| Nhóm 11 audit chưa quét xong (`.env.example`) | Thấp | AI | Chạy lại ở phiên có quyền đọc `.env*` | `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md` W-310 |
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |

## Bàn giao phiên

- Lần cập nhật: 2026-09-12
- State: DONE — cả 2 spec đã merge vào `main` qua **PR #62** (squash, 13/13 check xanh, không
  review comment/conflict, `mergeable_state: clean`). Đã unsubscribe PR, quay về `main`
  (`a6601b7`), pull cập nhật local.
- Việc đã xong và bằng chứng: PR-1..4 (`check-ci-policy.sh`, `TRAPS.md`, `CODEMAP.md`,
  `ci-workflow-policy.test.ts` dropins) + PR-A..C (TDD bắt buộc cho bugfix lên `CLAUDE.md`/`gate`;
  golden test tài liệu + `GOLDEN-TEST.template.md`; golden test cơ chế thật + ví dụ
  `lib/order-summary.ts` trong dropins). Bằng chứng: `check-docs-consistency.sh` ✅,
  `check-ci-policy.sh` ✅, `test-copy-framework.sh` ✅ (mọi assertion mới đều kèm negative test);
  `verify-dropins.sh` chạy đủ 6/6 bước trên Next.js 16.3.5 sạch nhiều lượt, lần cuối 15/15 test pass
  (13 `ci-workflow-policy.test.ts` + 2 golden mới); CI thật trên PR #62 xanh toàn bộ 13 check.
  Một sai sót tự phát hiện và tự sửa giữa đường: PR-B ghi nhầm Vitest có cờ `--ci`; PR-C xác minh
  thật (Vitest 5 không có cờ đó, cơ chế đúng là biến môi trường `CI`) và sửa lại trước khi merge.
- Bước tiếp theo: không có; chờ người dùng chọn hướng kế tiếp (dự án đích mới, quét thêm gói D–I, hoặc audit định kỳ).
- Quyền/quyết định cần thêm: không.
