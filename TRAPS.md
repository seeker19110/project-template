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
