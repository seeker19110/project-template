# Feature spec: Golden test và kỷ luật TDD thành luật của khung

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | — (khởi phát từ câu hỏi của người dùng 2026-09-12: "có golden và TDD chưa?") |
| Spec owner | AI (Claude Code) |
| State | **Approved for implementation** |
| Approver / date | donghanhcungban.org@gmail.com / 2026-09-12 |
| Last updated | 2026-09-12 |

> Không code khi chưa **Approved for implementation**.

## 1. Problem, user và evidence

Khung tự nhận ở `CLAUDE.md` §3.6 là "chống lỗi logic" và ở `quality-supplements.md` Nhóm 2 mục 6 là
"kỷ luật viết test". Lượt rà ngày 2026-09-12 (grep toàn repo, có dẫn số dòng) cho thấy hai khoảng trống:

**Golden test — chưa tồn tại như một cơ chế.** Toàn repo chỉ có **2 lần nhắc thoáng qua**, cả hai đều
ở dạng gợi ý hồ sơ công nghệ, không phải luật:
- `docs/framework/01-process-and-standards.md:11` — "CLI/thư viện: SemVer + golden test"
- `docs/framework/03-tech-selection-and-proactive-advice.md:237` — bảng hồ sơ: "Unit + **snapshot/CLI golden test** + ma trận đa phiên bản runtime"

Không có: định nghĩa golden test là gì, nơi lưu fixture, **luật soát diff khi cập nhật golden**, cổng
chặn, template, hay một ví dụ chạy được. `vitest.config.mts` không cấu hình snapshot
(`resolveSnapshotPath`, `snapshotFormat`, hay `--update` policy). Hệ quả nghiêm trọng và rất cụ thể:
golden test **không có luật cập nhật** là loại test tệ hơn không có test — khi nó đỏ, phản xạ mặc định
(của người và của AI) là chạy `vitest -u` để "làm xanh", tức là **ghi nhận bug thành giá trị kỳ vọng
mới**. Lúc đó lưới bảo vệ đã lặng lẽ trở thành thứ hợp pháp hoá hồi quy. Đây đúng là khuôn
"hỏng theo kiểu im lặng" mà spec `2026-09-12-traps-codemap-ci-policy.md` đang xử lý ở mặt CI.

**TDD — có, nhưng chỉ bắt buộc ở một ca hẹp và không có ở cổng nào.**
- Bắt buộc (hẹp): "bug phải có **test tái hiện trước** khi sửa (đỏ → sửa → xanh)" — `project-completion.md:30`, `.claude/commands/completion.md:27`, `docs/ops/comprehensive-audit-prompt.md:170`.
- Tùy chọn (tổng quát): `quality-supplements.md:413` — "**Vòng đỏ-xanh (khi áp dụng TDD có chủ đích)**".
- Trống: `CLAUDE.md` §3 (nguyên tắc bất biến), §5 (cổng commit), §6 (cổng merge) **không có chữ nào** về TDD hay test-trước. `.claude/commands/gate.md` không kiểm. `.claude/commands/debug.md` yêu cầu test hồi quy **kèm lúc sửa**, không phải trước.

Nên luật "test tái hiện trước" hiện chỉ sống trong nhánh `/completion` và `/audit-full`. Một phiên
`/auto` hay một PR `fix` thông thường **không đi qua** nhánh đó → sửa bug không có test tái hiện là
đường đi mặc định, dù khung có ý ngược lại. Đó là lệch giữa ý định và cơ chế.

## 2. Outcome, baseline, target và guardrails

| | Baseline (2026-09-12) | Target |
| --- | --- | --- |
| Golden | 2 lần nhắc thoáng qua, 0 định nghĩa, 0 luật cập nhật, 0 cổng, 0 ví dụ | Có định nghĩa + quy ước fixture + **luật cập nhật golden phải soát diff và nêu lý do trong PR** + ví dụ chạy được trong dropins + kiểm ở `/gate` |
| TDD | Bắt buộc chỉ trong `/completion`+`/audit-full`; vắng ở `CLAUDE.md` §3/§5/§6 và `/gate` | "Sửa bug → test tái hiện đỏ trước" thành **luật cấp `CLAUDE.md`**, có ở cổng commit §5 và `/gate`, và ở `/debug`; vòng đỏ-xanh tổng quát vẫn là **khuyến nghị**, không bắt buộc |

**Guardrails (quan trọng — chống biến khung thành vật cản):**
- **KHÔNG** ép TDD đầy đủ cho mọi thay đổi. Ép test-trước lên scaffolding, đổi tên cơ học, hay tài liệu là nghi thức rỗng; `quality-supplements.md:399` đã cảnh báo đúng thứ này ("horizontal slicing"). Chỉ bắt buộc ở **hai ca**: sửa bug, và nhánh logic nghiệp vụ phức tạp (đã là luật §3.6).
- **KHÔNG** đặt golden test làm mặc định cho UI. Snapshot UI rộng là nguồn test giòn kinh điển; giới hạn golden vào **đầu ra tuần tự hoá được, ổn định**: output CLI, phản hồi API đã chuẩn hoá, SQL/ERD sinh ra, file cấu hình sinh ra, kết quả tính toán dạng bảng.
- Không thêm phụ thuộc mới (Vitest đã có snapshot sẵn).
- Không tăng thời gian CI đáng kể (golden test là so sánh chuỗi).

## 3. Research current state

Đã đọc trực tiếp trong repo này (dẫn số dòng ở §1): `01-process-and-standards.md`,
`03-tech-selection-and-proactive-advice.md`, `quality-supplements.md` (Nhóm 2 mục 6, dòng ~390–416),
`project-completion.md`, `.claude/commands/{completion,debug,gate}.md`, `CLAUDE.md` §3/§5/§6,
`vitest.config.mts`, `docs/ops/comprehensive-audit-prompt.md`.

Thượng nguồn đã xem trong lượt quét 15 repo (2026-09-12):
- `donghanh/scripts/*-fixtures.json` (vd `eval-code-feedback-fixtures.json`, `eval-v2-routing-fixtures.json`, `eval-v2-memory-fixtures.json`) — **mẫu fixture tách khỏi file test**, đúng hình dạng golden cho đầu ra LLM; kèm `*.test.ts` đối chiếu.
- `xboss/scripts/test-skip-allowlist.json` + `mutation-check.mjs` — mẫu **allowlist tường minh** cho ngoại lệ test, tức "muốn bỏ qua thì phải ghi tên vào một file có người review".
- `X-Studio/evals/thresholds.yaml` + `evals/recordings/` — ngưỡng và bản ghi tách riêng.
- repo `Claude-Agents`, workflow eval-record.yml — **cập nhật bản ghi (golden) là hành động THỦ CÔNG có người bấm nút** (`workflow_dispatch`), không tự động mỗi PR; và CI đỏ ở `eval-replay` khi bản ghi lệch. Đây chính là mẫu "không tự ý làm xanh golden" mà §2 cần.

`eval-record.yml` xác nhận hướng thiết kế: **tách "phát hiện lệch" (tự động, chặn) khỏi "cập nhật giá trị
kỳ vọng" (thủ công, có người chịu trách nhiệm)**.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Do nothing | 0 công | Luật "test tái hiện trước" tiếp tục chỉ sống ở 2 nhánh lệnh; golden vẫn là 2 dòng chữ suông; dự án đích tự nghĩ ra cách riêng (4 repo đã tự nghĩ 4 cách) | ❌ |
| A. Ép TDD đầy đủ (mọi thay đổi phải test-trước) + snapshot mọi component | "Nghiêm" trên giấy | Nghi thức rỗng, test giòn, AI sẽ viết test tưởng tượng — đúng bẫy `quality-supplements.md:399`; sẽ bị bỏ qua trong thực tế | ❌ |
| **B. TDD bắt buộc đúng 2 ca (bug-fix, nhánh logic phức tạp) + golden có phạm vi hẹp và LUẬT CẬP NHẬT** | Khớp luật đã có (§3.6, `/completion`), nâng lên cấp `CLAUDE.md` + cổng để mọi nhánh đi qua; golden hẹp nên không giòn | Phải viết luật cập nhật golden cho cẩn thận, không thì vô dụng | ✅ **Chọn** |
| C. Chỉ thêm tài liệu, không chạm cổng | Rẻ | Đúng lỗi hiện tại: khung đã có ý định ở tài liệu mà vẫn không xảy ra vì không cổng nào kiểm | ❌ |

## 5. Scope / non-goals

**Trong phạm vi**
1. `docs/framework/quality-supplements.md` Nhóm 2 mục 6: thêm tiểu mục **"Golden test — khi nào dùng, lưu ở đâu, cập nhật thế nào"** và làm rõ ranh giới TDD bắt buộc vs khuyến nghị.
2. `CLAUDE.md` §3 (thêm vào mục 6 "chống lỗi logic"): **sửa bug phải có test tái hiện đỏ trước khi sửa**; và một dòng về golden.
3. `CLAUDE.md` §5 + `.claude/commands/gate.md` + mẫu Báo cáo xác thực §7: thêm dòng kiểm `Test tái hiện (nếu là fix) ✅/❌ | Golden cập nhật có lý do ✅/n-a`.
4. `.claude/commands/debug.md`: chuyển "test hồi quy" từ *kèm lúc sửa* sang **đỏ trước khi sửa** (khớp `/completion`).
5. `docs/framework/templates/GOLDEN-TEST.template.md` (mới) — quy ước thư mục fixture + checklist cập nhật.
6. Dropins: một golden test **ví dụ chạy được** + cấu hình snapshot trong `vitest.config.mts` (đường dẫn snapshot tường minh, `ci: snapshot không được tự tạo mới`).
7. Cổng: `--ci` của Vitest đã chặn tạo snapshot mới trên CI — **xác minh thật** rồi ghi vào tài liệu; nếu chưa bật thì bật trong `ci.yml` của dropins.
8. `TRAPS.md`/`CODEMAP.md` (từ spec 1) thêm dòng tương ứng — **chỉ nếu spec 1 đã merge**.
9. CHANGELOG + PROGRESS.md.

**Non-goals**
- Snapshot UI component diện rộng (xem guardrail §2).
- Mutation testing (`xboss/mutation-check.mjs`) — đáng làm nhưng là capability riêng, để đợt sau.
- Eval LLM / `thresholds.yaml` — chỉ áp dụng cho dự án đích có phần LLM; ghi một dòng trỏ tới, không dựng cơ chế.
- Đổi ngưỡng coverage hiện có (70%) — không liên quan.
- Ép TDD cho scaffolding/rename/docs.

## 6. User journeys và mọi state

| Journey | Hành vi mong đợi |
| --- | --- |
| Happy — sửa bug | AI viết test tái hiện **đỏ** trước, dán output đỏ làm bằng chứng, rồi sửa, rồi xanh. `/gate` in dòng "Test tái hiện ✅" |
| Happy — golden đỏ do đổi hành vi **có chủ đích** | Cập nhật golden, PR **phải** nêu: đổi gì, vì sao đúng, diff golden dán trong PR body |
| Error — golden đỏ do **hồi quy** | Luật cấm `-u` phản xạ; phải chẩn đoán trước. Phát hiện: diff golden không giải thích được bằng thay đổi trong PR |
| Empty — thay đổi không phải fix (feat/docs/chore) | Dòng kiểm là `n-a`, **không chặn** |
| Empty — dự án đích không có đầu ra tuần tự hoá được | Golden `n-a`; tài liệu nói rõ đây là trường hợp hợp lệ, không phải nợ kỹ thuật |
| Conflict — golden đỏ trên CI nhưng xanh ở máy (khác OS/locale/timezone) | Tài liệu bắt buộc chuẩn hoá trước khi so: sort khoá, cố định timezone/locale, thay timestamp/id/đường dẫn tuyệt đối bằng placeholder |
| Recovery — golden đã bị `-u` sai từ trước | Đối chiếu lại với hành vi mong đợi trong `PROJECT.md`, ghi một mục vào `TRAPS.md` (spec 1) |

## 7. Functional requirements

- **FR-1** `CLAUDE.md` §3.6 ghi luật: **sửa bug → test tái hiện đỏ trước khi sửa**, kèm câu nêu rõ ngoại lệ (không áp cho scaffolding/rename/docs).
- **FR-2** `CLAUDE.md` §5 và mẫu báo cáo §7 có dòng `Test tái hiện (nếu là fix) ✅/❌/n-a` và `Golden ✅/n-a`.
- **FR-3** `.claude/commands/gate.md` kiểm và in hai dòng ở FR-2; commit `fix:` mà không có test tái hiện → **cảnh báo và hỏi**, không tự động chặn (vì có ca sửa lỗi chính tả trong chuỗi thật sự không cần test — chặn cứng sẽ dạy người dùng đặt sai loại commit).
- **FR-4** `.claude/commands/debug.md` chuyển sang **test tái hiện đỏ trước khi sửa**, khớp `/completion`.
- **FR-5** `quality-supplements.md` Nhóm 2 mục 6 có tiểu mục Golden test gồm đủ 5 phần: (a) dùng khi nào / **không** dùng khi nào, (b) nơi lưu fixture (`__golden__/` hoặc `*-fixtures.json` cạnh test), (c) **luật chuẩn hoá** trước khi so (timestamp/id/đường dẫn/thứ tự khoá/locale/timezone), (d) **luật cập nhật**: không `-u` phản xạ; PR phải nêu lý do + dán diff golden, (e) CI không được tự tạo snapshot mới.
- **FR-6** Làm rõ tại `quality-supplements.md:413`: vòng đỏ-xanh tổng quát là **khuyến nghị**; "test tái hiện trước" cho bug là **bắt buộc**. Hai thứ khác nhau, hiện đang lẫn.
- **FR-7** `GOLDEN-TEST.template.md` tồn tại, ≤ 50 dòng, có checklist cập nhật golden dán được vào PR body.
- **FR-8** Dropins có 1 golden test ví dụ chạy được + `vitest.config.mts` cấu hình snapshot tường minh; `verify-dropins.sh` chạy nó thật.
- **FR-9** **Xác minh thật** (không suy đoán) hành vi Vitest khi snapshot thiếu ở chế độ CI, rồi mới ghi vào tài liệu.

## 8. Non-functional requirements

- **Reliability:** golden test phải **tất định**. FR-5(c) là điều kiện bắt buộc, không phải gợi ý — golden chập chờn sẽ bị vô hiệu hoá trong vài tuần rồi thành rác.
- **Performance:** so sánh chuỗi; ngân sách CI +5 s.
- **Cost:** 0 (không gọi API; golden cho đầu ra LLM là **non-goal** ở spec này).
- **Compatibility:** dùng snapshot sẵn có của Vitest; không thêm dependency. Hồ sơ non-Node: ghi công cụ tương đương (pytest `--snapshot-update`, `insta` của Rust) ở dạng một dòng trỏ, không dựng cơ chế.
- **Security:** golden fixture là nơi **rất dễ** vô tình commit dữ liệu thật (email, token trong response mẫu). FR-5 phải ghi cảnh báo + yêu cầu dữ liệu tổng hợp; `gitleaks`/`secret-scan.yml` là hàng rào sau cùng.
- **A11y:** không áp dụng.

## 9. Acceptance criteria

| AC | Given / When / Then | Bằng chứng |
| --- | --- | --- |
| AC-1 | Given một bug giả lập trong dropins · When làm theo `/debug` mới · Then có test đỏ **trước** khi sửa, và output đỏ được dán vào báo cáo | chạy thật, dán 2 output (đỏ rồi xanh) |
| AC-2 | Given golden test ví dụ · When đổi code để lệch hành vi · Then test đỏ với diff đọc được (không phải "Object mismatch" mù) | chạy thật |
| AC-3 | Given snapshot bị xoá · When chạy ở chế độ CI · Then **đỏ**, không tự tạo lại | chạy thật — đây là FR-9, cấm suy đoán |
| AC-4 | Given golden test ví dụ chạy 2 lần ở 2 timezone khác nhau (`TZ=UTC` và `TZ=Asia/Ho_Chi_Minh`) · Then cùng kết quả | chạy thật |
| AC-5 | Given `bash scripts/check-docs-consistency.sh` · Then PASS (TRIGGER và tham chiếu khớp) | cổng tự động |
| AC-6 | Given `bash scripts/verify-dropins.sh` · Then golden test ví dụ lint + type-check + pass trên dự án Next.js sạch | chạy thật |
| AC-7 | Given `/gate` trên một diff `fix:` không có test · Then in cảnh báo đúng dòng FR-3 | chạy thật |
| AC-8 | Given `quality-supplements.md` sau sửa · Then phân biệt rõ "bắt buộc (bug-fix)" vs "khuyến nghị (vòng đỏ-xanh tổng quát)" — không còn đọc lẫn | rà tay + trích dẫn |

## 10. UX/content/accessibility

Ngôn ngữ phải nói rõ **bắt buộc / khuyến nghị / không áp dụng** ở từng câu — đây chính là chỗ bản hiện
tại hỏng (một dòng "khi áp dụng TDD có chủ đích" để ngỏ cho mọi cách hiểu). Checklist cập nhật golden
phải **dán được thẳng vào PR body**, không cần diễn giải.

## 11. Architecture và code touchpoints

| Muốn | Sửa | Rồi chạy |
| --- | --- | --- |
| Luật TDD cấp khung | `CLAUDE.md` §3.6, §5, §7; `AGENTS.md` | `scripts/check-docs-consistency.sh` |
| Cổng kiểm | `.claude/commands/gate.md` | `check-docs-consistency.sh` |
| Vòng chẩn đoán | `.claude/commands/debug.md` | như trên |
| Hướng dẫn golden + TDD | `docs/framework/quality-supplements.md` (Nhóm 2 mục 6) | — |
| Template | `docs/framework/templates/GOLDEN-TEST.template.md` (mới) | `scripts/test-copy-framework.sh` |
| Ví dụ chạy được + cấu hình snapshot | dropins: `lib/<ví dụ>.golden.test.ts`, `vitest.config.mts` | `scripts/verify-dropins.sh` |

## 12. API/event contract

Không có API. Hợp đồng là **định dạng dòng mới trong Báo cáo xác thực §7** (`Test tái hiện ✅/❌/n-a`,
`Golden ✅/n-a`) — phải giữ ổn định vì `/gate`, `/completion`, `/auto` đều in mẫu này.

## 13. Data contract/migration

Golden fixture **là** dữ liệu có hợp đồng: đổi định dạng fixture = phá vỡ mọi golden hiện có.
Tài liệu phải ghi: đổi cách chuẩn hoá thì cập nhật **toàn bộ** golden trong một PR riêng, nêu rõ là
thay đổi cơ chế chứ không phải thay đổi hành vi. Dự án đích đã có snapshot cũ: không migration tự động.

## 14. Security/privacy/abuse cases

- Golden fixture chứa dữ liệu thật (PII, token trong response mẫu) — giảm nhẹ: FR-5 yêu cầu dữ liệu tổng hợp; `secret-scan.yml` + gitleaks là hàng rào sau.
- **Abuse chính (và đây là rủi ro thật nhất của spec này):** "làm xanh" bằng `vitest -u` hoặc thêm test vào skip-allowlist. Giảm nhẹ: luật FR-5(d) + yêu cầu dán diff golden trong PR; mẫu allowlist tường minh của `xboss` cho ngoại lệ. Không chống được bằng tự động hoá — chống bằng việc **diff golden phải có mặt trong PR để người review thấy**.
- Abuse thứ hai: viết test tái hiện **sau** khi sửa rồi khai là trước. Không kiểm được bằng script; giảm nhẹ bằng yêu cầu **dán output đỏ** làm bằng chứng (§7 báo cáo xác thực), cùng lối "bằng chứng chạy thật" khung đã dùng.

## 15. Observability và operations

Không có runtime service. Quan sát qua: dòng mới trong Báo cáo xác thực mỗi lần `/gate`; job test trên PR.
Runbook khi golden đỏ: (1) **đừng** `-u`; (2) đọc diff, hỏi "thay đổi nào trong PR này giải thích được
diff đó?"; (3) giải thích được → cập nhật + nêu lý do trong PR; (4) không giải thích được → đó là hồi quy,
sang `/debug`, và ghi một mục `TRAPS.md`.

## 16. Test/eval plan

| Loại | Nội dung |
| --- | --- |
| Negative test (bắt buộc) | AC-2 (golden phải biết đỏ), AC-3 (CI không tự tạo snapshot), AC-7 (cổng phải biết cảnh báo). Cổng/test chưa từng thấy đỏ là chưa được kiểm chứng |
| Tất định | AC-4: chạy 2 timezone |
| Cổng có sẵn | `check-docs-consistency.sh`, `test-copy-framework.sh`, `verify-dropins.sh` |
| Xác minh hành vi công cụ | FR-9/AC-3 — chạy Vitest thật, **không** ghi tài liệu theo trí nhớ (CLAUDE.md §4) |
| Không cần | E2E, a11y, perf, migration |

## 17. Slice/PR plan

| PR | Nội dung | Phụ thuộc | Nhãn route |
| --- | --- | --- | --- |
| PR-A | **TDD**: `CLAUDE.md` §3.6/§5/§7 + `AGENTS.md` + `/gate` + `/debug` + làm rõ `quality-supplements.md:413` (FR-1,2,3,4,6) | — | `route:standard` |
| PR-B | **Golden — tài liệu + template**: tiểu mục Nhóm 2 mục 6 + `GOLDEN-TEST.template.md` (FR-5,7) | PR-A (tránh trùng `quality-supplements.md`) | `route:standard` |
| PR-C | **Golden — cơ chế thật**: ví dụ chạy được + cấu hình snapshot + AC-3/AC-4 + `copy-framework.*` (FR-8,9) | PR-B | `route:spec` |

Quan hệ với spec `2026-09-12-traps-codemap-ci-policy.md`: **độc lập về file**, chạy song song được, TRỪ
`quality-supplements.md`/`CLAUDE.md` — spec kia cũng sửa `CLAUDE.md` §1/§5/§6. Theo FIFO (CLAUDE.md §8),
spec 1 tạo trước → merge trước; PR-A rebase lên `main` sau đó.

## 18. Rollout/rollback

Tài liệu + 1 file test ví dụ; không flag, không staging. Rollout = squash merge PR-A→PR-C.
Rollback = `git revert` từng PR. Rủi ro triển khai: luật mới ở `/gate` có thể làm phiên đang chạy
`/auto` thấy dòng kiểm lạ — vô hại vì FR-3 là **cảnh báo**, không chặn.

### Mục CHANGELOG sẽ thêm khi thực thi (vào `## [Unreleased]` → `### Added` / `### Changed`)

```
### Added
- **Golden test thành cơ chế thật, không còn là 2 dòng nhắc suông** (spec
  `docs/specs/2026-09-12-golden-tests-and-tdd.md`): thêm `GOLDEN-TEST.template.md` + tiểu mục
  Nhóm 2 mục 6 với đủ 5 phần (phạm vi dùng/không dùng · nơi lưu fixture · LUẬT CHUẨN HOÁ trước khi
  so · LUẬT CẬP NHẬT: không `-u` phản xạ, PR phải dán diff golden + nêu lý do · CI không tự tạo
  snapshot mới), và một golden test ví dụ chạy được trong dropins. Trước đây golden chỉ được nhắc
  thoáng qua ở `01-process-and-standards.md:11` và `03-tech-selection...:237` — không luật cập nhật,
  nên golden đỏ sẽ bị `vitest -u` làm xanh, tức ghi nhận bug thành giá trị kỳ vọng mới.

### Changed
- **"Sửa bug phải có test tái hiện ĐỎ trước khi sửa" nâng từ luật của một lệnh lên luật của khung:**
  trước đây chỉ sống trong `/completion` + `/audit-full`, nên một PR `fix` thường hoặc một phiên
  `/auto` không đi qua nhánh đó. Nay có ở `CLAUDE.md` §3.6/§5, Báo cáo xác thực §7 (dòng
  `Test tái hiện ✅/❌/n-a`), `/gate` và `/debug`. Đồng thời làm rõ ranh giới đang bị đọc lẫn:
  vòng đỏ-xanh TỔNG QUÁT là **khuyến nghị**, test-tái-hiện-trước cho bug là **bắt buộc**; cố ý
  KHÔNG ép test-trước lên scaffolding/rename/docs.
```

## 19. Risk, assumptions và open decisions

| Item | Verification/mitigation | Owner | Due | Decision |
| --- | --- | --- | --- | --- |
| Golden thành test giòn rồi bị vô hiệu hoá | Phạm vi hẹp (chỉ đầu ra tuần tự hoá ổn định) + luật chuẩn hoá là bắt buộc + AC-4 chạy 2 timezone | AI | PR-C | Đã khoá bằng AC |
| `vitest -u` phản xạ vẫn xảy ra | Không chống được bằng script; chống bằng **diff golden bắt buộc có trong PR** để người review thấy | AI | PR-B | Chấp nhận rủi ro còn lại |
| FR-3 cảnh báo thay vì chặn → dễ bị bỏ qua | Cố ý: chặn cứng sẽ dạy người dùng khai sai loại commit (`chore:` thay `fix:`), tệ hơn. Xem lại sau 10 PR `fix` xem cảnh báo có được tôn trọng | Người dùng | sau | **Chốt: cảnh báo** |
| Hành vi Vitest khi thiếu snapshot ở CI | FR-9/AC-3 phải **chạy thật** trước khi viết tài liệu (CLAUDE.md §4) | AI | PR-C | Chưa xác minh — **không chặn approve**, chặn merge PR-C |
| Chồng file với spec 1 (`CLAUDE.md`, `quality-supplements.md`) | FIFO §8: spec 1 merge trước, PR-A rebase | AI | PR-A | Đã có kế hoạch |
| Có nên thêm mutation testing (`xboss`) không? | Capability riêng, §5 đã loại | Người dùng | sau | **Để mở, không chặn** |

Không còn blocking decision.

## Approval

- [ ] Product/scope
- [ ] UX/a11y — _không áp dụng (không có UI), xác nhận bỏ qua_
- [ ] Architecture/API/data
- [ ] Security/privacy/cost
- [ ] Test/telemetry/rollout/rollback
- [ ] Blocking decisions closed

**Conclusion:** **Approved for implementation**
**Approver/date:** donghanhcungban.org@gmail.com / 2026-09-12

<!-- contract-exempt: scripts/verify-dropins.sh — gỡ khỏi repo khung theo ADR-0004 (bỏ scaffold Web mặc định, commit 98546db); spec này viết TRƯỚC quyết định đó nên giữ nguyên làm hồ sơ lịch sử -->
<!-- contract-exempt: package.json — file của DỰ ÁN ĐÍCH, repo khung cố ý không có (CLAUDE.md §10) -->
