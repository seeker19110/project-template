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
