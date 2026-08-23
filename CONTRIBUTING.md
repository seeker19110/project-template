# Đóng góp (Contributing)

Đọc `CLAUDE.md` trước, rồi đến điểm vào duy nhất
`docs/framework/standard-delivery.md`. Contract này sẽ định tuyến tới hướng dẫn theo đúng stack/hồ sơ.

Mọi tương tác trong dự án tuân theo [Quy tắc ứng xử](CODE_OF_CONDUCT.md).

## Luồng chuẩn (canonical flow)

**Frame → Research → Approve Spec → Plan → Build → Verify → Integrate → Observe → Reconcile.**

**Không được bắt đầu code tính năng** trước khi `docs/specs/*` được đánh dấu **Approved for
implementation** kèm người duyệt/ngày duyệt. Goal trải qua nhiều PR dùng `docs/goals/*`,
mỗi iteration/PR đúng một outcome.

## Git và PR

- Nhánh: `docs/spec-...` cho research/spec; `feat|fix|refactor/<issue>-<slug>` cho phần triển khai.
- Conventional Commits; commit nhỏ theo từng thay đổi logic; không push thẳng nhánh mặc định.
- Mở draft PR sớm và link tới Goal/Issue/Spec.
- Chỉ chuyển Ready khi có bằng chứng + đạt các cổng theo hồ sơ; chỉ merge qua PR đã được review và có thẩm quyền.
- Sau khi release: kiểm chứng health/metric/guardrail và checkpoint lại Goal.

## Definition of Ready / Done

Dùng DoR/DoD chuẩn trong `standard-delivery.md`. Lệnh của dự án lấy từ `CLAUDE.md`/manifest của
chính dự án; **không bao giờ** sao chép lệnh đặc thù hồ sơ Web sang hồ sơ khác khi chưa xác minh.

## Giới hạn vòng lặp AI

Một iteration = một outcome = một PR. Reconcile từ nhánh mặc định hiện tại, không từ trí nhớ chat.
Sửa cùng một lỗi tối đa ba lần. Dừng ở trạng thái WAITING/BLOCKED khi cần: phê duyệt, đánh đổi
sản phẩm/kiến trúc, thay đổi phá hủy/breaking, đụng production/bí mật/chi phí/quyền mới, CI ngoài
phạm vi, hoặc vượt guardrail. **Không bao giờ** làm yếu test hay bảo mật để qua cổng.

## Tự động hóa

Không né hook, CI, PR policy, quét bí mật/bảo mật hay branch protection. Cấu hình required checks
khớp đúng hồ sơ dự án đã chọn và kiểm chứng protection bằng một PR cố tình fail.
