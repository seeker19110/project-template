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
| 1 | Kiến trúc & thiết kế | ⬜ | | |
| 2 | Bảo mật | ✅ Xong | Cao 0 · Trung 0 · **Thấp 2** (F-001 eval tên biến động; F-002 ví dụ token inline trong comment crontab) | 2026-09-15 |
| 3 | Chất lượng mã & chống lỗi logic | ⬜ | | |
| 4 | Kiểm thử & coverage | ⬜ | | |
| 5 | Hiệu năng | ⬜ | | |
| 6 | Accessibility & UI/UX | ⬜ | | |
| 7 | Dependency & chuỗi cung ứng | ✅ Xong | 0 phát hiện — **16/16** `uses:` ghim full SHA 40 ký tự (0 tag trôi); `dependabot.yml` phủ cả npm + github-actions; `vendor/shellmetrics` có README nguồn + phiên bản 0.5.0 + LICENSE MIT + SHA256SUMS; không có `curl \| bash`; `npx --no-install`; `pip install` ghim `==`. KHÔNG chạy `npm audit` (không có package.json — chạy sẽ vô nghĩa) | 2026-09-15 |
| 8 | CI/CD & vận hành/observability | ⬜ | | |
| 9 | Tài liệu & đồng bộ | ⬜ | | |
| 10 | Dữ liệu & migration | ⬜ | | |
| 11 | Cấu hình môi trường & bí mật | ✅ Xong | Cao 0 · Trung 0 · **Thấp 2** (F-003 deny pattern `.claude/settings.json` không phủ thư mục con; F-004 `.gitignore` `.env*.local` không chặn `.env.production`) | 2026-09-15 |
| 12 | Thống nhất chéo tính năng | ⬜ | | |

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
