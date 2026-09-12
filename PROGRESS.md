# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — audit toàn diện 2026-09-12 đã qua Pha 3; đợt "siết hàng rào" đã vào `main`;
  Nhóm 11 (audit) đã quét xong, chỉ còn W-303/W-306/W-308 mở
- Default-branch SHA đã đối chiếu: `b6d66ef` (`origin/main`, PR #65)
- Nhánh đang làm: `claude/admiring-clarke-mq767f` (tiếp tục audit toàn diện: Nhóm 11 + rà 5 việc treo)
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
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |
| 31 nhánh đã merge còn tồn trên remote (F-014) | Thấp | Người dùng | Xoá qua GitHub UI hoặc cấp quyền Bash cho `git push --delete` — danh sách đủ ở `docs/ops/repository-settings.md` | `docs/ops/COMPLETION-PLAN.md` W-308 |
| W-303 test RLS "vượt quyền" chưa viết | Thấp | AI | Cần môi trường có Supabase local (`supabase start`) — không có trong phiên hiện tại | `docs/ops/COMPLETION-PLAN.md` W-303 |

## Bàn giao phiên

- Lần cập nhật: 2026-09-12 (phiên tiếp theo — audit định kỳ)
- State: DONE một phần — chạy `/audit-full` theo lựa chọn "Tiếp tục" của người dùng (không quét lại
  từ đầu, chỉ hoàn tất phần dở). 2 việc xong hẳn (Nhóm 11, tra cứu W-308), 1 việc bị chặn quyền
  (xoá nhánh), 2 việc vẫn treo vì thiếu môi trường (W-303) hoặc phụ thuộc việc khác (W-306).
- Việc đã xong và bằng chứng: (1) Nhóm 11 — đọc `.env.example` + `lib/env.ts`, đối chiếu từng biến,
  0 phát hiện mới, cập nhật `COMPREHENSIVE-AUDIT-STATUS.md` + `COMPLETION-PLAN.md` (W-310 ✅).
  (2) W-308 — tra cứu 61 PR qua `mcp__github__list_pull_requests`, xác nhận 31/32 nhánh có
  `merged_at` thật, 1 nhánh (PR #28) closed không merge; danh sách đầy đủ ghi vào
  `docs/ops/repository-settings.md`. Cổng đã chạy lại: `check-docs-consistency.sh` ✅,
  `check-ci-policy.sh` ✅ (chỉ sửa tài liệu, không đổi code/CI nên không cần chạy build/test/lint).
- Việc CHƯA xong + lý do: W-308 xoá nhánh thật — bị auto-mode classifier chặn `git push --delete`
  (destructive git), cần người dùng tự xoá hoặc cấp quyền Bash. W-303 (test RLS vượt quyền) — cần
  Supabase local, không có trong môi trường phiên này. W-306 (đồng bộ PROGRESS.md cuối lượt) — đã
  cập nhật một phần ngay trong phiên này, sẽ hoàn tất khi W-303/W-308 đóng.
- Bước tiếp theo: chờ người dùng xoá 31 nhánh (hoặc cấp quyền), rồi chờ hướng kế tiếp (dự án đích
  mới, quét thêm gói D–I, hoặc audit định kỳ khác).
- Quyền/quyết định cần thêm: quyền Bash cho `git push --delete` (nếu muốn AI tự xoá nhánh thay vì
  người dùng làm thủ công qua GitHub UI).
