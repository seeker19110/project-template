# Feature spec: Quick Start và adoption preflight

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Cải thiện lần áp dụng đầu tiên của project template |
| Spec owner | Codex |
| State | **Approved for implementation** |
| Approver / date | Người dùng (chat) / 2026-09-13 |
| Last updated | 2026-09-13 |

## 1. Problem, user và evidence

Người mới gặp README và runbook rất đầy đủ nhưng dài; họ khó xác định đường đi đầu tiên và dễ nhầm CI của khung với quality gate thật của ứng dụng đích.

## 2. Outcome, baseline, target và guardrails

Thêm một đường dẫn định hướng đọc trong khoảng 10 phút cho greenfield và brownfield, kèm preflight có thể đánh dấu. Không thay Standard Delivery Contract, không áp stack mặc định và không tự nhận checklist là cổng tự động.

## 3. Research current state

`README.md` dẫn thẳng đến `standard-delivery.md`; chi tiết áp dụng nằm rải ở `new-project-runbook.md` và `existing-project-adoption.md`. CI hiện chỉ kiểm chính framework khi chưa có app.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Giữ nguyên | Không thêm tài liệu | Rào cản nhập môn cao | Không chọn |
| Một quick start + checklist | Dễ định hướng, không đổi quy trình lõi | Cần giữ liên kết nhất quán | **Chọn** |
| Tạo scaffold mặc định | Nhanh cho một số người dùng | Mâu thuẫn ADR-0004, không phổ quát | Không chọn |

## 5. Scope / non-goals

Trong phạm vi: trang quick start, checklist preflight, liên kết từ README và chỉ mục framework. Ngoài phạm vi: scaffold, workflow CI mới, thay đổi gate hoặc bắt buộc tool/stack.

## 6. User journeys và mọi state

- Greenfield: chọn đường dẫn, copy khung, định nghĩa dự án, research profile rồi qua feature spec.
- Brownfield: inventory hiện trạng, copy không đè, merge dropins có chủ đích, baseline gate.
- Nếu chưa xác định stack hoặc còn câu hỏi kiến trúc: dừng ở research/approval, không bắt đầu code.

## 7. Functional requirements

- FR-1: Có một trang quick start được README và framework index liên kết.
- FR-2: Phân biệt rõ greenfield với brownfield.
- FR-3: Có preflight xác nhận app có lệnh/gate thực, CI, bảo mật, ruleset và rollback phù hợp.
- FR-4: Nêu rõ checklist không thay thế Standard Delivery Contract hay evidence chạy thật.

## 8. Non-functional requirements

Nội dung tiếng Việt, độc lập stack, liên kết nội bộ hợp lệ và không thêm phụ thuộc hay bí mật.

## 9. Acceptance criteria

- AC-1: Người dùng tìm được quick start từ README và `docs/framework/README.md`.
- AC-2: Mỗi đường dẫn nêu bước tiếp theo và điều kiện dừng rõ ràng.
- AC-3: Preflight có mục phân biệt framework gate với app gate.
- AC-4: `check-docs-consistency.sh`, `check-ci-policy.sh` và smoke tests của khung xanh.

## 10. UX/content/accessibility

Dùng heading ngắn, checkbox và link tương đối; không dựa vào màu sắc hoặc hình ảnh.

## 11. Architecture và code touchpoints

`README.md`, `docs/framework/README.md`, `docs/framework/quickstart.md`, `docs/specs/2026-09-13-quickstart-adoption.md`.

## 14. Security/privacy/abuse cases

Quick start nhắc kiểm secrets, quyền branch và rollback; không thu thập hay xử lý dữ liệu.

## 16. Test/eval plan

Chạy các script kiểm link/chính sách và smoke test copy framework; tự đọc lại checklist theo hai hành trình.

## 17. Slice/PR plan

Một PR tài liệu: spec đã duyệt, quick start, liên kết README/index và changelog.

## 18. Rollout/rollback

Merge như thay đổi docs; rollback bằng revert một commit nếu link hoặc nội dung gây nhầm lẫn.

## 19. Risk, assumptions và open decisions

| Item | Verification/mitigation | Owner | Due | Decision |
| --- | --- | --- | --- | --- |
| Checklist bị hiểu là cổng tự động | Ghi rõ đây là preflight thủ công; gate thật theo profile | Codex | PR này | Đã xử lý |

## Approval

- [x] Product/scope
- [x] UX/a11y
- [x] Architecture/API/data (không áp dụng)
- [x] Security/privacy/cost
- [x] Test/telemetry/rollout/rollback
- [x] Blocking decisions closed

**Conclusion:** **Approved for implementation**  
**Approver/date:** Người dùng (chat), 2026-09-13
