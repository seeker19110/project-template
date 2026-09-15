# Feature spec: Cổng máy CC cho mã shell (hai trần: hàm 12, thân script 45)

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Nối tiếp PR #123: cổng CC mới phủ Python, còn ~36 file shell (phần lớn mã chạy được của repo khung) không có phép đo nào |
| Spec owner | Phiên AI 2026-09-15 |
| State | **Approved for implementation** |
| Approver / date | donghanhcungban.org@gmail.com — 2026-09-15 ("thêm cổng CC cho shell luôn", chốt hai trần + vendor qua `AskUserQuestion`) |
| Last updated | 2026-09-15 |

## 1. Problem, user và evidence

PR #123 dựng cổng CC cho Python và nêu thẳng giới hạn ở "Reviewer focus #2": *trần 12 chỉ áp cho
`scripts/*.py`, shell không được phủ*. Repo khung là **36 file `.sh` / ~4.000 dòng** so với 4 file
`.py` — tức phần lớn mã chạy được đang không có phép đo phức tạp nào. Để nguyên là đúng khuôn
`TRAPS.md` mục 14 (luật có cổng cho nửa dễ, nửa khó thì "chốt bằng quy ước").

## 2. Outcome, baseline, target và guardrails

Đo trước khi chốt trần (`shellmetrics --csv` trên toàn repo, 150 khối):

| Nhóm | Cao nhất trước PR | Số khối > 12 |
| --- | --- | --- |
| Hàm shell | `dev-task.sh::detected_cmd` = 18 | 2 |
| Thân script `<main>` | `check-ci-policy.sh` = 41 | 7 |

- Target: **hàm ≤ 12** (`SH_CC_MAX`, cùng con số với Python) · **thân script ≤ 45**
  (`SH_CC_MAIN_MAX`), đặt ngay trên mức cao nhất đang có → **nắp chặn trượt**.
- Guardrail: không refactor 5 script cổng của chính CI chỉ để vừa một con số — rủi ro cao,
  không làm script dễ đọc hơn (người dùng chốt phương án này).
- Guardrail: `vendor/` bị loại khỏi phép đo (không áp trần của mình lên mã người khác) nhưng
  **không** loại khỏi `shellcheck`/`bash -n`.

## 3. Research current state

- `radon` (PR #123) **không đọc shell**; `lizard` cũng không hỗ trợ shell → cần công cụ khác.
- `shellspec/shellmetrics` v0.5.0 (commit `b3bfff2`): một file bash 491 dòng, MIT, đo CC theo
  hàm **và** theo thân script, có `--csv`. `shellcheck --severity=warning` + `bash -n` chạy sạch
  trên chính nó → vendor được mà không phải nới cổng lint nào.
- Không tự viết bộ đếm CC (CLAUDE.md §3 A4 nấc 3–5: thứ đã có thì dùng lại).
- `scripts/_test-lib.sh`, khuôn "thiếu công cụ → ĐỎ chứ không skip" của `check-python-complexity.sh`
  → dùng lại nguyên.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Không làm | 0 công | Phần lớn mã chạy được của repo không có phép đo | ❌ |
| Tự viết bộ đếm CC cho shell | không thêm mã bên thứ ba | Viết lại thứ đã có, sai số thầm lặng | ❌ |
| Một trần 12 cho cả hàm lẫn `<main>` | nhất quán một con số | Phải refactor 5 script cổng của chính CI; diff lớn, rủi ro cao | ❌ (người dùng bác) |
| Chỉ đo và cảnh báo, không chặn | rẻ | Đúng khuôn `TRAPS.md` mục 14 | ❌ (người dùng bác) |
| **Hai trần (hàm 12 / `<main>` 45), shellmetrics vendor + ghim SHA256** | chặn thật, chạy offline, không đụng script cổng | +491 dòng mã bên thứ ba trong repo | ✅ |
| Tải shellmetrics lúc CI thay vì vendor | repo gọn | Cổng phụ thuộc mạng + GitHub còn sống | ❌ (người dùng bác) |

## 5. Scope / non-goals

**Trong phạm vi:** `vendor/shellmetrics/{shellmetrics,LICENSE,SHA256SUMS,README.md}` ·
`scripts/check-shell-complexity.sh` · `scripts/test-check-shell-complexity.sh` · bước mới trong job
`framework-lint` · hạ CC 2 hàm vượt trần (`scripts/dev-task.sh`, `scripts/maintenance-sweep.sh`) ·
`CODEMAP.md` · `PROGRESS.md` · `CHANGELOG.md`.

**Non-goals:** không refactor script cổng để hạ `<main>` · không thêm job CI mới · không đổi trần
Python · không đụng `.ps1` (PowerShell — không có công cụ tương đương trong phạm vi này).

## 6. User journeys và mọi state

- Mọi khối dưới trần → in số khối đã đo + khối cao nhất, thoát 0. (happy)
- Hàm > 12 hoặc `<main>` > 45 → `::error file=…,line=…` mỗi vi phạm, thoát 1. (vi phạm)
- Checksum bản vendor không khớp → thoát 1 trước khi đo. (công cụ bị sửa)
- Không tìm thấy bản vendor / shellmetrics lỗi / 0 file `.sh` → thoát 1. (cổng rỗng)
- `SH_CC_MAX` / `SH_CC_MAIN_MAX` đặt → dùng đúng trần đó, hai trần độc lập. (ghi đè)

## 7. Functional requirements

- **FR-1** Cổng đo mọi `*.sh` của repo trừ `vendor/` và `node_modules/`.
- **FR-2** Hai trần độc lập: hàm `SH_CC_MAX` (12), thân script `SH_CC_MAIN_MAX` (45).
- **FR-3** Kiểm SHA256 bản vendor trước khi đo; sai → ĐỎ, không đo.
- **FR-4** Mỗi vi phạm in file + dòng + tên khối + CC + trần áp dụng, phân biệt "hàm" / "thân script".
- **FR-5** Job `framework-lint` chạy cổng **và** negative test của nó.
- **FR-6** Hai hàm vượt trần được hạ **không đổi hành vi** (`detected_cmd` 18, `detect_deps_cmd` 13).

## 8. Non-functional requirements

- Chạy ≤ 15s trên repo khung, **không cần mạng** (lý do vendor thay vì tải lúc chạy).
- Không thêm dependency phải cài (khác cổng Python cần `radon` qua pip).

## 9. Acceptance criteria

- **AC-1** `bash scripts/check-shell-complexity.sh` thoát 0 sau PR này.
- **AC-2** `bash scripts/test-check-shell-complexity.sh` xanh, gồm: hàm vượt trần → ĐỎ · thân script
  vượt trần → ĐỎ · nâng trần HÀM không cứu được thân script (hai trần tách rời) · checksum vendor
  sai → ĐỎ · baseline (thân script CC 41 đang có) → XANH.
- **AC-3** Hành vi `detected_cmd` và `detect_deps_cmd` giữ nguyên, chứng minh bằng đối chiếu bản
  cũ ↔ bản mới trên bộ fixture (node/python/go/rust/make/rỗng × mọi task).
- **AC-4** `shellcheck --severity=warning` toàn repo (kể cả `vendor/`) và `bash -n` vẫn sạch.
- **AC-5** `check-docs-consistency.sh` + `check-ci-policy.sh` + cổng CC Python vẫn xanh.

## 10. UX/content/accessibility

n-a (cổng CLI). Thông điệp tiếng Việt, annotation `::error file=…` để GitHub gắn đúng dòng.

## 11. Architecture và code touchpoints

- `vendor/shellmetrics/shellmetrics`, `vendor/shellmetrics/SHA256SUMS`, `vendor/shellmetrics/LICENSE`, `vendor/shellmetrics/README.md`
- `scripts/check-shell-complexity.sh`
- `scripts/test-check-shell-complexity.sh`
- `scripts/dev-task.sh`
- `scripts/maintenance-sweep.sh`
- `.github/workflows/ci.yml`
- `CODEMAP.md`

## 12. API/event contract

Hợp đồng duy nhất là mã thoát 0/1; đầu vào là CSV `file,func,lineno,lloc,ccn,…` của shellmetrics.

## 13. Data contract/migration

n-a.

## 14. Security/privacy/abuse cases

Mã bên thứ ba nằm trong repo → rủi ro chuỗi cung ứng được bịt bằng **ghim SHA256 + cổng kiểm
checksum mỗi lần chạy** (`docs/ops/supply-chain.md`: dependency phải tái lập được và được review).
Giấy phép MIT giữ nguyên cạnh file. Cổng chỉ đọc file, không in nội dung mã.

## 15. Observability và operations

Kết quả trong log job `framework-lint`; vi phạm hiện thành annotation trên diff PR.

## 16. Test/eval plan

`scripts/test-check-shell-complexity.sh` sinh file thăm dò với số nhánh đặt trước (13 nhánh trong
hàm, 46 nhánh ở thân script) rồi dọn sạch — mỗi trần có một ca ĐỎ và một ca đối chứng XANH.

## 17. Slice/PR plan

Một PR: cổng + test + hai refactor bắt buộc để cổng xanh phụ thuộc lẫn nhau.

## 18. Rollout/rollback

Rollback = revert PR (gỡ cả `vendor/shellmetrics`); không có state tồn dư.

## 19. Risk, assumptions và open decisions

- **Rủi ro:** trần `<main>` 45 nới tay hơn hàm nên script cổng có thể phình dần tới sát 45.
  → Giảm bằng chú thích "hạ dần, đừng nâng" ngay tại cổng + con số cao nhất được in mỗi lượt chạy.
- **Giả định:** shellmetrics đọc đúng cú pháp bash của repo (đã chạy thật trên cả 36 file, không lỗi).
- **Open:** chưa phủ `.ps1`; chưa hạ `<main>` của 5 script cổng — để dành cho một đợt tách script riêng.

## Approval

**Approved for implementation** — donghanhcungban.org@gmail.com, 2026-09-15.
