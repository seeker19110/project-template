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
- Giai đoạn: **GIAI ĐOẠN 1 (chỉ quét & đo, KHÔNG sửa gì)**

| # | Nhóm | Trạng thái | Tóm tắt phát hiện (số lượng theo mức độ) | Cập nhật lần cuối |
|---|------|-----------|-------------------------------------------|---------------------|
| 1 | Kiến trúc & thiết kế | ✅ Xong | Cao 0 · **Trung 2** (A-1, A-3) · Thấp 1 (A-2). Ranh giới 3 lớp còn đúng, **0 phụ thuộc vòng** (đồ thị lời gọi là DAG), ADR-0004/0005/0006/0007 khớp code | 2026-09-15 |
| 2 | Bảo mật | ✅ Xong | Cao 0 · Trung 0 · **Thấp 2** (F-001 eval tên biến động; F-002 ví dụ token inline trong comment crontab) | 2026-09-15 |
| 3 | Chất lượng mã & chống lỗi logic | ⬜ | | |
| 4 | Kiểm thử & coverage | ⬜ | | |
| 5 | Hiệu năng | ⬜ | | |
| 6 | Accessibility & UI/UX | ⬜ | | |
| 7 | Dependency & chuỗi cung ứng | ✅ Xong | 0 phát hiện — **16/16** `uses:` ghim full SHA 40 ký tự (0 tag trôi); `dependabot.yml` phủ cả npm + github-actions; `vendor/shellmetrics` có README nguồn + phiên bản 0.5.0 + LICENSE MIT + SHA256SUMS; không có `curl \| bash`; `npx --no-install`; `pip install` ghim `==`. KHÔNG chạy `npm audit` (không có package.json — chạy sẽ vô nghĩa) | 2026-09-15 |
| 8 | CI/CD & vận hành/observability | ⬜ | | |
| 9 | Tài liệu & đồng bộ | ✅ Xong | **Cao 2** (F-101 cổng JSON tắt im lặng; F-102 FEATURE-MAP thiếu 8 engine) · Trung 2 (F-103, F-104) | 2026-09-15 |
| 10 | Dữ liệu & migration | ⬜ | | |
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
