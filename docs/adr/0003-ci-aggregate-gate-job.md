# ADR-0003: Job tổng hợp `gate` trong CI làm required check duy nhất

- **Trạng thái:** Đã chấp nhận
- **Ngày:** 2026-09-12
- **Liên quan:** `.github/workflows/ci.yml`, `docs/ops/repository-settings.md`, `scripts/check-ci-policy.sh` (F-010, W-304)

## Bối cảnh

`ci.yml` có 6 job **phẳng, không `needs:`** (`framework-lint`, `docs-consistency`,
`copy-framework-smoke`, `quality`, `source-hygiene`, `e2e`). Không có job tổng hợp, nên branch
protection trên GitHub phải liệt kê **đúng tên từng job**. Hệ quả đã thấy trong audit 2026-09-12
(F-010):

- Thêm một job cổng mới mà quên khai trong branch protection → job chạy, đỏ vẫn merge được
  (**cổng hình thức**).
- Đổi tên/xoá một job → required check cũ không bao giờ báo cáo nữa → PR kẹt vĩnh viễn, không
  PR nào hiện đỏ để lần ra nguyên nhân.

`scripts/check-ci-policy.sh` (PR #62) đã bịt một nửa vấn đề: nó đối chiếu hai chiều job id thật
với danh sách trong `docs/ops/repository-settings.md`. Nhưng nửa còn lại vẫn thủ công — người
dùng phải vào Settings GitHub cập nhật danh sách bằng tay, và không có gì kiểm chuyện đó.

## Quyết định

Thêm job `gate` vào `ci.yml`: `needs:` toàn bộ job còn lại, `if: always()`, fail nếu bất kỳ
`needs.*.result` khác `success`. Branch protection chỉ cần khoá **`gate`** (ci.yml) và
**`metadata`** (pr-policy.yml).

`scripts/check-ci-policy.sh` vẫn giữ đối chiếu hai chiều **toàn bộ job** (khối code trong
`repository-settings.md` là *bản kê job*, không phải danh sách cần tick trên GitHub) — vì nó còn
bắt được chuyện thêm job mà quên đưa vào `needs:` của `gate`.

## Lý do

- Thêm job cổng mới: chỉ cần thêm vào `needs:` của `gate` (cùng file, cùng PR) — không phải vào
  Settings GitHub. Sai sót còn lại được `check-ci-policy.sh` bắt ở CI.
- `if: always()` + kiểm `needs.*.result` là khuôn chuẩn: nếu chỉ dùng `needs:` mặc định, job
  `gate` sẽ **bị skip** khi một job cha đỏ, và GitHub coi required check "skipped" là **đạt** —
  đúng kiểu hỏng im lặng mà khung chống.

## Đánh đổi

- Thêm một job (≈ 10 s runner) cho mỗi lượt CI.
- `gate` chỉ mạnh bằng danh sách `needs:` của nó → phải có cổng canh, nên `check-ci-policy.sh`
  bổ sung kiểm "mọi job trong `ci.yml` đều có mặt trong `needs:` của `gate`".

## Phương án đã loại

- **Giữ nguyên, chỉ dựa vào `check-ci-policy.sh`:** không giải quyết phần thủ công trên GitHub.
- **Gộp tất cả vào một job khổng lồ:** mất chạy song song (e2e + quality nối tiếp), chậm gấp bội,
  và mất khả năng đọc job nào đỏ.
