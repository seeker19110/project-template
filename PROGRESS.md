# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8 — ADR-0004 (gỡ scaffold Web mặc định) đã merge qua PR #67; tiếp đó PR #68 tổng
  quát hoá harness cho mọi AI coding model/provider (AGENTS.md làm entrypoint chung, bridge file
  cho Gemini/Cline/Windsurf/Cursor/Copilot, subagent `tester`+`security-reviewer`) cũng đã merge.
  Đang bổ sung hàng rào chống lỗi thời cho chính `PROGRESS.md` (script `check-progress-freshness.sh`
  + job CI `progress-freshness`) sau khi phát hiện file này bị lỗi thời một lượt (xem "Rủi ro" bên dưới).
- Default-branch SHA đã đối chiếu: `08bcc84` (`origin/main`, PR #68)
- Nhánh đang làm: `main` (đang sửa trực tiếp, sẽ commit qua PR mới cho hàng rào freshness)
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
- **(2026-09-12) PR #68 — tổng quát hoá harness cho mọi AI coding model/provider**: AGENTS.md
  thành entrypoint chung có hàng rào an toàn thủ công cho agent không có hook Claude Code;
  `.mcp.json.example` + `.claude/settings.local.json.example`; bridge file GEMINI.md/.clinerules/
  .windsurfrules/Cursor/Copilot trỏ về AGENTS.md; thêm subagent `tester` + `security-reviewer`.
- PR đã merge gần nhất: **#68** (tổng quát hoá harness), **#67** (ADR-0004 gỡ scaffold Web), **#66**
  (đóng Nhóm 11 audit), **#62** (TRAPS.md + CODEMAP.md + `check-ci-policy.sh` + golden test/TDD —
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

- **Ngay lập tức:** mở PR cho hàng rào `progress-freshness` (script + job CI + cập nhật CLAUDE.md
  §8/CODEMAP.md/repository-settings.md), đăng ký theo dõi, merge khi CI xanh.
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
| ~~PROGRESS.md lỗi thời (nhánh đã merge #67 nhưng vẫn ghi "chưa mở PR")~~ | Vừa | AI | ✅ Đã sửa 2026-09-12 — thêm `scripts/check-progress-freshness.sh` + job CI `progress-freshness` chặn merge nếu tái phạm; xem `TRAPS.md` | `CLAUDE.md` §8, `CODEMAP.md` |

## Bàn giao phiên

- Lần cập nhật: 2026-09-12 (phiên mới — audit toàn diện phát hiện chính `PROGRESS.md` bị lỗi thời)
- State: DONE, đang mở PR — người dùng chạy `/audit-full`, bị chặn ở Bước -1 (repo khung, không phải
  dự án cụ thể) nên chuyển sang chạy 3 cổng tự kiểm của khung (đều xanh), rồi quét kỹ hơn thì phát
  hiện `PROGRESS.md` mô tả nhánh `claude/remove-web-scaffold-layer2` là "đang hoàn thiện, chưa mở
  PR" trong khi PR #67 (và cả #68 sau đó) **đã merge thật** — file lỗi thời hoàn toàn im lặng. Người
  dùng hỏi cách chặn tận gốc kiểu lỗi này → đề xuất + viết cổng tự động.
- Việc đã xong và bằng chứng:
  - `scripts/check-progress-freshness.sh` (PF-1: SHA đã đối chiếu phải là tổ tiên của HEAD; PF-2:
    nhánh nêu trong "Nhánh đang làm" phải còn tồn tại trên remote) — chạy thử đã **bắt đúng lỗi thật**
    (báo PF-2 đỏ với nhánh đã merge) trước khi sửa PROGRESS.md.
  - Wire vào `.github/workflows/ci.yml`: job `progress-freshness` (chỉ chạy khi push vào `main`,
    `fetch-depth: 0`), thêm vào `needs:` của `gate`.
  - Cập nhật `docs/ops/repository-settings.md` (thêm job vào bảng required checks — qua được
    `check-ci-policy.sh`), `CODEMAP.md` (hàng "Merge một PR xong, quay về main"), `CLAUDE.md` §8 +
    §10 (bắt buộc cập nhật `PROGRESS.md` ngay sau khi quay về `main`).
  - Sửa lại chính `PROGRESS.md` cho khớp thực tế (SHA `08bcc84`, nhánh `main`, PR #67/#68 ghi vào
    "Đã xong", mục Rủi ro ghi nhận lỗi này đã sửa).
  - Đã chạy lại `check-docs-consistency.sh` ✅, `check-ci-policy.sh` ✅, `test-copy-framework.sh` ✅,
    `test-hooks-gate.sh` ✅, `check-progress-freshness.sh` ✅ (sau khi sửa PROGRESS.md) — tất cả xanh.
- Việc CHƯA xong + lý do: chưa mở PR cho đợt sửa này (làm ngay sau khi ghi file); cân nhắc thêm mục
  vào `TRAPS.md` cho khuôn lỗi "tài liệu trạng thái lỗi thời sau merge" (chưa làm — có thể để phiên
  sau nếu tái phát).
- Bước tiếp theo: commit, mở PR, đăng ký theo dõi, merge khi CI xanh (đặc biệt xác nhận job mới
  `progress-freshness` chạy đúng — job này chỉ kích hoạt SAU khi merge vào `main` nên tự PR của nó
  sẽ hiện `skipped`, không phải bằng chứng job hoạt động; cần merge xong rồi xem lần push kế tiếp).
- Quyền/quyết định cần thêm: không có gì mới ngoài các mục tồn đọng cũ (xoá 31 nhánh, đổi branch
  protection sang khoá `gate`, merge PR dependabot).
