# Feature spec: Spec-to-Contract Compiler & Tech Debt Radar Engine

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Tự động hóa chuyển biên dịch Markdown Spec sang Executable Contract Tests & Radar sức khỏe kiến trúc |
| Spec owner | Hermes Agent |
| State | **Approved for implementation** |
| Approver / date | Người dùng (chat) / 2026-09-13 |
| Last updated | 2026-09-13 |

## 1. Problem, user và evidence

Các tài liệu đặc tả bằng Markdown thuần (`docs/specs/*.md`) dễ bị trôi và hiểu sai nếu không có kiểm thử tự động thi hành hợp đồng. Đồng thời, kỹ sư thiếu công cụ radar đo đạc tổng thể sức khỏe kiến trúc và nợ kỹ thuật (Tech Debt).

## 2. Outcome, baseline, target và guardrails

Xây dựng `scripts/spec-compiler.py` tự động biên dịch Markdown specs sang unittest contracts, và `scripts/arch-health-radar.py` tính toán chỉ số sức khỏe kiến trúc.

## 3. Research current state

Trước thay đổi này, việc đối chiếu spec được thực hiện qua rà soát thủ công hoặc prompt.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Giữ rà soát thủ công | Không cần script mới | Dễ sót chi tiết | Không chọn |
| Spec Compiler & Health Radar Engine | Tự động hoá 100%, có bằng chứng thực thi | Cần bổ sung test suite tự kiểm | **Chọn** |

## 5. Scope / non-goals

Trong phạm vi: Spec compiler engine, health radar engine, shell wrappers, unittest contracts generator, self-testing suite.
