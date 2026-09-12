# Feature spec: Hàng rào thi hành cho các luật của khung

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | `docs/ops/COMPLETION-PLAN.md` — goal "Siết hàng rào (audit 2026-09-12)"; phát hiện F-001…F-017 trong `docs/ops/COMPREHENSIVE-AUDIT-STATUS.md` |
| Spec owner | AI (Claude Code), phiên 2026-09-12 |
| State | **Approved for implementation** |
| Approver / date | Người dùng (chủ repo) — 2026-09-12, duyệt phạm vi "cập nhật toàn diện" = cả 15 phát hiện của audit (sau đó thêm F-016, F-017 phát hiện trong lúc thực thi) |
| Last updated | 2026-09-12 |

> **Độ lệch quy trình phải ghi nhận (trung thực):** khung yêu cầu spec Approved **trước khi sửa
> source** (`CLAUDE.md` §2 Feature gate). Thực tế phiên này làm **ngược**: người dùng duyệt phạm vi
> bằng lời → AI sửa code → cổng `pr-policy.yml` trên PR #64 chặn vì thiếu spec → spec này được viết
> **sau**. Người duyệt phạm vi là thật và có trước khi code, nhưng *hình thức* spec thì trễ.
> Đây chính là bằng chứng cổng feature gate hoạt động; giữ ghi chú này làm bài học, không xoá.

## 1. Problem, user và evidence

**Problem.** Audit toàn diện 2026-09-12 cho ra 17 phát hiện. 4 trong số đó (F-001, F-002, F-004,
F-005) cùng **một khuôn**: một luật được viết trong `CLAUDE.md` nhưng **không có cơ chế nào thi
hành** nó. Luật không có hàng rào thì sẽ bị vi phạm trong phiên dài — và vi phạm **im lặng**.

**User.** (a) Người dùng khung này cho dự án thật; (b) AI chạy trong khung (chính là tác nhân dễ
vi phạm luật nhất khi phiên dài).

**Evidence (đo thật, không suy đoán).**

- **F-001:** 5 PR dependabot mở từ 2026-08-24, tới 2026-09-12 vẫn chưa merge — 19 ngày. `CLAUDE.md`
  §8 yêu cầu FIFO. Điều tra CI: `pr-policy.yml` job `metadata` **đỏ ở cả 2/2 lượt chạy** của PR #53
  → required check này *không thể* xanh trên PR bot (đòi mục PR template mà dependabot không điền).
  Không phải người quên FIFO: **cổng tự deadlock**.
- **F-002:** `.claude/hooks/pre-commit-gate.sh` là tính năng cốt lõi ("cổng chặn commit đỏ") nhưng
  `grep -rl hooks/ scripts/ .github/` cho thấy chỉ `test-copy-framework.sh` nhắc tới nó — và chỉ để
  kiểm hook **được copy**. `verify-dropins.sh:104` ghi rõ "job này không commit nên bỏ `prepare:
  husky`" → husky `pre-commit`/`commit-msg` **chưa bao giờ chạy** trong bất kỳ lượt verify nào.
- **F-004:** `CLAUDE.md` §8 cấm force-push nhánh chính và cấm `--abort` để né xung đột. Không có
  hook/CI nào chặn.
- **F-005:** `secret-scan.yml` chỉ chạy ở CI → bí mật bị bắt **sau khi** đã vào lịch sử Git.

## 2. Outcome, baseline, target và guardrails

| | Baseline (trước) | Target (sau) |
| --- | --- | --- |
| Luật có cơ chế thi hành | 0/4 (F-001/002/004/005 chỉ là văn bản) | 4/4 |
| Cổng chặn commit có bằng chứng chặn | 0 assertion | ≥ 15 assertion + negative test |
| Action ghim SHA | 12/13 | 13/13 + cổng canh |
| Action chạy Node 20 (bị xoá khỏi runner 16/09/2026) | 6 (`cache` + 5 chờ ở PR dependabot) | 0 |
| Năng lực khung không có cổng nào | subagent (8), hook (5 — chỉ kiểm copy) | subagent có cổng 2 chiều; hook có test hành vi |

**Guardrail:** không được biến hàng rào thành vật cản. Mọi hàng rào mới phải có **cờ bỏ qua tường
minh** và phải **fail-open có cảnh báo** khi thiếu công cụ, không fail-closed.

## 3. Research current state

- `git ls-remote --tags https://github.com/actions/cache` (2026-09-12): tag `v4` → `0057852` =
  v4.3.0; `action.yml` của nó `using: 'node20'`. Tag mới nhất v5: `caa2961` = v5.1.0 → `node24`.
- Kiểm `action.yml` của 4 action đã ghim còn lại (`checkout@3d3c42e`, `setup-node@8207627`,
  `upload-artifact@043fb46`, `cache@caa2961`) — **tất cả node24**.
- Release notes `gitleaks-action` v3.0.0, `dependency-review-action` v5.0.0: chỉ nâng runtime
  Node 24, không đổi input/output. `github-script` v9: **có** breaking change
  (`require('@actions/github')` không còn dùng được); đọc 2 chỗ dùng trong repo — chỉ gọi `core`,
  `github.rest`, `context` → **không ảnh hưởng**.
- GitHub deprecation: Node 20 bị **xoá khỏi runner 2026-09-16**. Log CI của PR #64 đã hiện warning
  "actions/github-script@… being forced to run on Node.js 24".

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Do nothing | 0 công | 4 luật tiếp tục bị vi phạm im lặng; 5 PR bảo mật kẹt qua mốc 16/09 | ❌ |
| Chỉ nâng 5 PR dependabot | Rẻ, gỡ rủi ro Node 20 | Không sửa nguyên nhân → PR dependabot **kế tiếp** lại kẹt y như vậy | ❌ |
| Sửa cổng + dựng hàng rào cho cả 4 luật (chọn) | Sửa nguyên nhân gốc; mỗi luật có cơ chế | Thêm ~600 dòng cần bảo trì; rủi ro hàng rào chặn oan | ✅ |
| Thêm luôn hàng rào cho *mọi* phát hiện | Trọn vẹn | W-202/W-303 cần chạy npm/Supabase thật để kiểm chứng → đẩy code chưa kiểm là vi phạm §5 | ❌ hoãn, ghi lý do |

## 5. Scope / non-goals

**Trong phạm vi:** W-102, W-103, W-104, W-105, W-106, W-201, W-203, W-204, W-301, W-302, W-304,
W-305, W-307, W-309, W-311, W-312 + `docs/FEATURE-MAP.md`, `docs/CONVENTIONS.md`, ADR-0003,
`TRAPS.md` mục 5–6.

**Non-goals (hoãn, có lý do trong `COMPLETION-PLAN.md`):** W-101 (chặn bởi W-106 — cần merge
trước), W-202 + W-303 (cần môi trường npm/Supabase thật để kiểm chứng), W-306 (chờ SHA `main`),
W-308 (xoá nhánh remote — cần người dùng xác nhận, `CLAUDE.md` §9), W-310 (phiên này bị chặn quyền
đọc `.env*`).

## 6. User journeys và mọi state

| State | Hành vi mong đợi |
| --- | --- |
| Cổng đỏ + `git commit` | Chặn (exit 2), in lý do + cách bỏ qua |
| Cổng xanh | Cho qua, im lặng |
| Thiếu `jq`/`gitleaks`/`pwsh`/`dev-task.sh` | **Fail-open + CẢNH BÁO ra stderr** (không im lặng, không chặn) |
| Người dùng chủ động bỏ qua | `--no-verify` / `ALLOW_DANGEROUS_GIT=1` / `SKIP_SECRET_SCAN=1` |
| Chuỗi mô tả chứa chữ "git reset --hard" | **Không** chặn (bỏ phần trong dấu nháy trước khi so khớp) |
| CI thiếu `pwsh` | `REQUIRE_PWSH=1` → job đỏ (không bỏ qua âm thầm) |
| Job cổng đỏ | `gate` (`if: always()`) đỏ theo — không được "skipped" (GitHub coi skipped là đạt) |
| PR do bot tạo | Miễn trừ mục PR template, vẫn kiểm tiêu đề conventional |
| PR mở > 7 ngày | Workflow tuần mở/cập nhật một issue tổng hợp, nêu rõ check đỏ |

## 7. Functional requirements

- **FR-1** `scripts/test-hooks-gate.sh` chứng minh `pre-commit-gate.sh` chặn khi đỏ, cho qua khi
  xanh, tôn trọng `--no-verify`, fail-open có cảnh báo khi thiếu `jq`; kèm negative test.
- **FR-2** `block-dangerous-git.sh` chặn force-push nhánh chính, `reset --hard`,
  `merge/rebase/cherry-pick --abort`; cảnh báo (không chặn) force-push nhánh riêng; cờ bỏ qua.
- **FR-3** `.husky/pre-commit` quét `gitleaks protect --staged`; fail-open có cảnh báo.
- **FR-4** `check-ci-policy.sh` thêm CP-2 (ghim SHA), CP-3 (`node-version` ↔ `.nvmrc`), CP-4
  (`needs:` của `gate` đủ job), và mục 7 (bảng CP-* khai ở cả bản vitest dropins).
- **FR-5** `check-docs-consistency.sh` kiểm subagent ↔ bảng `route:` hai chiều + frontmatter `name`
  khớp tên file; quét cả file chưa `git add`.
- **FR-6** `pr-policy.yml` miễn trừ `BOT_ACTORS` khỏi yêu cầu mục PR template.
- **FR-7** `ci.yml` có job `gate` với `if: always()`, `needs:` mọi job cổng.
- **FR-8** `stale-pr-alert.yml` chạy tuần, mở/cập nhật một issue liệt kê PR mở > 7 ngày kèm check đỏ.

## 8. Non-functional requirements

- **An toàn:** không hàng rào nào được làm chết phiên → hook dùng `set -uo pipefail` (cố ý không
  `-e`), luôn `exit 0` trừ khi cố ý chặn. Ghi thành quy ước `docs/CONVENTIONS.md` §A.
- **Đa loại dự án:** hook không chứa lệnh stack; mọi lệnh qua `scripts/dev-task.sh`.
- **Hiệu năng:** `test-hooks-gate.sh` < 5 s (dùng `dev-task.sh` giả, không chạy build thật);
  job `gate` ≈ 10 s; `stale-pr-alert` 1 lượt/tuần.
- **Bảo mật:** `stale-pr-alert.yml` chỉ `contents/pull-requests/checks: read` + `issues: write`.

## 9. Acceptance criteria

| AC | Given / When / Then | Evidence |
| --- | --- | --- |
| AC-1 | Cổng đỏ, chạy `git commit` → hook exit 2 | `test-hooks-gate.sh` ca 1 |
| AC-2 | Hook bị thay bằng hook rỗng → test phải ĐỎ | ca 6 (negative) |
| AC-3 | `git push --force origin main` → chặn | ca 7 |
| AC-4 | `echo 'git reset --hard ...'` → **không** chặn | ca 8 |
| AC-5 | Gỡ pin SHA một action → `check-ci-policy.sh` rc=1 | NT đã chạy |
| AC-6 | `node-version` lệch `.nvmrc` → rc=1 | NT đã chạy |
| AC-7 | Bỏ một job khỏi `needs:` của `gate` → rc=1 | NT đã chạy |
| AC-8 | Thêm agent không khai tài liệu / `name` lệch / route trỏ agent ảo → rc=1 | 3 NT đã chạy |
| AC-9 | File `.md` chưa `git add` có link gãy → rc=1 | NT đã chạy |
| AC-10 | Thêm CP-* ở bản shell mà quên bản vitest → rc=1 | NT đã chạy |
| AC-11 | `stale-pr-alert` bỏ qua PR draft và PR mới; update issue cũ thay vì tạo mới; không vỡ khi API check lỗi | 4 ca chạy offline với `github`/`core` giả |
| AC-12 | Dropins vẫn lint/type-check/build/test sạch trên Next.js mới | `verify-dropins.sh` |

## 11. Architecture và code touchpoints

`.claude/hooks/{block-dangerous-git,auto-format,pre-commit-gate}.sh` · `.claude/settings.json` +
`settings-shared-opusplan.json` · `scripts/{test-hooks-gate,check-ci-policy,check-docs-consistency,
test-copy-framework,ci-workflow-policy.test}.ts|sh` · `.github/workflows/{ci,pr-policy,
stale-pr-alert}.yml` · `.husky/pre-commit` · `copy-framework.sh|.ps1` · `docs/adr/0003-*` ·
`docs/{FEATURE-MAP,CONVENTIONS}.md` · `CODEMAP.md` · `TRAPS.md`.

## 14. Security/privacy/abuse cases

- **Abuse chính:** bỏ qua hàng rào bằng cờ (`ALLOW_DANGEROUS_GIT=1`, `SKIP_SECRET_SCAN=1`,
  `--no-verify`). **Cố ý cho phép** — hàng rào không có đường thoát tường minh sẽ bị vô hiệu hoá
  theo cách tệ hơn (xoá hook). Giảm nhẹ: cờ phải gõ tay, và AI phải nói rõ lý do cho người dùng.
- **Abuse thứ hai:** thêm job cổng rồi không đưa vào `needs:` của `gate` → đỏ không chặn merge.
  Giảm nhẹ: CP-4.
- Không xử lý dữ liệu người dùng; `stale-pr-alert` chỉ đọc metadata PR công khai của repo.

## 16. Test/eval plan

`test-hooks-gate.sh` (21 assertion) · `check-ci-policy.sh` CP-1..4 + mục 7 · `check-docs-consistency.sh`
mục 1–4 · `test-copy-framework.sh` (+`REQUIRE_PWSH`) · `verify-dropins.sh` (lint/type/build/test
thật trên Next.js sạch) · harness Node offline cho logic `stale-pr-alert` · **mọi assertion mới đều
kèm negative test đã chạy đỏ có chủ đích** (quy ước `CONVENTIONS.md` §A).

## 17. Slice/PR plan

1. **PR #64 (này)** — toàn bộ scope mục 5.
2. Sau khi #64 merge: W-101 — merge #53→#54→#55→#56→#57 theo FIFO (mỗi PR update branch với `main`).
3. Đợt sau: W-202, W-302 (phần còn lại), W-303, W-308, W-310.

## 18. Rollout/rollback

Rollout: merge squash vào `main`; sau đó chuyển branch protection sang khoá một tên `gate`
(việc thủ công trên GitHub — `docs/ops/repository-settings.md`). Rollback: revert commit; không có
trạng thái ngoài Git. Hook mới chỉ ảnh hưởng máy local của người chạy; xoá file là hết hiệu lực.

## 19. Risk, assumptions và open decisions

| Item | Verification/mitigation | Owner | Due | Decision |
| --- | --- | --- | --- | --- |
| Hàng rào chặn oan lệnh hợp lệ | 5 ca "không được chặn oan" trong `test-hooks-gate.sh`; đã bắt 1 lỗi thật (chuỗi trong dấu nháy) | AI | xong | ✅ đã xử lý |
| `stale-pr-alert` gây ồn | 1 lượt/tuần, một issue duy nhất (cập nhật, không tạo mới) | AI | xong | ✅ |
| Branch protection phải đổi tay sau merge | Ghi trong ADR-0003 + `repository-settings.md` + mục 18 | Người dùng | sau merge | ⚠️ chưa tự động hoá được |
| W-202/W-303 cần môi trường thật | Hoãn có lý do, ghi trong `COMPLETION-PLAN.md` | AI | đợt sau | ⚠️ để mở |
| `git checkout <file>` vẫn xoá được việc chưa commit | Không chặn (dùng hợp lệ hàng ngày); chốt bằng quy ước + `TRAPS.md` mục 6 | AI | xong | ✅ chấp nhận rủi ro có chủ đích |
