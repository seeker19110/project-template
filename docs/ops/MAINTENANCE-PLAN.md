# Kế hoạch bảo trì — 2026-09-15

Nguồn: docs/ops/MAINTENANCE-REPORT.md (quét 2026-09-15) · Trạng thái: **ĐÓNG** (duyệt 2026-09-15 — không có mục hành động)

## Tóm tắt quét

Lệnh chạy: `bash scripts/maintenance-sweep.sh --out docs/ops/MAINTENANCE-REPORT.md`
(mặc định: CÓ kiểm dependency, KHÔNG `--gate`, KHÔNG `--strict`). Exit code: 0.
Kết quả: **🔴 0 · 🟡 0 · ℹ️ 5** — không có phát hiện ở mức cần hành động.

| Mảng | Mức | Phát hiện |
| --- | --- | --- |
| Git | ℹ️ | commit gần nhất 0 ngày trước; 0 file chưa commit; 0 nhánh local đã merge chưa xoá; nhánh hiện tại khớp `origin/main` |
| Dependency | ℹ️ | `deps_outdated`/`deps_audit` chưa khai ở `.claude/project-commands.sh` — **cố ý**, repo khung không có `package.json`/lockfile thật (CLAUDE.md §10 ghi rõ placeholder này là cho dự án đích, không phải thiếu sót của repo khung) |
| Tài liệu & nợ kỹ thuật | ℹ️ | PROGRESS.md cập nhật cùng ngày; 0 spec Draft/In review; 0 goal BLOCKED; 10 TODO/FIXME/HACK (ngưỡng cảnh báo 20 — dưới ngưỡng); 0 dấu `DEBT:` |
| Vệ sinh repo & bí mật | ℹ️ | không có `.env` bị track; không có chuỗi giống bí mật; không có file >1MB bị track |
| CI & chuỗi cung ứng | ℹ️ | 7 workflow, tất cả action đã ghim full SHA; có `dependabot.yml` |
| Cổng khung & gate dự án | ℹ️ | docs-consistency ✅ · ci-policy ✅ · arch-health-radar 100/100 · dev-task gate bỏ qua (không dùng `--gate` trong lượt này) |

## Đối chiếu 10 TODO/FIXME/HACK

Đã grep thủ công (`grep -rnE "TODO|FIXME|HACK"`) toàn repo. Phần lớn kết quả là:
- Chuỗi `TODO`/`FIXME` xuất hiện trong **văn xuôi tài liệu** giải thích chính engine dò TODO
  (`CLAUDE.md`, `AGENTS.md`, `docs/specs/*`, `docs/framework/quality-supplements-group2.md`).
- Chuỗi `TODO` trong **code của chính engine** (`scripts/arch-health-radar.py`,
  `scripts/maintenance-sweep.sh`, `scripts/test-py-coverage.sh`, `scripts/test-engine-characterization.sh`)
  là regex/comment mô tả logic dò TODO hoặc fixture giả lập cho test — không phải nợ kỹ thuật thật
  còn sót.

Không tìm thấy dấu `TODO:`/`FIXME:`/`HACK:` nào là việc dở dang thật chưa có kế hoạch xử lý. Không
lập mục PR cho phần này.

## Việc cần làm (M-xx)

Không có. Sweep sạch (🔴 0 · 🟡 0), không có phát hiện nào đủ ngưỡng để mở PR bảo trì trong đợt này.

## Không làm / chờ quyết định

- Khai `deps_outdated`/`deps_audit` trong `.claude/project-commands.sh` — **không làm**: đây là
  placeholder có chủ đích cho dự án đích copy khung, repo khung không có dependency manager thật
  (không có `package.json`/`requirements.txt`/lockfile). Khai giả một lệnh ở đây sẽ là dữ liệu bịa,
  vi phạm CLAUDE.md §4 (chống ảo giác). Nếu về sau repo khung tự thêm tooling có dependency thật
  (vd một script Python cần thư viện ngoài) thì xem lại.

## Báo oan đã loại

Không có báo oan trong đợt quét này — mọi dòng ℹ️ trong report đều phản ánh đúng trạng thái thật
của repo, không phát hiện dòng nào của engine chạy sai/đo sai cần sửa ngưỡng hay loại trừ.

## Giới hạn của lượt quét này

- Không dùng `--gate`: build/type/lint/test dự án đích **không** được chạy lại trong lượt này (repo
  khung không có bộ lệnh dev app thật để chạy `dev-task.sh gate` có ý nghĩa — cổng riêng của repo
  khung là `framework-lint`/`docs-consistency`/`progress-freshness` chạy trong CI, không nằm trong
  phạm vi `maintenance-sweep.sh --gate`).
- Không dùng `--strict`: không áp ngưỡng nghiêm ngặt hơn mặc định.
- Mảng Dependency chỉ trả kết quả `n-a` vì lý do đã nêu ở trên — không phải bỏ qua do lỗi, mà do
  bản chất repo khung không có dependency manager để kiểm.

## Đính chính sau kiểm chứng của Tầng 1

Tầng 1 chạy lại `scripts/maintenance-sweep.sh --strict` để kiểm chứng (không tin lời khai —
CLAUDE.md §4). Hai điểm cần ghi đúng thay vì để nguyên báo cáo của subagent:

1. **`--strict` ra 🟡 1, không phải 🟡 0.** Dòng đó là *"1 file chưa commit trong working tree"* —
   và file chưa commit chính là `docs/ops/MAINTENANCE-PLAN.md` mà lượt quét vừa sinh ra. Bộ dò tự
   khớp sản phẩm của chính nó, đúng khuôn đã ghi nhiều lần ở `PROGRESS.md`/`TRAPS.md`. Không phải
   phát hiện thật, nhưng cũng không được rút gọn thành "strict cũng sạch".
2. **Con số TODO khác nhau tuỳ cách đếm.** Engine báo 10; `git grep -nE 'TODO|FIXME|HACK'` thô ra
   36 dòng trên 12 file. Tập file trùng khớp và toàn bộ nằm trong văn xuôi tài liệu mô tả chính
   engine dò TODO, hoặc trong code/test/fixture của engine đó — kết luận "không có nợ kỹ thuật thật
   bị bỏ sót" vẫn đứng, nhưng con số 10 là số của engine, không phải số dòng thô.
