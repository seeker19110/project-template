# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — audit toàn diện 2026-09-12 đã đóng (Nhóm 11 xong qua PR #66); **quyết định kiến
  trúc lớn mới cùng ngày: gỡ hẳn scaffold Web mặc định khỏi repo khung (ADR-0004)**, đang hoàn thiện
  trên nhánh riêng trước khi mở PR
- Default-branch SHA đã đối chiếu: `66840fe` (`origin/main`, PR #66)
- Nhánh đang làm: `claude/remove-web-scaffold-layer2` (ADR-0004 — xoá scaffold Next.js/Supabase, sửa
  `ci.yml`/`copy-framework.sh`/`.ps1`, cập nhật tài liệu tham chiếu)
- Ngày cập nhật: 2026-09-12

## Goal đang active

| Goal | Outcome | State | Current gap | Next slice | Link |
| --- | --- | --- | --- | --- | --- |
| Gói A+B+C: TRAPS + CODEMAP + cổng CI | 4 PR merge; TRAPS/CODEMAP thật + cổng `check-ci-policy.sh` chạy trong CI | ✅ ĐÓNG (2026-09-12, PR #62) | — | Không còn goal mở | `docs/specs/2026-09-12-traps-codemap-ci-policy.md` |
| Siết hàng rào (audit 2026-09-12) | 0 phát hiện Cao mở; luật có cơ chế thi hành | 🔄 MỞ | Còn 3 việc: W-303 (cần Supabase local — không có trong môi trường phiên), W-306 (chờ W-303/W-308 xong mới tổng hợp), W-308 (đã tra cứu xong 31 nhánh merged thật — **bị auto-mode chặn `git push --delete`**, cần người dùng tự xoá hoặc cấp quyền Bash) | W-308: người dùng xoá 31 nhánh liệt kê ở `docs/ops/repository-settings.md`, hoặc cấp quyền để AI chạy `git push --delete` | `docs/ops/COMPLETION-PLAN.md` |
| Golden test + kỷ luật TDD | 3 PR merge; TDD lên cấp CLAUDE.md/gate, golden có luật cập nhật | ✅ ĐÓNG (2026-09-12, PR #62) | — | Không còn goal mở | `docs/specs/2026-09-12-golden-tests-and-tdd.md` |
| Hoàn thiện khung theo COMPLETION-PLAN | 0 phát hiện Cao mở; Vừa/Thấp có kết cục ghi nhận; đạt Definition of Complete | ✅ ĐÓNG (2026-09-01) | — | Không còn goal mở | `docs/ops/COMPLETION-PLAN.md` |

## Đã xong (tóm tắt)

- Dựng trọn bộ khung: quy trình 9 giai đoạn + cổng, luật AI (CLAUDE.md/AGENTS.md), research-first,
  slash commands (`/consult` `/gate` `/bootstrap` `/auto` `/audit-full` `/audit-optimize` `/incident`
  `/completion` `/grill` `/debug` `/ui-ux` `/adr`), điều phối 3 tầng + opusplan, `copy-framework.sh`/
  `.ps1` + smoke test, OpenSpec (tùy chọn).
- **(2026-09-12, ADR-0004) Gỡ hẳn scaffold Web mặc định** — repo khung giờ chỉ còn Lớp 1 (phương
  pháp) + Lớp 2 (CI/quy ước GitHub tổng quát). Xem "Quyết định quan trọng" bên dưới.
- Hàng rào tự kiểm cho chính khung: CI `framework-lint` / `docs-consistency`
  (`scripts/check-docs-consistency.sh`) / `copy-framework-smoke`; case-study greenfield (lịch sử,
  chạy khi repo còn scaffold — xem `case-study-greenfield-dry-run.md`).
- Tái cấu trúc tên file sang tiếng Anh (nội dung tiếng Việt), bản đồ tên cũ→mới ở `docs/framework/README.md`.
- PR đã merge gần nhất: **#62** (TRAPS.md + CODEMAP.md + `check-ci-policy.sh` + golden test/TDD —
  2 spec `docs/specs/2026-09-12-*.md`, 7 PR gộp thành 1, rút từ lượt quét 15 repo dẫn xuất/lân cận),
  **#61** (verify-dropins ERESOLVE), **#52** (hoàn thiện khung theo COMPLETION-PLAN, 4 đợt/22 việc
  W-101→W-406, Pha 4 re-audit hội tụ + nghiệm thu Definition of Complete PASS), **#46** (parallel
  subagent workflow), **#45** (governance & supply-chain), **#44** (hợp nhất chuẩn —
  standard-delivery). Mốc cũ hơn (#19–#32…): xem lịch sử Git của file này + CHANGELOG.

## Đang làm / chờ

- **Kế hoạch hoàn thiện lượt 2026-09-12 đang MỞ:** `docs/ops/COMPLETION-PLAN.md` — 20/23 việc ✅
  (cả 2 phát hiện Cao đã đóng; W-310 vừa đóng thêm), 3 việc còn lại đều có lý do hoãn ghi rõ.
- **Audit toàn diện — Nhóm 11 đã quét xong:** `.env.example` ↔ `lib/env.ts` khớp hoàn toàn, 0 phát
  hiện mới. `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md` nay đủ 12/12 nhóm có kết cục (10 ✅, 2 ➖ N/A).
- **W-308 (xoá nhánh merge) đã tra cứu xong** qua GitHub API: 31/32 nhánh có PR `merged_at` thật,
  1 nhánh (PR #28) closed không merge → giữ lại. **Bị chặn xoá:** auto-mode classifier từ chối
  `git push --delete` (destructive git) — danh sách đầy đủ + cách xoá thủ công ở
  `docs/ops/repository-settings.md`.
- **Chờ người dùng:** (a) tự xoá 31 nhánh đã merge (W-308) qua GitHub UI, hoặc cấp quyền Bash cho
  `git push --delete`; (b) **chuyển branch protection sang khoá đúng 1 tên `gate`** thay vì 7 tên
  job (ADR-0003, `docs/ops/repository-settings.md`) — chỉ chủ repo làm được trên GitHub Settings.

## Tiếp theo

- **Ngay lập tức:** mở PR cho nhánh `claude/remove-web-scaffold-layer2` (ADR-0004 — gỡ scaffold
  Web), đăng ký theo dõi, merge khi CI xanh.
- Sau đó: chờ yêu cầu tiếp theo của người dùng — bắt đầu dự án đích mới bằng khung này (`/consult`
  hoặc `/auto`), tiếp tục quét thêm repo dẫn xuất khác (gói D–I của lượt quét 2026-09-12: script
  `check-*` của `xboss`, hook `block-dangerous-git.sh`, gitleaks pre-commit, gate-agent `sc-gate-*`,
  `eval-record.yml`), hoặc audit định kỳ khác (`/audit-full`).

## Quyết định quan trọng

- **opusplan là điểm ngọt, không đổi** — tối ưu token bằng CHIA VIỆC (subagent, cô lập ngữ cảnh),
  không "route theo độ khó". Chi tiết: `docs/framework/models-and-automation.md`.
- **(ĐẢO NGƯỢC 2026-09-12, ADR-0004) KHÔNG còn scaffold Web mặc định.** Quyết định cũ "giữ scaffold
  Web (Next.js+Supabase) làm hồ sơ mặc định" đã bị đảo ngược theo yêu cầu người dùng — gỡ hẳn khỏi
  repo khung để nhất quán với nguyên tắc "hỗ trợ mọi loại dự án, research-first" (không sửa ADR-0001
  — ghi ADR mới). Repo khung giờ chỉ còn Lớp 1 (phương pháp) + Lớp 2 (CI/quy ước GitHub tổng quát,
  không đặc thù stack).
- Copy-framework KHÔNG đè file có sẵn ở dự án đích (`copy_if_absent`); Lớp 2 (CI/GitHub) vào `_framework-dropins/`.
- ADR: `docs/adr/` (vd `0001-stack-selection.md`, `0004-remove-default-web-scaffold.md`).

## Rủi ro, blocker và nợ kỹ thuật

| Mục | Severity | Owner | Trigger/next action | Link |
| --- | --- | --- | --- | --- |
| F-011 `--theme-transition` dead token | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| F-014 usage-guard số thập phân | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| F-309 `dev-task.sh` fallback grep | Thấp | AI | **Chấp nhận rủi ro (xác nhận 2026-09-01)** — không sửa | `docs/ops/COMPLETION-PLAN.md` |
| 5 PR dependabot chưa merge (3 major công cụ bảo mật) | **Cao** | Người dùng | Mở PR cho nhánh hiện tại → merge → merge #53→#57 FIFO trước 16/09 | `docs/ops/COMPLETION-PLAN.md` W-101 |
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |
| 31 nhánh đã merge còn tồn trên remote (F-014) | Thấp | Người dùng | Xoá qua GitHub UI hoặc cấp quyền Bash cho `git push --delete` — danh sách đủ ở `docs/ops/repository-settings.md` | `docs/ops/COMPLETION-PLAN.md` W-308 |
| ~~W-303 test RLS~~ | — | — | ➖ Hết hiệu lực (ADR-0004) — dropins Supabase đã gỡ, không còn gì để test | `docs/ops/COMPLETION-PLAN.md` W-303 |

## Bàn giao phiên

- Lần cập nhật: 2026-09-12 (phiên tiếp theo — audit định kỳ → quyết định kiến trúc lớn giữa phiên)
- State: DONE một phần, đang xử lý PR mới — phiên bắt đầu bằng `/audit-full` (đóng Nhóm 11, tra cứu
  W-308, merge PR #66), rồi người dùng yêu cầu **gỡ hẳn scaffold Web mặc định** khỏi repo khung
  ("loại bỏ tất cả những cái không phải khung, harness để phát triển dự án") — đã xác nhận qua
  `AskUserQuestion` (đảo ngược quyết định cũ, ghi ADR-0004) trước khi xoá.
- Việc đã xong và bằng chứng (đợt audit, PR #66 đã merge): Nhóm 11 đối chiếu `.env.example` ↔
  `lib/env.ts` (0 phát hiện mới); W-308 tra cứu 61 PR qua GitHub API, xác nhận 31/32 nhánh merged
  thật, danh sách ghi vào `repository-settings.md`.
- Việc đã xong (đợt gỡ scaffold, nhánh `claude/remove-web-scaffold-layer2`, CHƯA merge): xoá 38 file
  (`app/`, `lib/`, `styles/`, `e2e/`, `i18n/`, `messages/`, `components/`, `supabase/`, config
  ESLint/Prettier/Vitest/Playwright/Lighthouse/commitlint, `.husky/`, `.env.example`, 3 workflow
  Web-specific, `scripts/verify-dropins.sh`); sửa `ci.yml` (bỏ job `quality`/`source-hygiene`/`e2e`,
  còn 3 job tự kiểm + `gate`), `copy-framework.sh`/`.ps1` (Lớp 2 chỉ còn CI/GitHub tổng quát, đã đối
  chiếu khớp nhau bằng `diff`), viết ADR-0004, cập nhật README/SECURITY/CLAUDE.md/CODEMAP.md/
  FEATURE-MAP.md/existing-project-adoption.md/quality-supplements.md/repository-settings.md/
  CHANGELOG.md; đóng W-303 (hết hiệu lực — không còn RLS mẫu để test). Bằng chứng: `check-docs-
  consistency.sh` ✅, `check-ci-policy.sh` ✅, `test-hooks-gate.sh` ✅ (toàn bộ ca xanh),
  `test-copy-framework.sh` ✅ (bản `.sh`; bản `.ps1` đối chiếu bằng `diff` khớp tuyệt đối, chưa chạy
  được `pwsh` local — sẽ chạy thật ở CI job `copy-framework-smoke`).
- Việc CHƯA xong + lý do: PR cho nhánh `remove-web-scaffold-layer2` chưa mở (làm ở bước kế tiếp
  ngay sau khi ghi file này). W-306 (đồng bộ PROGRESS.md cuối lượt "Siết hàng rào") vẫn chờ W-308
  (xoá nhánh thật — bị auto-mode chặn `git push --delete`, cần người dùng tự xoá qua GitHub UI hoặc
  cấp quyền Bash).
- Bước tiếp theo: mở PR cho `remove-web-scaffold-layer2`, theo dõi tới khi CI xanh (đặc biệt job
  `copy-framework-smoke` — lần đầu tiên `.ps1` được kiểm thật sau khi sửa), merge, rồi chờ người
  dùng xoá 31 nhánh hoặc cấp quyền.
- Quyền/quyết định cần thêm: quyền Bash cho `git push --delete` (nếu muốn AI tự xoá nhánh thay vì
  người dùng làm thủ công qua GitHub UI).
