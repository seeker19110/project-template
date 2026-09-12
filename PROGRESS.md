# PROGRESS.md — Trạng thái dự án

> Tóm tắt toàn dự án; cập nhật sau mỗi mốc. Goal nhiều PR theo dõi chi tiết ở `docs/goals/*`.
> Không sao chép iteration log vào đây. (Repo này LÀ bộ khung — file này là nhật ký của chính khung,
> không copy sang dự án đích; dự án đích nhận bản sạch từ `PROGRESS.template.md`.)

## Giai đoạn hiện tại

- Giai đoạn: GĐ 8. PR #69/#70 (hàng rào `progress-freshness` + quy trình chia PR/effort/auto-merge)
  đã merge. Sau đó chạy `/audit-full` reset (PR #71): 0 Cao, 4 Trung (G-001..G-004). G-001 (thiếu
  negative-test cho 3 gate chính) đã sửa qua PR #72. Đang trên nhánh
  `feat/branch-protection-ruleset-guard` (chưa mở PR): mượn cơ chế auto-merge/branch-protection từ
  repo `seeker19110/Claude-Agents` — ruleset import được (`.github/rulesets/main.json`) + job CI
  `protection-guard` đối chiếu hai chiều rule khai báo ↔ rule thật trên GitHub (thay `gộp về 2 tên`
  bằng cơ chế kiểm chứng tự động, không còn "lời hứa" trong tài liệu); cũng cập nhật CLAUDE.md §8 để
  dùng auto-merge gốc của GitHub thay vì tự canh CI rồi gọi merge tay.
- Default-branch SHA đã đối chiếu: `4d89105` (`origin/main`, PR #72)
- Nhánh đang làm: `feat/branch-protection-ruleset-guard`
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
- **(2026-09-12) PR #69 — cổng chống PROGRESS.md lỗi thời + chia đơn vị PR/trần effort medium/
  auto-merge**: `scripts/check-progress-freshness.sh` + job CI `progress-freshness`; quy trình mới
  sau bước duyệt kế hoạch cho việc đủ lớn cần điều phối 3 tầng — xem `TRAPS.md` mục 8.
- PR đã merge gần nhất: **#69** (freshness gate + PR-splitting/effort/auto-merge), **#68** (tổng quát hoá harness), **#67** (ADR-0004 gỡ scaffold Web), **#66**
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

- **Ngay lập tức:** mở PR cho nhánh `feat/branch-protection-ruleset-guard`, đăng ký theo dõi, merge
  khi CI xanh — sau đó **import `.github/rulesets/main.json` trên GitHub Settings → Rules →
  Rulesets** (chỉ chủ repo làm được) để `protection-guard` thật sự có gì để đối chiếu.
- Còn 3 phát hiện Trung từ audit toàn diện chưa xử lý: G-002 (PROGRESS.md risk table dependabot lỗi
  thời — đã dọn trong đợt sửa này), G-003 (dòng sơ đồ ASCII `orchestration-3-tier.md` còn "Opus·high"),
  G-004 (effort/model lặp 6 nơi không cổng đối chiếu).
- Có thể làm khi được yêu cầu: bắt đầu dự án đích mới bằng khung này (`/consult` hoặc `/auto`), tiếp
  tục quét thêm repo dẫn xuất khác (gói D–I của lượt quét 2026-09-12: script `check-*` của `xboss`,
  hook `block-dangerous-git.sh`, gitleaks pre-commit, gate-agent `sc-gate-*`, `eval-record.yml`),
  hoặc audit định kỳ khác (`/audit-full`). Ngoài ra vẫn còn tồn đọng chờ người dùng ở mục "Rủi ro"
  bên dưới (xoá 31 nhánh, import ruleset `.github/rulesets/main.json`).

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
| ~~5 PR dependabot chưa merge~~ | — | — | ➖ Lỗi thời (G-002, audit 2026-09-12) — #53→#57 đã merge từ trước, `list_pull_requests(state=open)` xác nhận 0 PR đang mở | `docs/ops/COMPLETION-PLAN.md` W-101 |
| Case-study Bước 6–8 (branch protection/Supabase/Vercel) chưa kiểm chứng | Thấp | Người dùng | Kiểm khi áp khung vào dự án thật có tài khoản | `docs/framework/case-study-greenfield-dry-run.md` |
| 31 nhánh đã merge còn tồn trên remote (F-014) | Thấp | Người dùng | Xoá qua GitHub UI hoặc cấp quyền Bash cho `git push --delete` — danh sách đủ ở `docs/ops/repository-settings.md` | `docs/ops/COMPLETION-PLAN.md` W-308 |
| Ruleset `.github/rulesets/main.json` chưa import trên GitHub | Vừa | Người dùng | Import: Settings → Rules → Rulesets → New ruleset → Import a ruleset — job CI `protection-guard` đỏ tới khi làm (CỐ Ý chưa nằm trong `needs:` của `gate` để tránh deadlock — xem `CP4_BOOTSTRAP_EXEMPT` ở `check-ci-policy.sh`). Sau khi import + job xanh: mở PR thêm `protection-guard` vào `needs:` của `gate` + xoá khỏi allowlist đó | `docs/ops/repository-settings.md` |
| G-003 (`orchestration-3-tier.md` dòng sơ đồ ASCII còn "Opus·high") | Vừa | AI | Chưa sửa — 1 dòng, cùng gốc với G-004 | `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md` |
| G-004 (effort/model lặp 6 file, không cổng đối chiếu) | Vừa | AI | Chưa sửa — cần thêm 1 kiểm vào `check-docs-consistency.sh` hoặc gộp về 1 nguồn | `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md` |
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
- Cùng phiên, người dùng yêu cầu thêm bước: sau khi duyệt kế hoạch, việc đủ lớn cần điều phối thì
  chia đơn vị PR (song song/tuần tự theo phụ thuộc) + trần effort medium cho mọi worker (kể cả
  `route:complex`, trước là Opus·high) + mỗi đơn vị mở PR riêng + bật auto-merge khi cổng xanh —
  viết nguyên tắc chung ở `AGENTS.md` (dùng chung mọi nhà cung cấp AI), bản triển khai Claude Code ở
  `orchestration-3-tier.md` + `.claude/agents/{coordinator,complex-implementer}.md` + `auto.md`.
- **Đã mở PR #69**, tiêu đề ban đầu `feat:` bị `pr-policy.yml` chặn (đúng thiết kế — feat phải link
  spec Approved, đây là framework meta nên không có) → đổi tiêu đề/checkbox sang `chore:` → CI xanh
  hết (`gate`, `docs-consistency`, `framework-lint`, `copy-framework-smoke`, `metadata`, `gitleaks`,
  `dependency-review`; `progress-freshness` skip đúng vì đây là PR chưa push vào `main`) → **đã
  merge (squash, SHA `9ab8f4e`)** → đã quay về `main`, fast-forward sạch.
- Việc CHƯA xong + lý do: chưa có — phiên này đã đóng trọn vẹn (spec → code → gate → PR → CI xanh →
  merge → quay về main → cập nhật PROGRESS.md). Có thể cân nhắc sau: thêm mục TRAPS.md riêng cho
  bài học "PR title `feat:` kích hoạt yêu cầu spec dù không phải feature dự án đích" nếu tái phát.
- Bước tiếp theo: không có, chờ yêu cầu người dùng.
- Quyền/quyết định cần thêm: không có gì mới ngoài các mục tồn đọng cũ (xoá 31 nhánh, đổi branch
  protection sang khoá `gate`, merge PR dependabot).
