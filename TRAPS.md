# TRAPS.md — bẫy đã mắc trong repo này

> Sổ bẫy ĐÃ MẮC THẬT của chính bộ khung này, không phải danh sách "nên tránh" chung chung. Mỗi mục
> có ngày + PR/commit + cách rà + test/cổng chốt chặn. Khác `docs/adr/` (ghi **quyết định**): file
> này ghi **lỗi đã xảy ra**. Mẫu rỗng cho dự án đích: `docs/framework/templates/TRAPS.template.md`.
>
> Cách dùng: gặp lỗi lạ → tìm khuôn khớp ở đây trước khi đọc code từ đầu (`/debug` Pha 1 đọc file
> này trước khi ra giả thuyết). Sửa xong → thêm mục mới nếu là khuôn mới, hoặc thêm ngày/PR vào mục
> cũ nếu là **tái phát**.

## 1. Dropins chưa từng biên dịch thì không "chắc chạy được"

Repo khung cố ý không có `package.json` (nó là drop-in cho `create-next-app`) — nên `app/*.tsx`,
`lib/env.ts`, `components/*.tsx`, `eslint.config.mjs`, `vitest.config.ts` **chưa từng được lint hay
biên dịch lần nào** trước khi phát cho dự án đích. Chạy `verify-dropins.sh` lần đầu (dựng dự án
Next.js sạch, copy khung vào, `lint`/`type-check`/`build`/`test` thật) bắt ngay 2 lỗi có sẵn:
`components/theme-toggle.tsx` vi phạm `react-hooks/set-state-in-effect` (rule React Compiler của
`eslint-config-next` bản mới), và `app/sw.ts` không type-check (`TS2552` thiếu lib `webworker`).
*Cách rà*: bất kỳ file dropins mới nào — hỏi "đã có lượt `verify-dropins.sh` nào biên dịch nó chưa,
hay mới chỉ được đọc bằng mắt?". *Chốt chặn*: `scripts/verify-dropins.sh` + `verify-dropins.yml`
(chạy khi PR đụng dropins, hằng đêm, và theo yêu cầu — lịch hằng đêm cũng là cảm biến version drift
vì dùng `create-next-app@latest`). (2026-08-08, PR #43)

## 2. `copy-framework.ps1` cần BOM cho PowerShell 5.1, dù `.sh` không cần

Windows PowerShell 5.1 mặc định đọc script theo ANSI; file UTF-8 **không BOM** làm hỏng ký tự tiếng
Việt và gây lỗi parse (`Missing closing '}'`, chuỗi bị cắt sớm ở ký tự em-dash). PowerShell 7 đọc
UTF-8 không BOM nên **không lộ lỗi khi test bằng PowerShell 7** — bẫy ẩn đúng ở chỗ máy dev hiện đại
không thấy gì sai. *Cách rà*: mọi thay đổi `.ps1` phải test bằng PowerShell **5.1** thật (không chỉ
pwsh 7), và kiểm byte đầu file là `EF BB BF`. *Chốt chặn*: ghi chú "PHẢI lưu UTF-8 có BOM" ở đầu file
+ `.gitattributes` giữ nguyên BOM (`*.ps1 text eol=lf`) + `[Console]::OutputEncoding = UTF8`
(try/catch) để chữ tiếng Việt in đúng. (2026-07-01, PR #18, commit `59a280f`)

## 3. `copy-framework.sh` thiếu file → hàng rào ở dự án đích no-op ÂM THẦM

`copy-framework.sh`/`.ps1` từng **không copy** `scripts/dev-task.sh` + `usage-estimate.sh` sang dự án
đích. Hệ quả không phải lỗi ồn ào: hook auto-format, cổng chặn commit đỏ, và nhắc quota ở dự án đích
đều **lặng lẽ thành no-op** — dự án đích tưởng mình có hàng rào nhưng không có gì chạy. Cùng PR, bản
`.sh` còn có lỗi `cp -R` gây **lồng thư mục** khi chạy script lần hai (`docs/framework/framework`,
`hooks/hooks`) — bản `.ps1` đã làm đúng, `.sh` thì chưa. *Cách rà*: sau bất kỳ thay đổi cấu trúc
`docs/framework/`, `.claude/`, `scripts/` — chạy `copy-framework.sh` **hai lần liên tiếp** vào cùng
một thư mục scratch, đếm số file, kiểm không lồng. *Chốt chặn*: `scripts/test-copy-framework.sh`
(chạy cả `.sh` và `.ps1`, chạy lại lần hai để bắt đúng lỗi lồng thư mục này). (2026-07-02, PR #27, commit `6a4ac40`)

## 4. Job CI mới thiếu `permissions:` tường minh → 403 im lặng đến khi chạy PR thật

`gitleaks-action` liệt kê commit của PR qua GitHub API; `GITHUB_TOKEN` mặc định (workflow-level
`contents: read`) thiếu quyền `pull-requests: read` nên action trả `403 Resource not accessible by
integration`. Lỗi này **không xuất hiện khi đọc YAML hay chạy `bash -n`** — chỉ lộ ra khi job thật
chạy trên một PR. *Cách rà*: thêm job CI mới gọi GitHub API (không chỉ chạy shell nội bộ) → tự hỏi
"job này cần quyền gì trên `GITHUB_TOKEN` ngoài `contents: read` mặc định?" trước khi mở PR đầu tiên
dùng job đó. *Chốt chặn*: khai `permissions:` tường minh ở cấp job (không dựa vào mặc định của repo/
tổ chức) — nguyên tắc này đã lan ra mọi workflow của khung (`ci.yml`, `lighthouse-ci.yml`,
`codeql.yml`…). (2026-06-30, commit `366aeec`)

## 5. ShellCheck bắt lỗi ở file `.example.sh` không có shebang (SC2148)

Ngay lần chạy đầu của job `framework-lint` mới thêm (bash -n + ShellCheck mức error), CI đỏ vì
`project-commands.example.sh` và `usage-budget.example.sh` không có `#!/usr/bin/env bash` —
ShellCheck không xác định được target shell. Cả hai file được `source` bằng bash
(`dev-task.sh: . "$DECL"`), nên shebang không chỉ để né lint mà đúng là thiếu sót thật.
*Cách rà*: mọi file `.sh`/`.example.sh` mới phải có shebang **trước khi** commit, không chờ CI báo.
*Chốt chặn*: job `framework-lint` (`bash -n` mọi `*.sh` + `shellcheck --severity=error`) — chạy cả
khi repo khung chưa có `package.json`. (2026-07-02, PR #27, commit con trong `6a4ac40`)

## 6. `verify-dropins.sh` đỏ vì ERESOLVE — thiếu bump cùng lượt của một transitive dependency

Thêm `vitest` vào lệnh cài của `verify-dropins.sh` mà không nâng `@types/node` cùng lượt → `npm ci`
báo `ERESOLVE` (xung đột phiên bản peer dependency), làm job `verify-dropins` đỏ từ 2026-09-04 mà
không ai để ý ngay vì workflow đó chỉ chạy khi PR đụng dropins, hằng đêm, hoặc theo yêu cầu — không
chạy trên mọi PR như `ci.yml`. *Cách rà*: thêm/nâng một dependency cài trong `verify-dropins.sh` →
chạy `npm ci` thật ở bước đó (không chỉ `npm install` cục bộ có cache cũ) trước khi tin cổng xanh.
*Chốt chặn*: `verify-dropins.yml` chạy hằng đêm (không chỉ khi có PR đụng dropins) — nhưng bài học
thật là: **cổng chạy không thường xuyên (hằng đêm/theo yêu cầu) cần được xem lại log định kỳ**, không
chỉ dựa vào nó tự báo đỏ trên PR đang mở. (2026-09-06, PR #61, commit `d0baf40`)

## 5. Cổng đòi thứ bot không thể có → PR bảo mật kẹt vĩnh viễn, nhìn như "PR chưa đạt chuẩn"

**Ngày/PR:** 2026-09-12, audit toàn diện (F-001) — bẫy đã âm thầm hoạt động từ 2026-08-24.

**Khuôn lỗi:** required check `pr-policy.yml: metadata` yêu cầu PR body chứa 6 mục của PR template.
Dependabot không điền được → check **không bao giờ xanh** → 5 PR nâng cấp (3 trong đó là công cụ
bảo mật: gitleaks, dependency-review, codeql) kẹt 19 ngày. Nhìn từ ngoài giống "PR chưa đạt chuẩn,
chờ người bổ sung", nên không ai lần ra rằng nó **không thể** đạt chuẩn.

Tổng quát: **cổng áp cho tác nhân không có khả năng thoả mãn nó** biến thành deadlock im lặng.
Nguy hiểm hơn cổng thiếu, vì nó trông như đang làm việc.

**Cách rà:**
- Với mỗi required check, hỏi: *ai/cái gì tạo PR loại này, và họ CÓ THỂ làm nó xanh không?*
  (dependabot, renovate, github-actions, release-please…)
- Có PR nào mở > 7 ngày với cùng một check đỏ? → `list_pull_requests` + xem `conclusion` của
  workflow run theo nhánh. PR bot cũ đọng lại là dấu hiệu, không phải sự lười.

**Cổng chốt chặn:** `pr-policy.yml` miễn trừ `BOT_ACTORS` khỏi yêu cầu mục template (vẫn giữ kiểm
tiêu đề conventional). Chưa tự động hoá được phần "phát hiện PR đọng" — xem W-105.

## 6. `git checkout <file>` xoá sạch thay đổi chưa commit — không cần `reset --hard`

**Ngày/PR:** 2026-09-12, trong lúc chạy `/completion` Pha 3.

**Khuôn lỗi:** chạy negative test bằng cách xoá `docs/FEATURE-MAP.md` rồi `git checkout` để phục
hồi — lệnh này lấy lại **bản đã commit**, nên mọi sửa chưa commit trong file đó (một sửa tham
chiếu backtick) biến mất không cảnh báo. `block-dangerous-git.sh` chặn `reset --hard` nhưng
**không** chặn `checkout <file>` / `restore <file>` vì hai lệnh này dùng hợp lệ hàng ngày.

**Cách rà:** trước khi `git checkout/restore <file>`, chạy `git diff -- <file>` — có output nghĩa
là đang sắp mất phần đó. Với negative test, nên copy file ra scratchpad rồi copy trả lại, **không**
dùng `git checkout`.

**Cổng chốt chặn:** không có cổng máy (chặn `checkout` sẽ gây khó chịu hơn lợi). Chốt bằng quy ước
trong `docs/CONVENTIONS.md` §A: negative test phải phục hồi bằng `cp` từ bản sao, không bằng Git.

## 7. PR dependabot chỉ sửa file TỒN TẠI LÚC NÓ ĐƯỢC TẠO — file mới mang lại phiên bản cũ

**Ngày/PR:** 2026-09-12, ngay sau khi merge #64 rồi #53–#57 (W-101).

**Khuôn lỗi:** PR #53 (tạo 24/08) nâng `actions/github-script` 7.0.1 → 9.0.0 trong 2 file có mặt
lúc đó. Một giờ trước khi merge nó, PR #64 thêm `.github/workflows/stale-pr-alert.yml` — và tôi
copy dòng `uses:` từ một workflow cũ, tức **ghim lại v7.0.1 (node20)**. Merge cả 5 PR dependabot
xong, `main` **vẫn còn** một action node20: chính file tôi vừa thêm. Thay đổi của tôi mang ngược
vào đúng vấn đề mà PR đó đang sửa.

Tổng quát: PR dependabot là **ảnh chụp danh sách file tại thời điểm tạo**. Thêm file mới trong lúc
PR dependabot đang treo → file mới không nằm trong phạm vi nó. Dependabot sẽ mở PR mới ở lượt quét
sau (hệ thống tự lành), nhưng khoảng giữa thì `main` sai mà mọi check đều xanh.

**Cách rà:** sau khi merge một loạt PP dependabot, **đo lại trên `main`** thay vì tin số PR đã merge:

```
grep -rhoE "uses: [^ ]+@[0-9a-f]{40}" .github/workflows/*.yml | sed 's/uses: //' | sort -u \
| while read ref; do repo="${ref%@*}"; sha="${ref#*@}"; \
    curl -sS "https://raw.githubusercontent.com/$repo/$sha/action.yml" | grep -oE "node[0-9]+" | head -1; done
```

Khi copy một dòng `uses:` từ workflow khác: kiểm xem có PR dependabot đang treo cho action đó không.

**Cổng chốt chặn:** `check-ci-policy.sh` CP-2 chỉ kiểm *đã ghim SHA*, **không** kiểm runtime — kiểm
runtime cần gọi mạng, mà cổng phải chạy offline. Chốt bằng quy ước: lệnh đo ở trên chạy tay sau mỗi
lượt merge dependabot (đã ghi vào `docs/CONVENTIONS.md` §D).

## 8. `PROGRESS.md` lỗi thời sau khi PR merge — mô tả nhánh "đang làm" đã thực ra đã merge

**Ngày/PR:** 2026-09-12, phát hiện khi người dùng yêu cầu quét kỹ lại sau `/audit-full`.

**Khuôn lỗi:** `PROGRESS.md` ghi "Nhánh đang làm: `claude/remove-web-scaffold-layer2`... đang hoàn
thiện trên nhánh riêng trước khi mở PR", nhưng thực ra PR #67 (nhánh đó) **đã merge từ trước**, và
PR #68 sau đó cũng đã merge — không phiên nào quay lại cập nhật file. Vì `PROGRESS.md` là văn xuôi
tự do, không có gì đối chiếu nó với git thật, nên lệch **hoàn toàn im lặng**: phiên sau đọc phải
trạng thái cũ, dễ tưởng còn việc dở (mở PR cho nhánh đã không còn tồn tại) hoặc bỏ sót việc mới
(PR #68) đã xong.

Tổng quát: **bất kỳ tài liệu trạng thái nào mô tả một mốc git (nhánh/SHA/PR) đều có thể lỗi thời
ngay khi mốc đó thay đổi mà không ai quay lại sửa** — không có cổng máy đối chiếu là lỗi chắc chắn sẽ
xảy ra, chỉ là chưa biết lúc nào.

**Cách rà:** trước khi tin `PROGRESS.md`, đối chiếu nhanh: `git branch -r` xem nhánh nêu tên còn
tồn tại không; `git log origin/main` xem SHA "đã đối chiếu" có phải HEAD hiện tại không.

**Cổng chốt chặn:** `scripts/check-progress-freshness.sh` (PF-1: SHA đã đối chiếu là tổ tiên của
HEAD; PF-2: nhánh nêu trong "Nhánh đang làm" còn tồn tại trên remote) + job CI `progress-freshness`
(chỉ chạy khi push vào `main`, `needs:` của `gate`) + `CLAUDE.md` §8 bắt buộc cập nhật `PROGRESS.md`
ngay sau khi quay về `main`.

## 9. Nhãn "C1 — MẶC ĐỊNH" gây thiên lệch web cho dự án không phải web

**Ngày/nguồn:** 2026-09-13, phát hiện qua phân tích ngoài phiên.

**Khuôn lỗi:** `docs/framework/03-tech-selection-and-proactive-advice.md` đặt nhãn `C1 — Hồ sơ Web app (MẶC ĐỊNH)` và `PROJECT.md` ghi "mặc định theo hồ sơ Web app" — trong khi `README`, `CLAUDE.md` và `existing-project-adoption.md` đều khẳng định khung **không có stack mặc định**. Với agent thiếu cẩn thận, hai chữ "MẶC ĐỊNH" có thể dẫn đến thiên lệch chọn Next.js/React/TS + cổng Lighthouse/a11y/CWV cho dự án backend thuần, CLI, plugin Revit/AutoCAD hay bất kỳ loại nào không phải web. Trong các phiên brownfield lặp lại hoặc khi context bị nén, agent có thể không đọc đủ chú thích và áp hồ sơ C1 như mặc định thật sự.

*Cách rà*: trước khi đề xuất stack/cổng, kiểm tra `PROJECT.md` mục 0 (Loại dự án & Hồ sơ) đã được điền chưa. Nếu chưa điền, chạy PHẦN A0 của KHUNG-3 để phân loại — không giả định C1 vì "đây là mặc định". Nhãn "MẶC ĐỊNH" trong C1 chỉ có nghĩa file cấu hình **drop-in** của khung giả định hồ sơ này, không có nghĩa mọi dự án nên dùng C1.

*Cổng chốt chặn*: làm rõ nhãn C1 trong `03-tech-selection-and-proactive-advice.md` và chú thích nguồn gốc trong `PROJECT.md` để agent luôn thấy ngữ cảnh giải thích khi đọc hai chữ "MẶC ĐỊNH". (2026-09-13)

## 11. Thêm code chạy được mà không nối cổng CI → code chết, không ai biết nó tồn tại

*Ngày: 2026-09-13 · PR #89, #91 (mắc) → PR sửa: audit 2026-09-13.*

PR #89 và #91 thêm 4 engine Python (`spec-compiler.py`, `arch-health-radar.py`,
`subagent-dispatch.py`, `telemetry-log.py`, ~650 dòng) **kèm cả self-test** —
`test-next-gen-engines.sh` và `test-telemetry-and-dispatch.sh` — nhưng **không nối self-test nào
vào `ci.yml`**, và không thêm dòng nào vào `CODEMAP.md` hay `CLAUDE.md` §1.

Hai hậu quả, cái thứ hai nặng hơn: (a) code không có cổng bảo vệ, sửa gãy không ai bắt; (b) **code
chết trên thực tế** — một phiên AI mới chỉ đọc `CLAUDE.md`/`CODEMAP.md` nên không bao giờ biết 4
engine đó tồn tại, dù chúng chạy hoàn hảo. Viết self-test rồi không cắm vào CI tạo cảm giác an toàn
giả: `ls scripts/` thấy có test, nhưng không lần chạy nào là bắt buộc.

Lỗ hổng lọt vì cổng cũ chỉ kiểm hai chiều **lệnh ↔ `CLAUDE.md`** (mục 3 của
`check-docs-consistency.sh`), không kiểm **script ↔ `CODEMAP.md`**. Khi thêm cổng mới, nó bắt luôn
2 script cũ cũng chưa khai (`usage-estimate.sh`, `ci-workflow-policy.test.ts`) — tức khuôn này đã
âm thầm lặp lại nhiều lần trước đó.

**Cách rà:** với mọi PR thêm file vào `scripts/`, hỏi đúng 3 câu — (1) có job/step CI nào *bắt buộc*
chạy nó không? (2) có dòng trong `CODEMAP.md` không? (3) một phiên AI mới, chỉ đọc `CLAUDE.md`, có
biết nó tồn tại không? Không đủ 3 thì chưa xong, dù test có xanh.

**Cổng chốt chặn:** `scripts/check-docs-consistency.sh` **mục 6** (mọi `scripts/*.{sh,py,json,ts}`
phải được `CODEMAP.md` khai; miễn trừ phải ghi lý do ở `CODEMAP_EXEMPT`) + 2 step mới trong job CI
`framework-lint` chạy `test-next-gen-engines.sh` và `test-telemetry-and-dispatch.sh` + negative-test
của chính mục 6 trong `scripts/test-check-scripts.sh` (cả chiều đỏ lẫn chiều xanh).

## 12. `test-check-scripts.sh` chỉ kiểm được cổng ĐÃ COMMIT — sửa cổng mà chưa commit thì test mới xanh giả

*Ngày: 2026-09-13 · phát hiện khi thêm mục 6 ở trên.*

`setup_repo()` dựng sandbox bằng `git archive HEAD` — **chỉ lấy file đã commit**. Nên khi vừa thêm
mục kiểm mới vào `check-docs-consistency.sh` (chưa commit) rồi chạy `test-check-scripts.sh` ngay,
sandbox vẫn chạy **bản cũ** của cổng: ca negative (`rc` phải = 1) đỏ vì cổng cũ không có mục đó, còn
ca đối chứng (`rc` phải = 0) **xanh giả** — xanh vì cổng không kiểm gì, không phải vì nó kiểm đúng.

Nguy hiểm ở chỗ nếu chỉ viết ca đối chứng (không viết ca negative), bộ test sẽ báo xanh toàn bộ và
người viết tin rằng cổng mới đã hoạt động. Đây là lý do mỗi mục kiểm **phải có cả ca đỏ lẫn ca xanh**
(nguyên tắc F-002/G-001 áp cho chính mình).

**Cách rà:** sửa bất kỳ `check-*.sh` nào → **commit trước** rồi mới chạy `test-check-scripts.sh`;
nếu một ca negative mới báo `rc=0`, nghi ngờ "chưa commit" *trước* khi nghi ngờ logic cổng.

**Cổng chốt chặn:** không có cổng máy (bản chất là thứ tự thao tác) — chốt bằng chính mục này +
ghi chú trong đầu `scripts/test-check-scripts.sh`.

## 13. Commit của phiên AI không gắn được tài khoản GitHub → auto-merge kẹt, triệu chứng không nói ra nguyên nhân

*Ngày: 2026-09-13 · PR #93.*

Ruleset `.github/rulesets/main.json` bật `require_extra_approval_for_unattributed_changes`.
Phiên AI commit bằng một email **chưa liên kết** tài khoản GitHub → GitHub coi đó là thay đổi
"unattributed" và **chặn auto-merge**, dù `required_approving_review_count` = 0 và **toàn bộ
required check đều xanh**.

Triệu chứng đánh lạc hướng: PR ở trạng thái `blocked` nhưng mọi cổng đều ✅, không thông báo nào
nói lý do. Rất dễ đi tìm nhầm trong CI. Dấu hiệu nhận ra: gọi API commit thấy **thiếu** trường
`author.login` (commit đã gắn được sẽ có), và trên giao diện GitHub avatar tác giả không hiện.

Điểm dễ mắc thứ hai: sửa bằng `--reset-author` sẽ đặt **cả** author lẫn committer, làm mất danh
tính harness (và mất chữ ký Verified). Git tách hai trường này nên **không phải đánh đổi**:
author quyết định attribution, committer quyết định chữ ký.

**Cách rà:** trước khi mở PR từ phiên AI — `git log -1 --format='%an <%ae> | %cn <%ce>'`; email
author phải nằm trong `Settings → Emails` của tài khoản GitHub.

**Cổng chốt chặn:** không có cổng máy trong repo (thuộc cấu hình môi trường chạy, không phải nội
dung repo) — chốt bằng mục **4b** trong `docs/framework/new-project-runbook.md` + mục này.

## 14. `git checkout -b` thất bại vì nhánh đã tồn tại → commit rơi nhầm vào `main`

*Ngày: 2026-09-13 · mắc ngay trong phiên xử lý audit 2026-09-13.*

`git checkout -b <nhánh>` báo `fatal: a branch named '<nhánh>' already exists` và **giữ nguyên
nhánh đang đứng**. Nếu lệnh đó nằm trong một chuỗi `&&`/nhiều lệnh và output không được đọc kỹ,
các lệnh sau vẫn chạy — nhưng trên **nhánh cũ**. Hậu quả trong phiên này: commit đồng bộ
`PROGRESS.md` rơi vào `main` cục bộ, rồi `git push origin <nhánh>` lại đẩy **nhánh cũ** (nội dung
đã merge từ trước) lên, tạo PR #94 sai nội dung mà vẫn bật auto-merge.

May mắn PR đó squash ra **commit rỗng** nên `main` không thụt lùi — nhưng đó là may, không phải
do cổng nào chặn.

**Cách rà:** sau mỗi lần chuyển nhánh, xác nhận bằng `git branch --show-current` **trước khi**
commit; đừng tin lệnh checkout đã thành công chỉ vì các lệnh sau nó không lỗi. Dùng
`git switch -c <nhánh> || git switch <nhánh>` để ý định "tạo hoặc chuyển sang" là tường minh.
Trước khi push, đối chiếu `git log --oneline -1 <nhánh>` với commit vừa tạo.

**TÁI PHÁT 2026-09-14 (PR #111), qua một đường khác và tệ hơn:** lần này `git checkout -B <nhánh>`
không *thất bại* — nó **không hề chạy**. Lệnh đó nằm chung một dòng `&&` với một heredoc `python3`,
và cả dòng bị chính `block-dangerous-git.sh` chặn ở `PreToolUse` (bug chặn oan ở mục 18). Lệnh bị
chặn trước khi thực thi ⇒ không có output lỗi nào của git để mà đọc — dấu hiệu sớm ở mục này
("đừng tin checkout đã thành công chỉ vì lệnh sau không lỗi") **không áp dụng được**, vì không có
lệnh sau nào chạy cả. Ba commit sửa hook rơi vào `main` cục bộ; `git push -q -u origin <nhánh>` đẩy
**nhánh cũ** (đã merge) lên, tạo PR #111 sai nội dung.

Hai thứ làm nó sống lâu thêm:
- `git push -q` nuốt output, và tôi **không đối chiếu remote sau khi push** — tin vào dòng "Create a
  pull request for ..." mà dòng đó xuất hiện cả khi ref được tạo từ một nhánh khác.
- Hàng rào này chính là thứ đang được sửa trong PR đó: một hook chặn oan không chỉ phiền, nó **làm
  hỏng lệnh ghép theo cách không để lại dấu vết**.

**Cách rà (bổ sung, đây là phần đắt nhất):** sau **mỗi** `git push`, đối chiếu hai SHA trước khi nói
bất kỳ câu nào về kết quả — `git fetch origin && git rev-parse HEAD` so với
`git rev-parse origin/<nhánh>`. Bằng nhau mới là đã vào. Đây đúng `CLAUDE.md` §4 bước 1–3 (xác định
lệnh CHỨNG MINH được câu mình định nói, chạy đủ, đọc hết output) áp cho thao tác git. Và: **không
ghép `git checkout` vào cùng một dòng với lệnh khác** — chạy riêng, đọc `git branch --show-current`.

**Cổng chốt chặn:** không có cổng máy (thuộc thao tác, không phải nội dung repo) — chốt bằng mục
này. Dấu hiệu sớm: hook `stop-hook-git-check` báo "unpushed commit(s) on branch 'main'".

## 15. "Đã copy đủ file" không có nghĩa là "dùng được ở dự án đích"

*Ngày: 2026-09-14 · gây ra ở PR #93, phát hiện khi đánh giá tổng thể.*

PR #93 bắt `telemetry-log.py` đọc `scripts/model-rates.json` và **thoát mã 1** nếu thiếu (cố ý:
thà không có báo cáo còn hơn báo cáo chi phí bằng số bịa). Nhưng `copy-framework.sh`/`.ps1`
**không phát** file dữ liệu đó, trong khi vẫn phát `telemetry-log.py`. Hậu quả:
`telemetry-log.sh --record` **chết trên MỌI dự án đích**, suốt nhiều PR, mà không cổng nào kêu.

Vì sao lọt: `test-copy-framework.sh` kiểm **đúng file có được copy không** — cấu trúc, không phải
hành vi. Self-test đi kèm (`test-telemetry-and-dispatch.sh`) bắt được ngay, nhưng **chưa ai chạy
nó BÊN TRONG dự án đích**. Khung tự kiểm chính mình rất kỹ, còn thứ nó **phát đi** thì không.

Cùng lượt smoke đầu tiên còn lộ thêm 2 ca nữa, đều cùng gốc "chạy ở repo khung thì xanh, ở dự án
đích thì không": `spec-compiler --compile-all` im lặng không in gì khi chưa có `docs/specs/`
(dự án mới thì đương nhiên chưa có), và ca AHR-3 assert "độ phủ phải TỤT" trong khi dự án đích
chưa có `ci.yml` nên độ phủ đã là 0 — không có gì để tụt.

**Cách rà:** mỗi khi thêm/sửa thứ được `copy-framework` phát đi, hỏi hai câu — (1) nó có phụ thuộc
file/thư mục nào mà dự án đích CHƯA có không? (2) đã chạy thật nó trong một dự án đích trống chưa?
Trạng thái "trống" (chưa có spec, chưa có CI, chưa có budget) là HỢP LỆ, phải xử lý tử tế chứ
không được coi là lỗi.

**Cổng chốt chặn:** `scripts/test-copy-framework.sh` mục "Smoke" — dựng dự án đích thật rồi CHẠY
các self-test được phát kèm ngay trong đó; đỏ là chặn. Chạy trong job CI `copy-framework-smoke`.

## 16. Push lại cùng nhánh cùng ngày chỉ "thành công" nhờ trùng giây — không thật sự an toàn

*Ngày: 2026-09-14 · phát hiện khi viết test cho `scripts/maintain-cron.sh` (agent bảo trì chạy
không giám sát trên VPS/cron).*

`maintain-cron.sh` thiết kế: nhánh `maint/auto-<ngày>` chạy lại cùng ngày thì `git reset --hard`
về nhánh nền rồi commit lại từ đầu (không cộng dồn). Bản đầu push bằng `git push -u origin
<nhánh>` (không force). Test tay chạy hai lượt LIÊN TIẾP RẤT NHANH (cùng giây đồng hồ) thấy xanh —
kết luận sai là "ổn". Viết thêm ca test 5 lượt (7a→7e, có xử lý tốn vài giây giữa các lượt) mới lộ
ra: commit thứ hai có nội dung/parent giống hệt commit thứ nhất nhưng **khác giây** → khác SHA →
không phải hậu duệ của commit cũ trên remote → git từ chối `non-fast-forward`. Lượt test nhanh
trước đó "xanh" thuần tuý vì hai commit **trùng giây tuyệt đối** nên trùng SHA, push thành no-op.

**Bài học tổng quát:** một test tay chạy đủ NHANH để né race condition không chứng minh gì — thời
gian trôi qua giữa hai bước là một BIẾN, không phải hằng số; test tự động phải cố tình để đủ thời
gian trôi qua (nhiều bước xen giữa, hoặc gọi mạng/subprocess thật) chứ không chỉ lặp lại lệnh liền
kề nhau.

**Sửa:** `git fetch origin <nhánh>` trước, rồi `git push --force-with-lease=<nhánh>` — CHỈ áp cho
nhánh do chính wrapper sở hữu (`maint/auto-*`), không bao giờ cho nhánh chính; `--force-with-lease`
(khác `--force` thường) bị remote từ chối nếu ai đó đã đẩy lên đúng nhánh đó sau lượt fetch.

**Cổng chốt chặn:** `scripts/test-maintain-cron.sh` mục 4 — hai lượt chạy cách nhau qua nhiều bước
xử lý thật (không phải `sleep` giả), xác nhận push thành công và không cộng dồn commit.

## 17. Biến gán trong hàm gọi qua `$(...)` không bao giờ thấy được ở ngoài — kể cả có khai `local`

*Ngày: 2026-09-14 · cùng lượt viết `maintain-cron.sh` (bước tự mở PR qua GitHub REST API).*

Một hàm `http_call()` ghi đường dẫn file tạm vào biến `http_body_file` (khai `local` ở hàm CHA gọi
nó), rồi hàm cha đọc lại biến đó ngay sau khi gọi. Chạy `bash -n`/shellcheck đều sạch. Lỗi chỉ lộ
lúc CHẠY THẬT: `set -u` báo `http_body_file: unbound variable`. Nguyên nhân: mọi lệnh gọi hàm đều
qua `code="$(http_call ...)"` — cú pháp `$(...)` luôn chạy trong **subshell**; một biến được gán
BÊN TRONG subshell đó biến mất khi subshell kết thúc, bất kể biến được khai `local` ở scope nào.

**Bài học tổng quát:** không bao giờ dùng một biến "kênh phụ" (side-channel) để hàm A truyền dữ
liệu ra ngoài trong khi lệnh gọi hàm A lại đi qua command substitution để lấy giá trị IN RA
stdout — hai kênh giao tiếp (biến + stdout) không cùng sống sót qua ranh giới subshell. Dữ liệu
"ra ngoài" thứ hai phải đi qua tham số truyền vào (caller tạo sẵn, truyền path/tên vào) hoặc gộp
chung vào output có cấu trúc, không bao giờ qua biến toàn cục/`local` chia sẻ ngầm.

**Sửa:** đổi `http_call()` nhận đường dẫn file tạm làm THAM SỐ tường minh (`http_call METHOD URL
BODYFILE [DATA]`), caller tự `mktemp` trước khi gọi — không còn kênh phụ nào.

**Cổng chốt chặn:** `scripts/test-maintain-cron.sh` mục 7 — chạy thật hàm `open_pr()` qua `curl`
giả (không mock ở mức hàm bash, chạy nguyên vẹn dưới `set -u`) mới bắt được; test tĩnh không đủ.

## 18. Hook an toàn quét CẢ chuỗi lệnh → chặn oan vì DỮ LIỆU trong lệnh (heredoc/nháy)

**Ngày/PR:** 2026-09-14, khi đồng bộ `PROGRESS.md` sau PR #109. Mắc **hai lần trong cùng một lượt**.

`.claude/hooks/block-dangerous-git.sh` nhận nguyên văn chuỗi lệnh rồi `grep` bốn khuôn nguy hiểm
trên **toàn bộ chuỗi đó**. Nhưng một lệnh shell chứa cả *lệnh* lẫn *dữ liệu*, và dữ liệu nhiều từ
thường nằm trong thân heredoc:

1. `git commit -F - <<EOF … EOF && git push -u origin claude/<nhánh> --force-with-lease` bị quy tắc
   1 ("force-push vào nhánh chính") chặn, vì **commit message** có chữ `main` đứng riêng ("quay về
   main"). Nhánh đích là nhánh riêng.
2. Ngay sau đó, một lệnh `python3 - <<PY … PY` bị quy tắc 2 chặn, vì thân script có chuỗi
   `git reset --hard` làm **dữ liệu fixture** cho test.

Phần trong dấu nháy đã được bỏ từ audit 2026-09-12 — nhưng heredoc thì chưa, và heredoc mới là chỗ
văn bản dài sống.

**Vì sao nghiêm trọng hơn là "phiền":** hàng rào báo oan dạy người ta gõ `ALLOW_DANGEROUS_GIT=1`
thành phản xạ, và lúc đó nó không còn chặn được ca thật. Một cổng bị vô hiệu hoá vì mất lòng tin
nguy hiểm hơn một cổng không tồn tại, vì tài liệu vẫn khai là có.

**Khuôn tổng quát:** *bộ dò tự khớp văn bản của chính thứ nó đang soi*. Cùng họ với bẫy bộ đếm miễn
trừ tự đếm chính mình (`docs/framework/quality-supplements-group2.md` §"Sổ trần cho LỐI THOÁT khỏi
cổng coverage"). Trước khi viết bất kỳ bộ dò dạng grep-trên-văn-bản nào, hỏi: *văn bản mình đang
soi có thể chứa chính mẫu mình đang tìm, dưới dạng dữ liệu, không?*

**Cách rà:** cho bộ dò chạy trên một đầu vào **chứa mẫu dưới dạng dữ liệu** (chuỗi, comment, thân
heredoc, fixture test) và xác nhận nó KHÔNG báo động — đồng thời giữ ca chiều ngược (mẫu thật vẫn
bị bắt). Thiếu một trong hai chiều thì test vô nghĩa.

**Sửa:** bỏ thân heredoc khỏi chuỗi trước khi so khớp (`strip_heredoc_bodies`), cùng lý do đã bỏ
phần trong dấu nháy. Giới hạn còn lại được ghi thẳng trong comment của hook: dữ liệu không nháy,
không heredoc (`… && echo main`) vẫn bị quét — sửa hẳn cần tách lệnh theo `&&`/`;`/`|` rồi chỉ soi
segment bắt đầu bằng `git`, chưa làm vì chưa có sự cố thật.

**Bẫy TRONG chính bản sửa — bản vá đầu tiên NỚI LỎNG hàng rào:** bản đầu nhận heredoc bằng
`<<-?[[:space:]]*DELIM`, nên `echo "a << b"` khớp thành heredoc với delimiter `b`, và **mọi dòng sau
đó bị nuốt** — `git reset --hard` ở dòng kế KHÔNG còn bị chặn. Đo được bằng một lần chạy hook thật,
không phải suy đoán; phát hiện vì tự kiểm lại một ca xấu đã nêu ra miệng mà chưa test (`CLAUDE.md`
§4 bước 1: xác định lệnh nào CHỨNG MINH được câu mình định nói). Sửa: cấm khoảng trắng giữa `<<` và
delimiter.

**Bài học riêng của ca này:** khi bản vá là "bỏ bớt đầu vào khỏi phép quét", hai chiều hỏng KHÔNG
đối xứng — bỏ thiếu thì chặn oan (thấy ngay, có người kêu), bỏ thừa thì **để lọt** (không ai biết).
Mọi bản vá dạng này phải có ít nhất một ca chặn-bắt-buộc đi kèm, không chỉ ca không-chặn-oan.

**Cổng chốt chặn:** `scripts/test-hooks-gate.sh` — mục 8 hai ca không-chặn-oan (`force-push nhánh
RIÊNG, chữ 'main' chỉ nằm trong thân heredoc`; `nhánh riêng có chuỗi 'main' trong TÊN nhánh`) và
mục 7 một ca chặn-bắt-buộc mới (`lệnh nguy hiểm SAU một chuỗi chứa '<<' không phải heredoc`), cùng
5 ca chặn thật có sẵn làm chiều ngược. 15/15.

---

## 19. Rút helper dùng chung làm đỏ test COPY một danh sách file cố định

**Ngày/PR:** 2026-09-14, nhánh `claude/confident-brown-6vb0f7` (commit `4f9e740` gây, vá ở commit kế).

**Khuôn lỗi:** một refactor "gộp boilerplate" tạo file mới (`scripts/_python-exec.sh`) và biến nó
thành **phụ thuộc lúc chạy** của script cũ (`subagent-dispatch.sh`). Mọi test dựng sandbox bằng cách
`cp` một **danh sách file viết tay** vào thư mục tạm đều đỏ ngay — vì danh sách đó không biết về file
mới. Ở đây là `test-maintain-cron.sh:24` và `test-maintain-run.sh:31`.

**Vì sao lọt:** refactor được nghiệm thu bằng đúng hai test *trực tiếp* của bốn wrapper
(`test-next-gen-engines.sh`, `test-telemetry-and-dispatch.sh`) — cả hai chạy trong cây repo thật nên
file mới luôn có mặt. Hai test đỏ nằm ở **script khác, tên không liên quan**, không ai nghĩ tới.
Sai lầm quy trình: "cổng liên quan xanh" bị đọc thành "không đổi hành vi", trong khi `CLAUDE.md` §6
đòi chạy **TOÀN BỘ** test trước khi merge. Xanh giả kiểu này còn nguy hiểm hơn đỏ.

**Cách rà:** sau khi thêm bất kỳ file nào bị `source`/`exec` bởi script khác, grep danh sách copy:
`grep -rn 'cp .*scripts/{' scripts/` — mọi danh sách có chứa script tiêu thụ thì phải có thêm file mới.
Tổng quát hơn: `grep -rn "$(basename FILE_MOI)" scripts/` phải khớp **cả nơi dùng lẫn nơi copy**.

**Cổng chốt chặn:** `scripts/test-maintain-cron.sh` + `scripts/test-maintain-run.sh` (job CI
`framework-lint`) — đã xanh trở lại sau khi thêm `_python-exec.sh` vào hai danh sách `cp`. Đo thật:
exit 0/0 ở `HEAD~1`, exit 9/22 sau refactor, exit 0/0 sau bản vá.

## 20. Test xanh nhưng nhánh cần đo KHÔNG bị chạm — `chmod 000` vô hiệu dưới uid 0

**Ngày/PR:** 2026-09-14, nhánh `claude/cool-gauss-4dk9ln` (bắt được TRƯỚC khi commit, khi tự kiểm).

**Khuôn lỗi:** viết characterization test cho nhánh `except OSError: continue` của
`arch-health-radar.py::_scripts_inventory` bằng cách `os.chmod(file, 0o000)` rồi assert kết quả.
Test **xanh** — nhưng xanh vì đi đường BÌNH THƯỜNG: phiên chạy dưới `uid 0` (container/CI hay gặp),
và root đọc được cả file `0o000`, nên `open()` không hề ném `OSError`. Nhánh định khoá vẫn trần trụi.

**Vì sao nguy hiểm:** đây là xanh giả *ngược chiều* với mục 19. Mục 19 là "cổng liên quan xanh bị đọc
thành không đổi hành vi"; mục này là **chính test được viết ra để khoá một nhánh lại không chạm tới
nhánh đó** — nó sẽ vẫn xanh sau khi ai đó xoá mất `try/except`, đúng thứ nó có mặt để ngăn. Cùng họ
với mục 18 (bộ dò tự khớp văn bản của chính nó): cái sai nằm ở *tiền đề của phép đo*, không ở kết quả.

**Cách rà:** mọi test dựng điều kiện lỗi bằng **quyền truy cập** (`chmod`, chủ sở hữu file, thư mục
chỉ-đọc) đều đáng ngờ — `id -u` bằng 0 thì phần lớn vô hiệu. Kiểm tiền đề trước bằng một dòng:
`python3 -c "open(F).read()"` trên chính file đã `chmod` — đọc được nghĩa là test đang giả.
Bắt buộc hơn: với MỌI test khoá một nhánh, chạy **negative test** — cố ý phá nhánh đó và xác nhận
test chuyển đỏ. Test không đỏ khi phá thì không phải test.

**Cổng chốt chặn:** `scripts/test-engine-characterization.sh` — nay kích lỗi bằng **thư mục trùng
tên** (`IsADirectoryError`, một `OSError`), độc lập hoàn toàn với quyền của người chạy. Đo thật ở
4 negative test trước khi commit: phá `_ci_gate_tests` → 5 failures · phá luật wrapper `.sh`→`.py`
→ 4 failures · phá nối `--context-file` → 1 failure · phá nhánh render `hermes` → 1 error ·
đối chứng khôi phục → OK.

## 21. So bản CŨ với bản MỚI bằng cách chạy file cũ ở thư mục khác → nó quét nhầm cây

**Ngày/PR:** 2026-09-14, nhánh `claude/cool-gauss-4dk9ln` (mắc HAI lần liên tiếp trong cùng một phiên).

**Khuôn lỗi:** để chứng minh refactor không đổi hành vi, chép bản cũ ra thư mục tạm
(`git show HEAD:scripts/x.py > /tmp/.../x.py`) rồi chạy hai bản và `diff` đầu ra. Cả bốn engine của
khung đều tính `ROOT_DIR = dirname(dirname(abspath(__file__)))`, nên bản cũ ở thư mục tạm quét
**thư mục tạm**, không phải repo. Kết quả `diff` khác nhau toé loe và *trông như* refactor đã phá
hành vi — trong khi thật ra phép đo sai. Lần hai y hệt với `AGENTS_DIR` của `subagent-dispatch.py`.

**Vì sao lọt:** phép so sánh có vẻ hiển nhiên đúng nên không ai kiểm tiền đề của nó. Nguy hiểm cả hai
chiều: lần này nó báo động giả, nhưng cùng cơ chế đó có thể cho hai bản cùng quét một cây RỖNG rồi
trả về "IDENTICAL" — một chứng minh vô nghĩa được đọc thành bằng chứng mạnh.

**Cách rà:** đừng so bằng cách chạy file ở vị trí khác. Nạp **cả hai** bản làm module
(`importlib.util.spec_from_file_location`), **ghi đè `ROOT_DIR`/`AGENTS_DIR` của cả hai vào CÙNG một
cây cố định** (dựng bằng `git archive HEAD | tar -x -C <thư mục>`), rồi gọi thẳng hàm và so giá trị
trả về. Luôn in kèm một con số nhận dạng của cây đó (số file, điểm sức khoẻ) để thấy ngay nếu nó rỗng.

**Cổng chốt chặn:** không có cổng máy — đây là kỷ luật của người chứng minh, thuộc `CLAUDE.md` §4
bước (4) "output có khớp đúng câu định nói không". Ghi lại ở đây vì khuôn này sẽ quay lại ở mọi lần
refactor engine sau.
