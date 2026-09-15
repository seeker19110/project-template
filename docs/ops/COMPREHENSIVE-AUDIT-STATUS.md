# Trạng thái Audit toàn diện

> AI đọc/ghi file này để biết quét tới đâu — cho phép tiếp tục qua nhiều phiên.
> Trạng thái mỗi nhóm: ⬜ Chưa quét · 🔄 Đang dở · ✅ Xong · ➖ Không áp dụng.
>
> **Chủ thể:** chính bộ khung `projects-template` (không phải app web) — xem `docs/FEATURE-MAP.md`.
> "Tính năng" = năng lực khung cung cấp cho dự án đích; code nghiệp vụ = 33 script engine trong
> `scripts/` + hệ cổng CI. `PROJECT.md` trống là **đúng chủ ý** (mẫu cho dự án đích điền), không
> phải dấu hiệu chưa có dự án — đây là lý do Bước -1 của `/audit-full` KHÔNG dừng ở repo này.

- Lần quét bắt đầu: **RESET 2026-09-15** (lượt trước: base `709cc86`, 2026-09-12 — đã trôi 51 commit)
- Base: `98ccd6f` (`origin/main`, sau PR #143)
- Hồ sơ dự án áp dụng (KHUNG-3 PHẦN C): **C5 CLI/thư viện** (tiệm cận) — tập script shell/Python
  + tài liệu, không runtime, không UI, không CSDL
- Giai đoạn: **GIAI ĐOẠN 2 (xử lý)** — người dùng duyệt TOÀN BỘ 4 batch ngày 2026-09-15

| # | Nhóm | Trạng thái | Tóm tắt phát hiện (số lượng theo mức độ) | Cập nhật lần cuối |
|---|------|-----------|-------------------------------------------|---------------------|
| 1 | Kiến trúc & thiết kế | ✅ Xong | Cao 0 · **Trung 2** (A-1, A-3) · Thấp 1 (A-2). Ranh giới 3 lớp còn đúng, **0 phụ thuộc vòng** (đồ thị lời gọi là DAG), ADR-0004/0005/0006/0007 khớp code | 2026-09-15 |
| 2 | Bảo mật | ✅ Xong | Cao 0 · Trung 0 · **Thấp 2** (F-001 eval tên biến động; F-002 ví dụ token inline trong comment crontab) | 2026-09-15 |
| 3 | Chất lượng mã & chống lỗi logic | ✅ Xong | **Cao 1** (F-301 hàng rào `block-dangerous-git` BỊ VƯỢT) · Trung 5 · Thấp 4 | 2026-09-15 |
| 4 | Kiểm thử & coverage | ✅ Xong | **13/13 suite XANH** khi đủ công cụ (chạy thật). Độ phủ TOTAL **95%** — **sát sàn**. **Cao 1** (F-401: 4 hook không có test nào) · Trung 3 · Thấp 3 | 2026-09-15 |
| 5 | Hiệu năng | ✅ Xong | Cao 0 · **Trung 1** (F-205 thiếu `timeout-minutes`) · Thấp 1. Đo thật bằng `time`: mọi cổng < 1s, tổng script job `framework-lint` **45.4s**; không có quét O(n²), không có `git` trong vòng lặp nóng | 2026-09-15 |
| 6 | Accessibility & UI/UX | ➖ Không áp dụng | Xác minh bằng lệnh (không đoán): `git ls-files | grep -iE "\.(tsx|jsx|html|css|scss|vue|svelte)$"` → **rỗng**; `styles/` không tồn tại. A11y dạng CLI **đạt**: trạng thái luôn mang bằng ký tự+chữ (🔴/🟡/✅/❌ + câu tiếng Việt), 0 escape ANSI trong engine Python ⇒ không có ca "chỉ dùng màu". 1 phát hiện phát sinh đã chuyển sang Nhóm 9 (F-201) | 2026-09-15 |
| 7 | Dependency & chuỗi cung ứng | ✅ Xong | 0 phát hiện — **16/16** `uses:` ghim full SHA 40 ký tự (0 tag trôi); `dependabot.yml` phủ cả npm + github-actions; `vendor/shellmetrics` có README nguồn + phiên bản 0.5.0 + LICENSE MIT + SHA256SUMS; không có `curl \| bash`; `npx --no-install`; `pip install` ghim `==`. KHÔNG chạy `npm audit` (không có package.json — chạy sẽ vô nghĩa) | 2026-09-15 |
| 8 | CI/CD & vận hành/observability | ✅ Xong | **Cao 2** (F-101 đã ghi ở Nhóm 9 — cùng gốc; **F-202** `maintenance.yml` đóng nhầm issue) · Trung 1 (F-203 gitleaks không required) · Thấp 1 (F-204). Đã soi và **bác bỏ** các khuôn xanh giả khác | 2026-09-15 |
| 9 | Tài liệu & đồng bộ | ✅ Xong | **Cao 2** (F-101 cổng JSON tắt im lặng; F-102 FEATURE-MAP thiếu 8 engine) · Trung 2 (F-103, F-104) | 2026-09-15 |
| 10 | Dữ liệu & migration | ✅ Xong (phần CSDL ➖ không áp dụng) | CSDL/migration: xác minh `git ls-files | grep -iE "migration|schema|\.sql"` → **rỗng**. Phần dữ liệu JSON thật: **Trung 2** (F-206 `_verified_on` không có cổng; F-207 tiers JSON fail-open + drift + thiếu test). `_verified_on` cả 2 file đều **tươi** (2 ngày / 0 ngày) | 2026-09-15 |
| 11 | Cấu hình môi trường & bí mật | ✅ Xong | Cao 0 · Trung 0 · **Thấp 2** (F-003 deny pattern `.claude/settings.json` không phủ thư mục con; F-004 `.gitignore` `.env*.local` không chặn `.env.production`) | 2026-09-15 |
| 12 | Thống nhất chéo tính năng | ✅ Xong | Cao 0 · **Trung 2** (T-1 hai khuôn cổng đối lập; T-2 sweep chỉ chạy 2/5 cổng) · Thấp 1 (T-3) | 2026-09-15 |

## Ghi chú điểm dừng (nhóm đang 🔄 dở — đã xét sub-mục nào, chưa xét sub-mục nào)
- (chưa có)

## Lượt trước (2026-09-12, base `709cc86`) — tham khảo, KHÔNG mang kết luận sang

8 nhóm ✅ · 4 nhóm ➖ (N5/N6/N10 không áp dụng sau ADR-0004). Cao 0 · Trung 4 (G-001..G-004, đã sửa
cả 4) · Thấp 0 mới. Vì đây là lượt **RESET**, mọi kết luận trên phải được **quét lại và tự chứng
minh**, không chép sang. Xem lịch sử Git của file này nếu cần tra nội dung cũ.

## Phát hiện chi tiết — Nhóm 2 / 7 / 11 (quét 2026-09-15)

| ID | Nhóm | Mức | Vị trí | Phát hiện | Rủi ro nếu để nguyên | Công sức |
| --- | --- | --- | --- | --- | --- | --- |
| F-001 | 2 | Thấp | `scripts/dev-task.sh:36`, `scripts/maintenance-sweep.sh:72` | `eval "printf '%s' \"\${$1:-}\""` dựng chuỗi eval từ **tên biến động**. Hiện KHÔNG khai thác được: `dev-task.sh:147` có allowlist cứng `case "$TASK" in format\|lint\|typecheck\|test\|build)`, và `maintenance-sweep.sh:162` chỉ lặp trên hai giá trị literal `outdated audit` — dữ liệu ngoài không có đường vào `$1` | Bẫy chờ: một call site tương lai lấy tên task từ input người dùng sẽ thành RCE mà không ai để ý, vì bản thân hàm không tự bảo vệ | Nhỏ (~30 phút): thay bằng `case` tường minh hoặc mảng liên kết bash 4+ |
| F-002 | 2 | Thấp | `scripts/maintain-cron.sh:33` | Ví dụ trong comment đặt token ngay trên dòng lệnh: `GITHUB_TOKEN=ghp_xxx scripts/maintain-cron.sh`. Là comment, không phải code chạy | Người vận hành copy nguyên văn vào crontab thật → token lộ trong `ps aux` và history cho mọi user cùng máy VPS | Rất nhỏ (~10 phút): đổi ví dụ sang `EnvironmentFile=`/file quyền hạn chế |
| F-003 | 11 | Thấp | `.claude/settings.json:69-72` | Deny list có `Read(**/.env)` (phủ mọi độ sâu) nhưng `Read(./.env.*)` và `Read(./secrets/**)` chỉ **neo ở gốc** → `apps/web/.env.local` và `apps/api/secrets/**` KHÔNG bị chặn | Chỉ tác động ở hồ sơ monorepo (C9) mà dự án đích copy khung về: agent vô tình `Read` một `.env.local` thư mục con, giá trị bí mật lọt vào ngữ cảnh/log | Rất nhỏ (~5 phút): đổi thành `Read(**/.env.*)` + `Read(**/secrets/**)` |
| F-004 | 11 | Thấp | `.gitignore` | `.env*.local` chỉ chặn biến thể có hậu tố `.local`; `.env.production`/`.env.development` không bị chặn | Repo khung hiện không có app nên rủi ro bằng 0; nhưng dự án đích copy khung về rồi tạo `.env.production` chứa giá trị thật sẽ commit nhầm mà không cổng nào chặn | Rất nhỏ (~5 phút) |

**Đã kiểm và KHÔNG ra phát hiện** (ghi lại để lượt sau không kiểm trùng): không workflow nào dùng
`pull_request_target`; không chỗ nào nội suy `${{ github.event.* }}` thẳng vào `run:` (script
injection Actions); `maintain-cron.sh` không bao giờ push/force-push nhánh chính và `git add` đúng
3 file theo tên, token chỉ vào header `curl` không bị log; `maintain-run.sh` dựng lệnh bằng **mảng
bash** + prompt qua stdin nên nội dung prompt không phá được ranh giới lệnh; mọi file `*.example`
chỉ có placeholder, `git grep` các khuôn bí mật phổ biến ra **0** kết quả.

**Đính chính của Tầng 1 khi kiểm chứng lại:** subagent báo "13 lần `uses:`"; đếm thật là **16/16**
ghim SHA (`grep -h 'uses:' .github/workflows/*.yml | wc -l` = 16). Kết luận không đổi, con số thì sai.

## Phát hiện chi tiết — Nhóm 1 / 9 / 12 (quét 2026-09-15)

Tầng 1 đã **chạy lại lệnh kiểm chứng** cho mọi mục Cao/Trung dưới đây, không chép lời khai subagent.

| ID | Nhóm | Mức | Vị trí | Phát hiện (đã xác minh) | Rủi ro nếu để nguyên | Công sức |
| --- | --- | --- | --- | --- | --- | --- |
| F-101 | 9 | **Cao** | `.github/workflows/ci.yml:119` | Bước "JSON cấu hình hợp lệ (jq)" còn trỏ `.claude/settings-shared-opusplan.json` — file đã đổi tên thành `settings-shared-default.json` từ ADR-0007. Vì có `if [ -f "$f" ]` bọc ngoài, bước **không đỏ**, nó im lặng bỏ qua ⇒ `settings-shared-default.json` **chưa từng được `jq empty` kiểm** kể từ khi đổi tên. Không cổng nào bắt: `check-docs-consistency.sh:61` chỉ quét `'*.md' '*.sh' '*.ps1'`, **không quét `*.yml`** | File cấu hình hỏng JSON lọt CI, chỉ vỡ ở phiên người dùng. Nghiêm trọng hơn: khuôn "đổi tên file → cổng tự tắt im lặng" còn nguyên cho mọi lần đổi tên sau | XS (sửa tên + bỏ fail-open) · S (mở rộng cổng sang `*.yml` + negative test) |
| F-102 | 9 | **Cao** | `docs/FEATURE-MAP.md` | Thiếu **8/8** engine & cổng: `spec-compiler`, `arch-health-radar`, `subagent-dispatch`, `telemetry-log`, `check-shell-complexity`, `check-python-complexity`, `check-progress-freshness`, `block-dangerous-git` — `grep -c` ra **0** cho từng cái. `FT-21` bị cấp trùng cho 2 mục. Số đếm lệch: khai 9 subagent (thật 11), 5 hook (thật 6), "3 script cổng" (thật 5 `check-*` + 13 `test-*`) | `CLAUDE.md` §1 gọi các script đó là "Engine chạy được" — code có logic nhất của khung — mà bản đồ *nguồn sự thật "dự án CÓ NHỮNG GÌ"* không biết chúng tồn tại. Nhóm 12 của mọi đợt audit sau lấy chính file này làm căn cứ ⇒ bỏ sót có hệ thống | M |
| F-103 | 9 | Trung | `docs/CONVENTIONS.md` | Sổ quy ước khai số đã sai (`12/12 lệnh` → thật 13; `8/8 agent` → thật 11) và tuyên bố mục W-307 "ĐÃ XỬ LÝ" không còn đúng: khai "comment tại cả 9 file `set -uo`", thực tế **12 file** `set -uo` không có chú thích lý do | Sổ quy ước nói sai sự thật ⇒ đợt audit Nhóm 12 sau đối chiếu nhầm; W-307 tưởng đã đóng nên không ai canh, drift lan tiếp theo mỗi script mới | S |
| F-104 | 9 | Trung | `PROGRESS.md:246` + `scripts/check-progress-freshness.sh` (PF-1) | Dòng "Default-branch SHA đã đối chiếu" vẫn là `9351961` (PR #141) trong khi HEAD đã đi trước **4 commit**. `CLAUDE.md` §8 bước (5) buộc cập nhật ngay sau khi quay về `main` và nêu job `progress-freshness` là hàng rào — nhưng PF-1 chỉ ra `::warning` + `exit 0` nên **không chặn** | Đúng nguy cơ §8 gọi là "nguyên nhân số một khiến PROGRESS.md lỗi thời"; luật nói một đằng, cổng làm một nẻo | XS (sửa dòng) · S (siết PF-1 cho ca hẹp: HEAD đi trước ≥1 VÀ nhánh = `main` VÀ tree sạch → đỏ) |
| A-1 | 1 | Trung | `scripts/test-copy-framework.sh:12`, `test-engine-characterization.sh`, `test-py-coverage.sh` | 3/13 script test **không** dùng `scripts/_test-lib.sh`, mỗi cái tự cài bộ đếm riêng (`fail` số ít vs `fails` số nhiều, `FAIL [...]` vs `❌`) | `CODEMAP.md:40` cảnh báo "đổi `_test-lib.sh` là đổi output của CẢ TÁM" — nhưng 3 file này không theo, output CI lệch nhau âm thầm; đọc log không biết `FAIL [x]` có được đếm vào tổng không | S |
| A-3 | 1 | Trung | `scripts/check-python-complexity.sh:17`, `check-shell-complexity.sh:18` | 2 cổng mới nhất dùng `set -uo pipefail` (thiếu `-e`) **và không có chú thích lý do**, trong khi 3 cổng cũ đều `set -euo pipefail`. Xác minh: 3 `-euo` / 2 `-uo` trên 5 file `check-*.sh` | Không có `-e`, một lệnh phụ hỏng giữa chừng (`radon`/`shellmetrics` ra rác, `mapfile` rỗng) không dừng script → **cổng kết luận xanh trên dữ liệu rỗng**, đúng khuôn "cổng rỗng luôn xanh là cổng hỏng" mà chính `check-shell-complexity.sh:41` cảnh báo | XS |
| A-2 | 1 | Thấp | `scripts/test-engine-characterization.sh` (450 dòng) | File mã dài nhất repo; chính `arch-health-radar` của khung tự báo "việc cần làm". Header đã giải thích vì sao **không viết bằng Python**, nhưng không giải thích vì sao **gộp 3 engine vào một file** | Radar báo việc cần làm mãi không ai đóng → nhiễu tín hiệu | M (tách) hoặc XS (thêm dấu `DEBT:` đúng khuôn §3 A7) |
| T-1 | 12 | Trung | 3 cổng cũ vs 2 cổng mới (xem A-3) | Hai khuôn đối lập trùng khít trên cùng ranh giới thế hệ: chế độ nghiêm (`-euo` vs `-uo`), cách đếm (tích luỹ `fail` báo mọi vi phạm vs `exit 1` ngay lỗi đầu), luồng `::error::` (stdout vs stderr — 14 stdout / 7 stderr) | Thêm cổng thứ 6 phải đoán khuôn nào chuẩn; kiểu "thoát ngay lỗi đầu" khiến một lượt CI chỉ lộ 1 trong N vi phạm → nhiều vòng đỏ liên tiếp | S |
| T-2 | 12 | Trung | `scripts/maintenance-sweep.sh:280-281` | Mục tự đặt tên **"6. Cổng khung"** nhưng chỉ chạy **2/5** cổng `check-*.sh`: thiếu `check-progress-freshness.sh`, `check-shell-complexity.sh`, `check-python-complexity.sh` | **Đã gây hậu quả thật, cùng ngày** — xem mục "Đính chính" bên dưới. Báo cáo `/maintain` kết luận "cổng khung ✅" trên 2/5 cổng = kết luận mạnh hơn bằng chứng (§4 cấm) | S |
| T-3 | 12 | Thấp | `maintenance-sweep.sh` vs `maintain-run.sh`/`maintain-cron.sh` | Hai tiền tố cho cùng họ tính năng. **Đề xuất KHÔNG đổi tên** (lan sang CODEMAP/ci.yml/copy-framework/FEATURE-MAP/CP-6 — đắt hơn lợi ích), chỉ ghi một dòng phân vai vào `CONVENTIONS.md` | Nhỏ: gõ nhầm, tìm nhầm file | XS |

### Đính chính quan trọng: T-2 lật lại kết luận của đợt `/maintain` sáng nay

Đợt `/maintain` 2026-09-15 (PR #143) báo **🔴 0 · 🟡 0, "cổng khung ✅", 0 mục hành động**. Kết luận
đó **hẹp hơn tôi đã trình bày**: `maintenance-sweep.sh` chỉ chạy 2/5 cổng, và `check-progress-freshness.sh`
— đúng cái cổng sinh ra để bắt F-104 — **không nằm trong lượt quét**. F-104 (PROGRESS.md trễ 4 commit)
đã tồn tại ngay lúc đó và lượt sweep không thể thấy.

Không phải sweep chạy sai: nó chạy đúng những gì được lập trình để chạy. Sai ở chỗ **báo cáo gọi
2/5 là "cổng khung"**, và tôi đã chuyển nguyên nhãn đó ra cho người dùng mà không kiểm phạm vi
thật. Đây chính là bẫy §4 "không tin lời khai — kể cả của chính mình": tôi có chạy lệnh và đọc
output, nhưng không hỏi *output đó có bao phủ đúng điều tôi sắp tuyên bố không*.

### Đã kiểm và ĐẠT (ghi lại để lượt sau không kiểm trùng)

- **Kiến trúc:** ranh giới 3 lớp còn đúng; `ls -d app lib styles e2e i18n messages components supabase .husky`
  → không thư mục nào tồn tại ⇒ ADR-0004 (gỡ scaffold web) được tôn trọng đầy đủ. Đồ thị lời gọi
  thật giữa các script là **DAG, 0 chu trình**. `_python-exec.sh` (27 dòng) không rò rỉ trách nhiệm.
- **ADR:** không ADR nào lỗi thời. ADR-0001 bị ADR-0004 đảo, ADR-0006 mục 2 bị ADR-0007 đảo — cả hai
  **bằng ADR mới, không sửa ADR cũ**, đúng luật. ADR-0002 (Node 24) khớp `.nvmrc`.
- **`CLAUDE.md` §5/§10 còn `[ĐIỀN]`:** xác minh là CỐ Ý và ghi chú **vẫn còn đúng** — 6 cổng thật nó
  liệt kê khớp đúng 6/6 với `needs:` của job `gate` (`ci.yml:280-283`). Không phải thiếu sót.
- **Thống nhất chéo:** 4/4 wrapper Python dùng đúng một dòng `_python-exec.sh`; 13/13 file lệnh có
  frontmatter + đúng một khoá `description:`; 11/11 subagent khai TẦNG/model/ranh giới.

### Sợi chỉ xuyên suốt (nhận định của Tầng 1)

Sáu trong chín phát hiện trên nằm đúng một ranh giới: repo có **hai thế hệ script** — thế hệ
2026-09-12/13 (cổng docs/CI) và thế hệ 2026-09-14/15 (complexity, coverage, maintenance, Windows).
Các tài liệu meta (`FEATURE-MAP.md` chốt 2026-09-14, `CONVENTIONS.md` chốt 2026-09-13) và các cơ chế
bao trùm (`maintenance-sweep.sh`, `check-docs-consistency.sh` chỉ quét `.md/.sh/.ps1`) **chưa theo kịp
thế hệ sau**. Đây không phải 9 lỗi rời rạc mà là **một khoảng trễ có hệ thống**, và không cổng máy
nào canh được nó — vì mọi cổng hiện có chỉ kiểm thứ *đã được khai báo*.

## Phát hiện chi tiết — Nhóm 5 / 6 / 8 / 10 (quét 2026-09-15)

| ID | Nhóm | Mức | Vị trí | Phát hiện (đã xác minh) | Rủi ro nếu để nguyên | Công sức |
| --- | --- | --- | --- | --- | --- | --- |
| **F-202** | 8 | **Cao** | `.github/workflows/maintenance.yml:36-42` + `:66-74` | Bước sweep chạy dưới `set +e`, ghi `rc=$?` vào `$GITHUB_OUTPUT` — nhưng **không ai đọc `rc`** (chỉ `:48` `outputs.red` và `:49` `outputs.yel`). Hai dòng `grep … \|\| echo 0` biến "không parse được số" thành `red=0, yel=0`. Nhánh `:66` `if (red === 0 && yel === 0)` khi đó **comment "🔴 0 · 🟡 0 — đóng issue" rồi `issues.update({state:'closed'})`**. Tức **sweep chết giữa chừng trông y hệt sweep sạch**, và còn chủ động xoá dấu vết. Job vẫn xanh | Đây là **kênh observability duy nhất chạy theo lịch** của repo. Hỏng ở đây = repo im lặng tin rằng mình sạch trong nhiều tuần, đúng lúc không ai đang mở phiên để kiểm | ~45 phút (đọc `rc` + bỏ `\|\| echo 0` + 1 ca test chứng minh sweep chết thì KHÔNG đóng issue) |
| F-205 | 5 | Trung | `.github/workflows/ci.yml:225` | **1/13** job có `timeout-minutes` (`grep -rn timeout-minutes .github/workflows/ \| wc -l` = 1). Job `framework-lint` — dài nhất, có `apt-get install shellcheck`, 2 lần `pip install`, và `test-maintain-cron.sh` với vòng retry push + `sleep 5` — chạy ở timeout mặc định **360 phút** | Một lần treo mạng/apt hoặc retry loop không thoát đốt 6 giờ runner; `gate` có `needs:` nên treo theo ⇒ PR đứng im không rõ lý do | ~20 phút |
| F-203 | 8 | Trung | `.github/rulesets/main.json` (`required_status_checks` = đúng 2 context: `gate`, `metadata`) | `gitleaks` và `dependency-review` **không phải required check**. Đây là **chủ ý đã khai** (`docs/ops/repository-settings.md:37-39`) nên không phải lỗi ẩn — nhưng `secret-scan.yml:3-5` tự mô tả là *"tự động hoá luật 'bí mật KHÔNG bao giờ vào Git'"*, và `CLAUDE.md` §3.5 xếp luật đó vào **bất biến phổ quát**. `gitleaks` đỏ hiện chỉ làm PR có một dấu ❌ mà **auto-merge vẫn chạy** | Một bí mật thật lọt vào `main` của chính bộ khung rồi được `copy-framework.sh` **nhân bản xuống mọi dự án đích**. Theo đúng chữ repo tự dùng: luật không có cổng là trang trí | ~30 phút. **Lưu ý:** chỉ nên bắt buộc `gitleaks`; `dependency-review` có `if:` nên ở repo khung luôn skip → bắt buộc nó sẽ tạo đúng bẫy "skipped = đạt" |
| F-206 | 10 | Trung | `scripts/model-rates.json:3`, `scripts/model-capability-tiers.json:3` | `_verified_on` là trường **tự khai, không cổng nào cảnh báo khi nó mục**. `grep` toàn repo: chỉ có văn xuôi + một chỗ đọc thụ động (`telemetry-log.py:44` đọc rồi in, không so với hôm nay). `maintenance-sweep.sh` quét 6 mảng, **không mảng nào** kiểm độ tươi. Chính `model-rates.json:2` tự viết ra vấn đề: *"sai số ở đây KHÔNG làm đỏ CI — sẽ âm thầm sai mãi"* | Giá API / bảng model lệch nhiều tháng; ước tính chi phí sai âm thầm, và vì chỉ dùng để *ước tính* nên không có tín hiệu nào phát hiện. **Hiện tại cả 2 file đều tươi** (2 ngày / 0 ngày) — đây là bẫy chờ, không phải hỏng | ~45 phút (thêm mục 🟡 vào sweep, dùng hạ tầng đã có) |
| F-207 | 10 | Trung | `scripts/subagent-dispatch.py:41-45`, `:162`, `:184` | Ba vấn đề, đã **chạy thử thật** trên bản sao cô lập: (1) fail-open có che giấu — **xoá hẳn file** và **đổi cấu trúc JSON** cho ra *y hệt* thông báo `tier 'standard' không có trong <đường dẫn>`, tức đổ lỗi sai chỗ cho tham số người dùng; (2) bỏ một trường → **traceback trần `KeyError: 'model_hint'`**; (3) danh sách tier nhân bản 3 nơi (argparse `choices=` hard-code, khoá JSON, văn xuôi `CLAUDE.md`) — thêm tier vào JSON là **vô hiệu**, argparse chặn trước khi file được mở. Bất đối xứng rõ: `model-rates.json` **có** negative test cho JSON hỏng (`test-py-coverage.sh:96-109`), file này **không có ca nào** — trong khi `CODEMAP.md:49` khai rằng cổng của nó là `test-telemetry-and-dispatch.sh` | Điều phối đa-model (ADR-0006) là đường dẫn **AI tự chạy**, không có người đọc lỗi tại chỗ — một `KeyError` trần hoặc thông báo đổ lỗi sai chỗ giữa phiên tự động tốn hẳn một vòng chẩn đoán | ~1.5 giờ |
| F-201 | 9 | Thấp | `CLAUDE.md:38`, `:89`; gốc ở `scripts/check-docs-consistency.sh:66` | `CLAUDE.md` nhắc `styles/theme.css` như đường dẫn thật; file không tồn tại. Bản thân việc đó là **CỐ Ý** (`quality-supplements-theme.md:5`: *"tự tạo ở gốc dự án đích"*). **Nhưng cổng không biết điều đó** — nó thoát vì lý do khác hẳn: regex `:66` chỉ bắt đuôi `(md\|sh\|ps1\|json\|ts\|tsx\|yml\|cjs\|mjs)`, **không có `css` và không có `py`** | Bốn engine Python của khung có thể đổi tên/di chuyển và **mọi tham chiếu `scripts/*.py` trong tài liệu mục âm thầm** — cổng không bắt. Giảm nhẹ một phần: mục 6 của cùng script bắt chiều ngược lại | ~30 phút (thêm `css\|py` + kê vào `ALLOW_MISSING_PATH` kèm lý do) |
| F-204 | 8 | Thấp | `docs/ops/incident-response.md` | Runbook **dùng được** (bảng SEV, 7 bước, mẫu post-mortem nhúng, template issue `incident.md` tồn tại thật) nhưng **chưa từng dùng** (`git ls-files \| grep -i postmortem` → rỗng). Với repo không có production thì đó là bình thường, KHÔNG phải nợ. Vấn đề thật: bước 3 giả định hạ tầng cụ thể (*"Vercel: Promote bản trước"*, *"backup/PITR"*, *"Sentry"*) — không áp được cho chính bộ khung, và không mục nào nói runbook này dành cho dự án đích | Thấp: lúc thật sự có sự cố, người đọc mất thời gian nhận ra runbook nói về hạ tầng mình không có | ~20 phút (một dòng khoanh phạm vi) |
| F-208 | 5 | Thấp | `scripts/check-docs-consistency.sh:70-75` | `grep_files()` (một `git grep` toàn repo) chỉ chạy cho ref **không tồn tại** — hiện 49 ref, ≈0.25s. Là O(số ref gãy), không phải O(n²), nhưng **suy biến tuyến tính khi tài liệu gãy hàng loạt** (vd đổi tên một thư mục) — đúng lúc cổng cần chạy nhanh nhất | Rất thấp, thuần chi phí | ~15 phút (kiểm `ALLOW_MISSING_PATH` **trước** `grep_files`) |

### Số đo hiệu năng thật (Nhóm 5)

Mọi cổng "kiểm thuần" **dưới 1 giây**: `check-progress-freshness` 0.046s · `arch-health-radar` 0.069s ·
`check-ci-policy` 0.200s · `check-docs-consistency` 0.770s · `check-shell-complexity` 0.792s.
Script nặng nhất là `test-check-scripts.sh` **18.6s** — nặng vì nó **dựng repo git giả và chạy lại 3
gate bên trong** (negative test), không phải vì thuật toán kém. **Tổng phần script của job
`framework-lint`: 45.4s.** Không có quét O(n²), không có `git` gọi trong vòng lặp nóng.

### Đã soi và BÁC BỎ (ghi lại để lượt sau không kiểm trùng)

- **Khuôn xanh giả trong CI:** `grep -rn "continue-on-error"` → **rỗng**; `grep -rn '|| true'` → **rỗng**.
  Job `gate` viết rất chặt: `if: always()` có; duyệt `toJSON(needs)` **giữ tên job** thay vì
  `join(needs.*.result)`; `skipped` **chỉ** đạt khi có tên trong `SKIP_ALLOWED`; mọi result khác
  (`failure`/`cancelled`/`timed_out`) rơi vào `*)` → `bad=1`. CP-5 so `SKIP_ALLOWED` **hai chiều**.
- **Nghi ngờ đã bác bỏ:** `pr-policy.yml:23` `if (pr.draft) return;` — tưởng là lỗ cho PR draft
  chuyển Ready mà không chạy lại Feature gate. Nhưng `:5` khai `types:` **có `ready_for_review`** ⇒
  lỗ đã bịt. Không phải phát hiện.
- **Observability của `maintain-cron.sh`: tốt hơn dự đoán** — log có timestamp UTC ISO-8601 ra stderr,
  lock dir chống chạy chồng + tự dọn khi PID chết, retry push một lần sau 5s, exit code được log
  tường minh chứ không nuốt, kênh báo cáo là PR tự mở (dùng đúng thông báo GitHub sẵn có).
- **`model-rates.json` xử lý dữ liệu hỏng ĐÚNG chuẩn** — thiếu file/hỏng JSON → **dừng hẳn**; không
  khớp khoá → `default` **kèm cảnh báo stderr**, không im lặng; có negative test thật; có trong
  `jq empty`. Đây chính là khuôn mà `model-capability-tiers.json` nên sao chép (spec
  `2026-09-15-da-model-da-nha-cung-cap.md:81` FR-4 **đã yêu cầu** "theo khuôn `model-rates.json`" —
  phần `_verified_on`/`_source` đã làm, phần **cổng và test** thì chưa).

### Đính chính của Tầng 1

Subagent xếp F-202 mức **Trung**; tôi **nâng lên Cao**. Lý do: nó không chỉ bỏ sót tín hiệu mà
**chủ động huỷ tín hiệu** — một lượt sweep chết sẽ đi đóng issue bảo trì đang mở kèm dòng chữ
"🔴 0 · 🟡 0". Cộng với T-2 (sweep chỉ chạy 2/5 cổng), kênh bảo trì theo lịch đang **kém tin cậy hơn
hẳn mức nó tự quảng cáo**, và đó là kênh duy nhất hoạt động khi không ai mở phiên.

### Giới hạn của lượt quét này (không che)

1. **Branch protection thật trên GitHub chưa kiểm được** — cần `GET /repos/.../rules/branches/...`
   với token (job `protection-guard` trong Actions). Chỉ xác minh được **file khai báo khớp workflow**
   (`check-ci-policy.sh` exit 0) và logic đối chiếu hai chiều viết đúng. Ruleset có đang
   `enforcement: active` với `bypass_actors: []` hay không: **chưa biết**.
2. **Thời lượng CI thật chưa đọc** — 45.4s là tổng script cục bộ trên Linux, **chưa gồm** checkout,
   `apt-get install shellcheck`, 2 lần `pip install`, lượt `shellcheck`, và **toàn bộ job
   `framework-lint-windows`**.
3. **ShellCheck không cài trong sandbox** → không tự xác minh được "0 cảnh báo".
4. **`test-copy-framework.sh` chạy thiếu nửa phạm vi** — không có `pwsh` nên bản `.ps1` không được
   kiểm; 12.1s thấp hơn thời gian CI thật (nơi có `REQUIRE_PWSH=1`).
5. **`framework-lint-windows` hoàn toàn không chạy được** ở đây ⇒ mọi kết luận về Windows là **chưa
   kiểm chứng**.
6. **Hiện tượng môi trường, KHÔNG phải phát hiện:** một lượt `check-python-complexity.sh` đầu phiên
   đỏ vì thiếu `radon`, các lượt sau xanh — `radon` được cài **giữa phiên** bởi tiến trình ngoài.
   Cổng ứng xử **đúng** (cố ý đỏ khi thiếu công cụ, có comment giải thích + negative test).

## Phát hiện chi tiết — Nhóm 3 / 4 (quét 2026-09-15)

| ID | Nhóm | Mức | Vị trí | Phát hiện (Tầng 1 đã chạy lại lệnh xác minh) | Rủi ro nếu để nguyên | Công sức |
| --- | --- | --- | --- | --- | --- | --- |
| **F-301** | 3 | **Cao** | `.claude/hooks/block-dangerous-git.sh:66` | **Hàng rào an toàn bị vượt.** Heredoc mở bằng `<<-` (POSIX cho phép đóng bằng dòng có TAB đầu): dòng đóng thật là `\tEOF`, không bằng `EOF`, nên `delim` không bao giờ được xoá → awk **nuốt toàn bộ phần còn lại của lệnh** → lệnh nguy hiểm đứng sau heredoc không bị quét. **Tầng 1 chạy lại và xác nhận:** payload có heredoc → `rc=0` (CHO QUA); cùng lệnh đứng một mình → `rc=2` (chặn đúng). Phần "GIỚI HẠN CÒN LẠI" của file (`:52-58`) có nêu ca `<< EOF` có khoảng trắng (chiều **an toàn**) nhưng **không** nêu ca này ⇒ không phải thứ cố ý | `git reset --hard` / force-push nhánh chính đi lọt trong bất kỳ lệnh có heredoc thụt TAB — **mất dữ liệu chưa commit, không dấu vết**. Đúng chiều hỏng nguy hiểm mà chính file cảnh báo: *"bỏ thiếu thì chặn oan (thấy ngay), bỏ thừa thì để lọt (không ai biết)"* | ~1h (gồm 2 ca test: chặn-bắt-buộc + không-chặn-oan) |
| **F-401** | 4 | **Cao** | `.claude/hooks/auto-format.sh`, `session-guide.sh`, `session-resume.sh`, `usage-guard.sh` | **4 hook không có bất kỳ test nào** (`grep -ln` trong mọi `test-*.sh` → NONE cho cả 4). `test-hooks-gate.sh` chỉ phủ `pre-commit-gate.sh` + `block-dangerous-git.sh`. Cả 4 đều có nhánh điều kiện thật ⇒ ADR-0005 bắt buộc phải có test | Sửa sai một ngưỡng/marker → hành vi hỏng, không cổng nào đỏ, và `copy-framework.sh` vẫn **phát hook hỏng đó sang mọi dự án đích** | ~3–4h |
| F-302 | 3 | Trung | `maintenance-sweep.sh:34`; `maintain-cron.sh:54,56,58,59,61`; `maintain-run.sh:44-49` | **Cờ thiếu giá trị → treo vô hạn.** `$#`=1, `case` khớp `--out`, `OUT="${2:-}"` không lỗi, rồi `shift 2` **thất bại và KHÔNG shift** → `while [ $# -gt 0 ]` lặp mãi; không có `set -e` nên không ai dừng. **Tầng 1 xác nhận:** `timeout 6 … --out` → **rc=124**; `… --harness` → **rc=124** | `maintain-cron.sh` chạy **không giám sát trên VPS/cron** — một dòng crontab gõ sót giá trị tạo tiến trình treo tích luỹ mỗi tuần. Treo **trước** bước lấy khoá nên khoá tiến trình không cứu được | ~1h |
| F-303 | 3 | Trung | `scripts/check-ci-policy.sh:259` (xung đột `cd` ở `:33`) | **Cổng xanh giả.** Mục 7 đọc chính mình qua `$0` **sau** khi đã `cd` về gốc repo. Gọi bằng đường dẫn tương đối từ thư mục khác → `grep` chết → `while` đọc rỗng → **không CP-* nào được đối chiếu**, nhưng script vẫn in câu khẳng định "bảng kiểm khớp hai bản". **Tầng 1 chạy từ `scripts/`:** in `grep: check-ci-policy.sh: No such file or directory` rồi ngay dưới là `OK — CP-1..CP-6 đạt; bảng kiểm khớp hai bản`, **rc=0** | W-302 (ràng hai bản shell/vitest) mất hiệu lực âm thầm. CI hiện gọi từ gốc nên chưa nổ — nhưng **cổng không được phép phụ thuộc thư mục gọi** | ~30 phút |
| F-304 | 3 | Trung | `.claude/hooks/pre-commit-gate.sh:26` | Không bỏ thân heredoc (bản vá TRAPS 18 **chỉ áp cho hook anh em** `block-dangerous-git.sh:62-76`). Một lệnh có heredoc nhắc `git commit` làm **dữ liệu** (viết tài liệu, sinh fixture) → hook tưởng là commit thật → chạy toàn bộ `dev-task.sh gate`; ở dự án đích đang đỏ thì **chặn oan một lệnh `cat`** | Chặn oan dạy người dùng gõ `--no-verify` phản xạ → **mất luôn cổng thật** | ~1.5h (rút helper dùng chung) |
| F-305 | 3 | Trung | `check-ci-policy.sh:213`; `check-progress-freshness.sh:44`, `:70` | Nhánh báo lỗi **chết trước khi in**. Cả ba là gán `X="$(… \| grep …)"` dưới `set -euo pipefail`; `grep` không khớp → pipeline trả 1 → thoát **ngay tại dòng gán** ⇒ cổng đỏ **không in một dòng chẩn đoán nào**, và các mục sau (CP-6/CP-7, PF-2/PF-3) **không chạy**. Chính `check-progress-freshness.sh:101-102` đã ghi khuôn này *"đã mắc thật"* và vá bằng `\|\| true` ở `:103` — **nhưng chỉ vá 1 trong 3 chỗ** | Đỏ CI không nói được nguyên nhân; một mục hỏng che mọi mục sau | ~30 phút |
| F-306 | 3 | Trung | `copy-framework.sh:57` | **Lồng thư mục ở lượt chạy thứ BA** (tái hiện TRAPS mục 3). Lượt 2 tạo `.claude/hooks.framework-new/` (đúng); lượt 3 đích đã có thư mục đó nên `cp -R src dir` **copy VÀO TRONG** → `.claude/hooks.framework-new/hooks/`. Người dùng cập nhật khung lần 3 mở file so sánh → **không có file nào ở đó** → kết luận "không có gì mới" và giữ hook cũ | Người dùng âm thầm bỏ lỡ mọi cập nhật hook/agent từ lượt 3 trở đi | ~1h |
| F-307 | 3 | Thấp | `scripts/dev-task.sh:137`, `:155` | Đường dẫn file đi thẳng vào `bash -c` → tên file chứa `$(...)` **thực thi được**. Nháy kép không bảo vệ khi chuỗi được `bash -c` diễn giải lại. Hook `auto-format` chạy **tự động, không hỏi**, trên mọi Edit/Write. Mẫu đúng đã có sẵn trong repo: `maintain-run.sh:105` dùng **mảng**, không ghép chuỗi | Cần tên file bất thường nên mức Thấp, nhưng đường đi là tự động và có ở mọi dự án đích | ~1.5h |
| F-308 | 3 | Thấp | `maintain-cron.sh:133`, `:140` | `git add` một file đang bị `.gitignore:37` chặn (`MAINTENANCE-REPORT.md`) → lỗi git + `hint:` **mỗi lượt cron**. Mâu thuẫn với chính `CODEMAP.md` ("ảnh chụp thô, KHÔNG commit") và `CLAUDE.md` §1 | Nhiễu log làm người vận hành ngừng đọc log cron | ~30 phút |
| F-309 | 3 | Thấp | `scripts/telemetry-log.py:83` | `KeyError` thô nếu một mục giá thiếu khoá `input`/`output`; `load_rates()` chỉ kiểm có `rates`/`default`, không kiểm hình dạng từng mục. Gõ nhầm `"in"`/`"out"` vẫn qua `jq empty` | Chết bằng traceback thay vì thông điệp cố ý mà `load_rates` được viết ra để cho | ~30 phút |
| F-310 | 3 | Thấp | `maintenance-sweep.sh:208` vs `:216` | Bộ đếm TODO loại trừ **chỉ** `maintenance-sweep.sh`; bộ đếm DEBT loại trừ **cả** file test của nó. Bất đối xứng ⇒ thêm fixture `TODO` vào `test-maintenance-sweep.sh` (việc rất tự nhiên) làm số TODO tăng giả. **Chưa nổ** (grep → 0 dòng) — rủi ro treo | Lại một ca của khuôn "bộ dò tự khớp thứ nó đang soi" | ~15 phút |
| F-402 | 4 | Trung | `scripts/test-check-python-complexity.sh` | Không nhận ra thiếu `radon` → **báo cáo SAI nguyên nhân**: in `❌ PY_CC_MAX=13 vẫn đỏ — cổng không đọc ngưỡng` (một khẳng định sai sự thật về code) trong khi nguyên nhân thật là `::error::Thiếu radon`. Hai suite anh em **đã làm đúng** (`test-check-shell-complexity.sh` in `⏭️ bỏ qua: máy này không có gawk`; `test-py-coverage.sh` in `::error::Thiếu coverage.py`) | Dev/AI chạy trên máy chưa cài radon → kết luận cổng hỏng, đi sửa một script đang đúng | ~30 phút |
| F-403 | 4 | Trung | `check-docs-consistency.sh:92-108`, `:116-123`, `:128-136`, `:157-160`; `check-ci-policy.sh:250-263` | **5 nhánh phát hiện của cổng không có negative test.** Hệ quả đo được: mục 7 của `check-ci-policy.sh` **đã hỏng thật** (F-303) mà không suite nào thấy | Xoá `OLD_NAMES` hoặc làm sai regex mục 3B → cổng xanh vĩnh viễn | ~2h |
| F-404 | 4 | Trung | `test-maintenance-sweep.sh` mục 6 | Không suite nào kiểm "cờ thiếu giá trị" ⇒ F-302 (treo vô hạn ở 3 script) không ai biết | Cùng gốc với F-302 | ~1h |
| F-405 | 4 | Thấp | `test-maintain-cron.sh:21-27` | Sandbox dựng bằng danh sách `cp` viết tay, **không có `.gitignore`** ⇒ che hành vi thật F-308 | Test không bao giờ thấy lỗi đang xảy ra hằng tuần | ~30 phút |
| F-406 | 4 | Thấp | `test-copy-framework.sh` | Chỉ chạy **2 lượt** (`== chạy lại lần hai ==`, không có lượt ba) ⇒ bỏ lọt F-306 | Cùng gốc với F-306 | ~30 phút |
| F-407 | 4 | Thấp | `maintain-cron.sh:117` + `test-maintain-cron.sh` mục 4 | Cửa sổ xanh-giả khi lượt test **vắt qua nửa đêm UTC**: hai lượt rơi vào hai ngày → hai nhánh khác tên → ca "chạy lại cùng ngày không cộng dồn" xanh mà **không kiểm gì** | Test không chạm nhánh nó định khoá | ~30 phút |

### Kết quả chạy thật 13 suite (Nhóm 4)

**13/13 XANH** khi môi trường đủ công cụ. Tổng ca: `test-check-scripts` 25✅ · `test-maintain-cron` 29✅ ·
`test-maintain-run` 27✅ · `test-maintenance-sweep` 27✅ · `test-hooks-gate` 22✅ · `test-telemetry-and-dispatch` 11✅ ·
`test-check-shell-complexity` 10✅ · `test-next-gen-engines` 9✅ · `test-check-python-complexity` 6✅ ·
`test-copy-framework` 5✅ · `test-usage-estimate` 4✅ · `test-engine-characterization` 35 unittest OK ·
`test-py-coverage` báo cáo phủ.

**Độ phủ dòng thật:** `arch-health-radar.py` 93% · `spec-compiler.py` 95% · `subagent-dispatch.py` 97% ·
`telemetry-log.py` 97% — **TOTAL đúng 95%, tức SÁT SÀN**: thêm một nhánh không test là đỏ.

### Đã kiểm và KHÔNG có phát hiện (Nhóm 3 — ghi để lượt sau không kiểm trùng)

Đã đối chiếu **toàn bộ 38 file `.sh`** cho `set -euo pipefail`: mọi chỗ thiếu `-e` đều có comment cố ý
trỏ `CONVENTIONS.md` §A. Mọi `cd` quan trọng đều có `|| exit`/`|| die`. **Không có** `rm -rf` trên biến
nào trong toàn repo (chỉ `rm -f` trên file từ `mktemp`). So sánh sai kiểu: rà từng chỗ, đều là số hoặc
có chặn trước. Python: **tất cả** `open()` trong 4 engine đều có `encoding="utf-8"` (TRAPS 24 đã áp đủ);
`relpath` khác ổ đĩa có `try/except` (TRAPS 28); chia cho 0 chặn tường minh. **Bộ dò tự khớp chính nó**:
rà cả 8 mục của `check-docs-consistency.sh` — mục 2 tự loại, mục 5 loại qua `STALE_EFFORT_EXCLUDE`,
mục 8 dựng mẫu bằng `printf` lúc chạy — **đúng và có ghi lý do**, không còn ca chưa xử lý trong nhóm
`check-*.sh` (ca còn sót nằm ở `maintenance-sweep.sh`, xem F-310). CP-6 khớp thật cả 13 `test-*.sh`.

### Giới hạn (Nhóm 3/4)

1. **`copy-framework.ps1` chưa kiểm** (không có `pwsh`) ⇒ **chưa biết** F-306 có tồn tại ở bản `.ps1`
   không — TRAPS mục 3 ghi hai bản **từng lệch nhau đúng ở điểm này**, nên phải kiểm riêng.
2. **Nhóm lỗi chỉ-có-trên-Windows chưa kiểm được** (BOM `.ps1`, CRLF, `cp1252`, `relpath` khác ổ đĩa) —
   chỉ xác nhận bản vá **có mặt trong source**, không xác nhận hiệu lực.
3. **Ca `gawk` bị bỏ qua** (máy chỉ có mawk) ⇒ chưa chứng minh cổng CC shell chạy được dưới gawk.
4. Subagent **đã cài `radon` + `coverage`** vào môi trường Python của phiên để đo được F-402 và độ phủ
   thật. Không đụng file nào trong repo — đây là thay đổi môi trường duy nhất.

## GIAI ĐOẠN 2 — tiến độ xử lý

Người dùng duyệt **toàn bộ 4 batch** theo thứ tự đã đề xuất (2026-09-15).

**Ràng buộc đã nêu với người dùng:** phiên này chỉ được push lên nhánh
`claude/kind-darwin-a8v4uy`, nên không tách được mỗi mục thành một PR riêng như §8 mong muốn. Thay
vào đó: **mỗi mục một commit nguyên tử**, gom vào một PR.

| Batch | ID | Trạng thái | Commit | Bằng chứng |
| --- | --- | --- | --- | --- |
| 1–2 | F-301 | ✅ Xong | `901a3c1` | Test ĐỎ trước (`❌ KHÔNG chặn: … heredoc <<- … exit 0, kỳ vọng 2`) → sau khi sửa 24/24 xanh; xác minh trực tiếp `rc=2`. TRAPS mục 30. |
| 1–2 | F-303 | ✅ Xong | `83c04e4` | Trước: gọi từ `scripts/` in `grep: … No such file` rồi ngay dưới `OK — bảng kiểm khớp hai bản`, rc=0. Sau: không còn lỗi, cổng thật sự đọc được CP-*. |
| 1–2 | F-305 | ✅ Xong | `83c04e4` | Sandbox (`git archive HEAD` + xoá dòng `needs:` của gate): trước chết im lặng; sau in `::error::Có job 'gate' nhưng không đọc được dòng 'needs:'` **và vẫn chạy tiếp CP-5/6/7**, rc=1. |
| 1–2 | F-101 | ✅ Xong | `859052e` | 6/6 file JSON bắt buộc tồn tại + `jq empty` xanh. Bổ sung 3 file danh sách cũ bỏ sót. |
| 1–2 | F-202 | ✅ Xong | `b80a111` | Đọc `rc` và thoát nếu ≠ 0; bỏ `\|\| echo 0`; thiếu dòng tổng ⇒ đỏ. |
| 3 | F-302 | ✅ Xong | `f5bc846` | Test ĐỎ trước (`❌ --out thiếu giá trị: TREO VÔ HẠN (rc=124)`) → sau khi sửa rc=2 kèm thông điệp. Helper `need_val` áp cho **12 cờ** ở 3 script. |
| 3 | F-404 | ✅ Xong | `f5bc846` | 10 ca mới phủ cả 3 script, dùng `timeout 8` và coi rc=124 là thất bại. |
| 3 | F-401 | ✅ Xong | `45b6492` | **22 ca mới** cho 4 hook. Đã CHỨNG MINH test bắt được hỏng: phá `usage-guard` → 3 ca đỏ; phá `session-guide` → ca "hai trạng thái khác nhau" đỏ. |
| 3 | F-403 | ✅ Xong | `6c49055` | 5 ca mới, mỗi ca một sandbox + đúng một lỗi cài sẵn, đòi rc=1. |
| 4 | F-201 | ✅ Xong | `f7235bd`, `3464df6` | Regex mục 1 thêm đuôi `py\|css`; gỡ 2 entry ALLOW_MISSING_PATH đã thành file thật; 3 ca test (bắt `.py` gãy, bắt `.css` gãy, đối chứng không chặn oan). |
| 4 | F-104 | ✅ Xong | `7c11a19` | PF-1 ĐỎ ở ca hẹp (trễ ≥2 + nhánh `main` + tree sạch); 4 ca ranh giới; cập nhật dòng SHA `9351961` → `98ccd6f`. |
| 4 | F-103 + A-3 | ✅ Xong | `ce5bf58` | Sửa số (12→13 lệnh, 8→11 agent); viết lại luật hub; **MỞ LẠI W-307** thay vì đóng; thêm `# cố ý KHÔNG -e` cho đủ 12 file. |
| 4 | F-102 | ✅ Xong | `+ mục 9` | 8/8 engine nay có mặt (`grep -c` ≥1 cho từng cái); ID hết trùng; **thêm mục 9 vào `check-docs-consistency.sh`** đối chiếu agent+hook ↔ FEATURE-MAP + cấm ID trùng, kèm 2 negative test. |
| 5 | T-2 | ✅ Xong | `bcde247` | Sweep nay chạy **5/5** cổng `check-*`. Tách "thiếu công cụ" (🟡, chưa kiểm chứng được) khỏi "vi phạm thật" (🔴). 8 ca test gồm ca đối chứng chống regex quá rộng. |
| 5 | F-306 | ✅ Xong | `ce4bd67` | Test ĐỎ trước (3 thư mục lồng, **rộng hơn audit báo** — có cả `.cursor/rules`) → sau khi sửa sạch. Helper `check_no_nesting` chạy cho **cả hai** bản. TRAPS mục 31. |
| 5 | F-304 | ✅ Xong | `2ab150e` | Test ĐỎ trước (2 ca chặn oan) → sau khi sửa 3/3 xanh gồm đối chứng "commit thật sau heredoc vẫn chặn". Rút `_hook-lib.sh` dùng chung thay vì chép tay lần hai. |

### Đính chính khuyến nghị của chính audit (F-101 phần c)

Audit đề xuất "mở rộng `check-docs-consistency.sh` thêm `'*.yml'`" để bắt đường dẫn chết trong
workflow. Kiểm lại: đường dẫn hỏng nằm **trần trong vòng lặp shell, không trong backtick**
(`grep -c '\`.claude/settings-shared-opusplan.json\`'` ra **0**), mà mục 1 chỉ bắt đường dẫn
**trong backtick** ⇒ mở rộng sang `.yml` **sẽ không bắt được ca này**. Không làm phần (c); thứ
thật sự bịt lỗ là bỏ fail-open, đã làm.

### Ghi nhận khác

`test-copy-framework.sh` **treo** khi stdin không đóng (stub `hermes` chờ nhập); với `</dev/null`
thì rc=0. Không liên quan thay đổi nào của batch này. Chưa lập thành phát hiện vì trong CI stdin
đã đóng sẵn — ghi lại để lượt sau biết.

### Ghi nhận batch 3

**F-302 không nằm trong 4 batch tôi đề xuất ban đầu** — đó là chỗ sót của chính tôi khi xếp nhóm.
Phải kéo nó vào cùng F-404 vì viết test cho "cờ thiếu giá trị" mà không sửa cái treo thì test đỏ
mãi. Đúng thứ tự đỏ→xanh, nhưng thứ tự batch tôi trình cho người dùng đã thiếu một mục.

**Một lần tự kiểm chứng thất bại rồi điều tra ra nguyên nhân thật:** khi phá hoại `session-guide.sh`
lần đầu để xem test có bắt được không, test vẫn xanh. Không kết luận vội "test rỗng" — kiểm lại thì
regex phá hoại **không khớp** nên file không hề bị đổi. Phá hoại đúng cách thì test đỏ ngay. Ghi
lại vì đây là bẫy dễ đọc ngược: một phép thử âm tính có thể do **phép thử** hỏng, không phải do thứ
đang thử.

### Đính chính thêm cho chính báo cáo audit (phát hiện khi thực thi batch 4)

1. **F-208 đã được làm sẵn.** Audit đề xuất "kiểm `ALLOW_MISSING_PATH` **trước** `grep_files` để bỏ
   ~49 lần git grep". Đọc code thì `is_in "$ref" "${ALLOW_MISSING_PATH[@]}" && continue` **đã nằm
   trước** `grep_files` rồi. Không có gì để sửa; F-208 là báo oan.
2. **A-3 nói quá rủi ro.** Audit cho rằng hai cổng complexity thiếu `-e` tạo lỗ "cổng kết luận xanh
   trên dữ liệu rỗng". Cả hai **đã có tự bảo vệ tường minh** (`cổng rỗng luôn xanh là cổng hỏng` →
   exit 1). Cái còn đúng chỉ là thiếu dòng chú thích lý do — đã bổ sung.
3. **W-307 KHÔNG được đóng lại.** Nguyên nhân gốc (không có cổng máy bắt `set -uo pipefail` thiếu
   dòng lý do) chưa xử lý. Đóng nó bây giờ chính là lặp lại sai lầm 2026-09-12 — lần đó cũng ghi
   "✅ ĐÃ XỬ LÝ" rồi drift lan tiếp sang 12 file mới.

### Mục ĐÃ DUYỆT nhưng CHƯA làm (nêu rõ, không im lặng bỏ)

Bốn batch người dùng duyệt gồm 14 mục; 14 mục đã xong. Các mục **còn lại của audit** chưa nằm trong
batch nào và **chưa được xử lý**:

| ID | Mức | Vì sao chưa làm |
| --- | --- | --- |
| F-203 | Trung | Đưa `gitleaks` vào required checks — **đụng cấu hình GitHub thật**, cần người dùng quyết (CLAUDE.md §9). |
| F-205 | Trung | Thêm `timeout-minutes` cho 12 job — việc nhỏ, chưa xếp vào batch nào. |
| F-206 | Trung | Cổng cảnh báo `_verified_on` mục — cần chọn ngưỡng ngày, nên hỏi trước. |
| F-207 | Trung | `subagent-dispatch.py` fail-open + `choices` hard-code + thiếu negative test (~1.5h). |
| T-1, T-2 | Trung | Hợp nhất khuôn cổng; `maintenance-sweep` chỉ chạy 2/5 cổng. **T-2 đáng ưu tiên** vì nó là lý do đợt `/maintain` sáng nay báo sạch sai phạm vi. |
| A-1, A-2, T-3, F-204, F-304, F-306..F-310 | Thấp/Trung | Chưa xếp batch. F-306 (copy-framework lồng thư mục lượt 3) và F-304 (pre-commit-gate không bỏ thân heredoc) đáng làm sớm nhất trong nhóm này. |

### Nợ do chính đợt xử lý này sinh ra (không giấu)

`arch-health-radar` tụt **100 → 99/100** vì `scripts/test-check-scripts.sh` nay **404 dòng** (trần
400) sau các ca test tôi thêm ở batch 3/4. Radar ghi "cân nhắc tách". Đây là hệ quả trực tiếp của
đợt xử lý này, không phải nợ có sẵn.

**Chưa xử lý** vì tách file test theo cổng (`test-check-docs.sh` / `test-check-ci.sh` /
`test-check-progress.sh`) kéo theo `ci.yml`, CP-6 của `check-ci-policy.sh`, và `copy-framework.sh` —
rộng hơn hẳn phạm vi "sửa phát hiện audit", nên không tự ý mở rộng. Ghép chung với **A-2** (file
`test-engine-characterization.sh` 450 dòng, cùng khuôn) thành một việc tách test riêng thì hợp lý
hơn. Radar chỉ cảnh báo khi < 80 nên 99 không chặn gì.

### Đính chính thêm (phát hiện khi sửa F-306)

- **Audit báo thiếu một ca.** Nó nêu `.claude/hooks` và `.claude/agents` bị lồng; chạy thật ra
  **ba** — còn `.cursor/rules.framework-new/rules`. Đọc code suy ra được hai, chạy mới ra đủ.
- **Giới hạn số 1 của Nhóm 3/4 đã được giải quyết.** Audit ghi "chưa biết F-306 có tồn tại ở bản
  `.ps1` không" (không có `pwsh`). Đọc `Copy-Tree` trong `copy-framework.ps1`: nó **tạo thư mục đích
  rồi copy các CON vào trong**, tức không có lỗi này. Hai bản **đang lệch nhau** — bản vá làm `.sh`
  khớp `.ps1`, không phải ngược lại. Đã thêm ca `pwsh` để CI chứng minh thay vì tin vào việc đọc.
- **Cổng bắt đúng chính tôi:** mục 1 của `check-docs-consistency.sh` chặn commit vì mục TRAPS mới và
  một comment trong test dùng backtick quanh đường dẫn **sinh lúc chạy** (`.framework-new/...`).
  Đã diễn đạt lại thay vì thêm miễn trừ để né cổng.

### Cổng tự bắt chính người sửa (ghi lại — đây là dấu hiệu cổng sống)

Trong lượt sửa F-304, **mục 9** của `check-docs-consistency.sh` — cổng tôi vừa thêm sáng nay cho
F-102 — chặn commit vì `_hook-lib.sh` chưa có trên `FEATURE-MAP.md`. Đã khai vào bản đồ (FT-63) +
`CODEMAP.md` thay vì thêm miễn trừ. Đây là lần thứ hai trong phiên một cổng mới bắt đúng người vừa
dựng nó (lần đầu: mục 1 chặn đường dẫn `.framework-new` trong TRAPS 31).
