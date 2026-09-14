# Feature spec: Agent bảo trì toàn diện (`maintainer` + `/maintain` + engine `maintenance-sweep`)

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Yêu cầu người dùng (chat 2026-09-14): "một agent bảo trì toàn diện cho dự án này và dự án đích sau này" |
| Spec owner | Phiên AI (Claude Code) |
| State | **Approved for implementation** |
| Approver / date | Người dùng (chat — "hãy lên kế hoạch và triển khai") / 2026-09-14 |
| Last updated | 2026-09-14 |

> Không code khi chưa **Approved for implementation**.

## 1. Problem, user và evidence

Khung đã có cổng cho **từng thay đổi** (`/gate`, hook, CI) và audit **một lần** (`/audit-full`,
`/completion`), nhưng **không có gì đo thứ mục nát theo thời gian dù code không đổi**: dependency
lỗi thời/lỗ hổng, nhánh local đã merge còn sót, `PROGRESS.md` lỗi thời (TRAPS.md mục 8 — nguyên
nhân số một gây làm việc lặp), spec/goal treo, action CI chưa ghim SHA, bí mật lọt git, cổng khung
bắt đầu đỏ giữa hai đợt phát triển. Bằng chứng: PR #82 (auto-merge nuốt commit PROGRESS), F-001
(5 PR dependabot kẹt 19 ngày không ai thấy), F-003 (action tag di động lọt 13 action). Mỗi lần đều
phát hiện **tình cờ** bởi một audit thủ công, không bởi cơ chế định kỳ.

## 2. Outcome, baseline, target và guardrails

- **Outcome:** một vòng bảo trì lặp lại được, cùng một cách trên repo khung **và** mọi dự án đích
  (mọi stack), từ đo → triage → kế hoạch chờ duyệt → PR nhỏ qua `/gate` → quét lại hội tụ.
- **Baseline:** 0 cơ chế định kỳ; bảo trì phụ thuộc trí nhớ người dùng.
- **Target:** `maintenance-sweep.sh` chạy < 5 s (không dependency) trên repo khung; self-test có
  negative-test cài lỗi sẵn; workflow tuần mở đúng một issue; `/maintain` dừng chờ duyệt trước khi
  sửa source.
- **Guardrails:** engine CHỈ ĐỌC; agent không commit/merge/xoá; không nâng major tự ý; không tắt
  test/nới ngưỡng để xanh.

## 3. Research current state

Đọc repo thật (2026-09-14): `scripts/dev-task.sh` (mẫu tự dò stack + khai báo `project-commands.sh`
→ tái dùng đúng mẫu), `.claude/agents/tester.md`/`reviewer.md` (mẫu frontmatter + ranh giới "KHÔNG
làm"), `.github/workflows/stale-pr-alert.yml` (mẫu workflow lịch + một issue tổng hợp, action ghim
SHA v9.0.0), `scripts/check-docs-consistency.sh` mục 4/6/7 (cổng bắt agent/script/engine chưa khai),
`scripts/test-copy-framework.sh` mục Smoke (self-test phải xanh **trong dự án đích**), `TRAPS.md`
mục 11/15. Không có thư viện ngoài; chỉ bash + git + jq (tuỳ chọn).

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Do nothing | 0 công | Lỗi mục nát tiếp tục phát hiện tình cờ | Không chọn |
| A. Chỉ thêm prompt `/maintain` (không engine) | Rẻ | AI phải nhớ danh sách kiểm → lệch mỗi lần; không chạy được ngoài Claude Code, không đo được trong CI | Không chọn |
| B. Engine shell đo + subagent triage + lệnh + workflow lịch | Cùng một phép đo cho người/AI/CI; đa-harness (script chạy ở mọi harness); có negative-test | Thêm ~280 dòng bash + tài liệu | **Chọn** |
| C. Engine Python | Dễ mở rộng | Dự án đích không có Python thì chết (khác 4 engine cũ vốn tuỳ chọn) — bảo trì phải chạy được ở mọi nơi có git | Không chọn |

## 5. Scope / non-goals

**Trong phạm vi:** `scripts/maintenance-sweep.sh` + `scripts/test-maintenance-sweep.sh`;
`.claude/agents/maintainer.md`; `.claude/commands/maintain.md`; `.github/workflows/maintenance.yml`
(Lớp 2 dropin); biến khai báo `deps_outdated`/`deps_audit` trong `project-commands.example.sh`;
wiring CLAUDE.md/AGENTS.md/CODEMAP/FEATURE-MAP/orchestration/models-and-automation/copy-framework;
nối self-test vào CI `framework-lint` + smoke dự án đích.
**Ngoài phạm vi:** tự nâng dependency (dependabot lo); tự merge; đo coupling/complexity (radar ghi rõ
không đo); thay `/audit-full`/`/completion`.

## 7. Functional requirements

- **FR-1** Engine đo 6 mảng: Git (dirty, đứng sau main, nhánh đã merge còn sót), Dependency
  (outdated/audit — khai báo ưu tiên, tự dò Node/Python/Go/Rust, n-a nếu không dò được), Tài liệu &
  nợ (PROGRESS.md tuổi, spec Draft, goal BLOCKED, TODO/FIXME), Vệ sinh & bí mật (.env tracked,
  chuỗi giống khoá, file > 1 MB), CI & chuỗi cung ứng (action chưa ghim SHA, dependabot), Cổng khung
  (docs-consistency, ci-policy, radar, tuỳ chọn `dev-task gate`).
- **FR-2** Mỗi phát hiện có mức 🔴/🟡/ℹ️ + cách xử lý; `--strict` thoát 1 khi có 🔴; không có
  `--strict` luôn thoát 0 (không làm chết phiên).
- **FR-3** Engine không sửa gì; phép đo không áp dụng ở stack hiện tại ghi `n-a`, không crash.
- **FR-4** Subagent `maintainer` triage → `docs/ops/MAINTENANCE-PLAN.md` (mỗi mục = một PR, có
  `route:`, tiêu chí xong, cổng kiểm) và DỪNG chờ duyệt; không sửa source trước khi duyệt.
- **FR-5** `/maintain` chạy 5 pha (tiền kiểm → quét → triage/duyệt → thực thi FIFO qua `/gate` →
  hội tụ `--strict` 🔴 0), có `quick`/`full`/`continue`.
- **FR-6** Workflow tuần chạy engine `--no-deps`, mở/cập nhật MỘT issue có marker; sạch thì đóng issue.
- **FR-7** Self-test có negative-test (repo tạm cài sẵn .env + khoá giả + action chưa ghim + PROGRESS
  cũ + audit khai báo đỏ) và positive-test (repo sạch → `--strict` 0, `.env.example` không báo oan).

## 9. Acceptance criteria

| ID | Given / When / Then | Cách kiểm |
| --- | --- | --- |
| **AC-1** | Given repo khung · When `maintenance-sweep.sh --no-deps` · Then có đủ 6 mục + bảng tổng hợp, exit 0 | `scripts/test-maintenance-sweep.sh` mục 2 |
| **AC-2** | Given repo tạm có `.env` + khoá giả + `uses: …@v4` + PROGRESS 2020 + `deps_audit` exit 3 · When `--strict` · Then exit 1; có 🔴 Bí mật ×2, 🔴 Dependency, 🟡 CI, 🟡 Tài liệu | mục 3 |
| **AC-3** | Given repo tạm sạch · When `--strict --no-deps` · Then exit 0, "🔴 0", `.env.example` không bị báo | mục 4 |
| **AC-4** | Given dự án đích vừa `copy-framework.sh` · When chạy `scripts/test-maintenance-sweep.sh` ở đó · Then xanh | `scripts/test-copy-framework.sh` mục Smoke |
| **AC-5** | Given thêm agent/lệnh/script mới · Then `check-docs-consistency.sh` mục 3/4/6/7 xanh (đã khai CLAUDE.md, orchestration, CODEMAP, AGENTS) | `bash scripts/check-docs-consistency.sh` |
| **AC-6** | Given `maintenance.yml` · Then mọi `uses:` ghim SHA 40 ký tự | `scripts/check-ci-policy.sh` CP-2 |

## 10b. Phụ lục (2026-09-14, cùng ngày, trong phạm vi Approved) — chạy không giám sát trên VPS/cron

Người dùng hỏi thêm: engine chạy trên Git (GitHub Actions) hay có thể chạy trên VPS riêng? Trả lời:
cả hai — bổ sung `scripts/maintain-cron.sh`, một wrapper cho VPS/cron gọi `maintain-run.sh` rồi tự
đẩy CHỈ `docs/ops/MAINTENANCE-*.md` lên nhánh riêng `maint/auto-<ngày>` để người duyệt qua PR như
bình thường. Nằm trong phạm vi FR-5 (`/maintain`)/Outcome đã Approved (§2): vẫn là "đo → triage →
kế hoạch chờ duyệt", chỉ thêm nơi chạy. Hàng rào cứng bổ sung (không phải tùy chọn):
- Không bao giờ commit/push vào nhánh chính — luôn qua `maint/auto-<ngày>`.
- Không `--force`, không `reset --hard`/`clean -f*` khi working tree đang có việc dở (dừng, không tự dọn).
- `git add` đích danh 3 file `MAINTENANCE-*.md`, không `add -A`.
- Khoá tiến trình (flock, đặt NGOÀI working tree) chống hai lượt cron chồng nhau.

Test: `scripts/test-maintain-cron.sh` — dựng bare-repo remote THẬT (không mock), chứng minh nhánh
chính trên remote không đổi sau khi chạy, nhánh `maint/auto-*` nhận đúng nội dung, lượt thứ hai
cùng ngày ghi đè chứ không cộng dồn, `--no-push` không đụng remote, và khoá chặn được lượt chạy chồng.

## 11. Architecture và code touchpoints

- `scripts/maintenance-sweep.sh` — engine (bash, ~280 dòng, shellcheck sạch mức warning)
- `scripts/test-maintenance-sweep.sh` — self-test (CI `framework-lint` + smoke dự án đích)
- `.claude/agents/maintainer.md` — subagent Sonnet, ngoài bảng route
- `.claude/commands/maintain.md` — lệnh `/maintain`
- `.github/workflows/maintenance.yml` — lịch tuần, Lớp 2 dropin
- `.claude/project-commands.example.sh` — thêm `deps_outdated` / `deps_audit`
- `scripts/maintain-cron.sh` + `scripts/test-maintain-cron.sh` (phụ lục 10b)
- `copy-framework.sh` / `copy-framework.ps1` — phát 2 script + workflow dropin
- `CLAUDE.md`, `AGENTS.md`, `CODEMAP.md`, `docs/FEATURE-MAP.md`, `docs/framework/orchestration-3-tier.md`, `docs/framework/models-and-automation.md`, `docs/ops/repository-settings.md`

## 16. Test/eval plan

Self-test AC-1..3 chạy trong `framework-lint`; AC-4 qua smoke `test-copy-framework.sh`; AC-5/6 qua
hai gate có sẵn. Không có UI/E2E. Chạy thật `maintenance-sweep.sh` trên repo khung trước khi mở PR
và đính kết quả vào PR.

## 17. Slice/PR plan

Một PR (`feat: agent bảo trì toàn diện`) — các file mới độc lập, wiring tài liệu đi cùng PR theo
CLAUDE.md §8 bước 0. Không đụng lockfile/migration.

## 18. Rollout/rollback

Dự án đích nhận qua `copy-framework.sh` (script `copy_if_absent`, workflow vào `_framework-dropins/`
để tự so/merge). Rollback = xoá 5 file mới + gỡ wiring; không có trạng thái bền vững ngoài
`docs/ops/MAINTENANCE-*.md` (do người dùng giữ hoặc xoá).

## 19. Risk, assumptions và open decisions

| Item | Verification/mitigation | Owner | Due | Decision |
| --- | --- | --- | --- | --- |
| Regex bí mật báo oan (chuỗi test/giả) | Test tạo khoá giả lúc chạy; loại `.example/.sample`; báo oan → mục "Báo oan đã loại" trong kế hoạch, sửa engine bằng PR riêng | maintainer | — | chấp nhận |
| Kiểm dependency cần mạng, chậm | `--no-deps`, timeout 180 s/lệnh, hết giờ = 🟡 không phải 🔴 | engine | — | chấp nhận |
| Workflow tuần ồn | Một issue có marker, sạch thì tự đóng | workflow | — | chấp nhận |
| Approval qua chat, không qua form | Ghi rõ nguồn duyệt ở bảng đầu spec; người dùng có thể rút lại trước khi merge PR | người dùng | trước merge | ghi nhận |

## Approval

- [x] Product/scope
- [x] UX/a11y (n-a — không có UI)
- [x] Architecture/API/data
- [x] Security/privacy/cost (engine chỉ đọc; không gửi dữ liệu ra ngoài; issue chỉ chứa báo cáo, không chứa giá trị bí mật — engine cắt dòng 160 ký tự và chỉ in `path:line`)
- [x] Test/telemetry/rollout/rollback
- [x] Blocking decisions closed

**Conclusion:** **Approved for implementation**
**Approver/date:** Người dùng (chat) / 2026-09-14
