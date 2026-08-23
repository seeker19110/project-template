# docs/specs — Feature Spec (contract từng tính năng)

> Thư mục **bắt buộc tồn tại**: cổng `pr-policy.yml` yêu cầu mọi PR `feat` liên kết tới một file
> `docs/specs/<YYYY-MM-DD>-<slug>.md` đã ghi **Approved for implementation** (kèm người duyệt + ngày).
> Luật gốc: `docs/framework/standard-delivery.md` §2–§3 và `CLAUDE.md` mục 2.

## Cách dùng
1. Copy `docs/framework/templates/FEATURE-SPEC.template.md` thành `docs/specs/<ngày>-<slug>.md`.
2. Điền research + contract của tính năng; **chưa Approved thì chưa được sửa source code.**
3. Người duyệt ghi rõ `Approved for implementation` + tên + ngày, rồi mới mở PR `feat`.

Goal nhiều PR dùng `docs/goals/` (mẫu `docs/framework/templates/GOAL.template.md`).
