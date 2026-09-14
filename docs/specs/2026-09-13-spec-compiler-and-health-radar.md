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

## 7. Functional requirements

- **FR-1** `spec-compiler.py` đọc `docs/specs/*.md` và sinh contract test `unittest` vào `tests/contracts/`.
- **FR-2** Mỗi contract test sinh ra phải **CÓ THỂ ĐỎ**: không được sinh assertion hằng đúng
  (`assertTrue(len(x) >= 0)` và tương đương). Không đủ dữ liệu để kiểm → `skipTest`, không assert bừa.
- **FR-3** Hợp đồng kiểm được: C-1 spec khai `State`; C-2 spec khai ≥ 1 mã yêu cầu; C-3 mọi đường
  dẫn trong mục "11. Architecture và code touchpoints" của spec **đã Approved** phải tồn tại thật.
- **FR-4** Miễn trừ C-3 phải khai ngay trong spec kèm **lý do**: `<!-- contract-exempt: <path> — <lý do> -->`.
- **FR-5** `arch-health-radar.py` xuất báo cáo sức khoẻ; chỉ đo tín hiệu có thật, **không** đếm văn
  xuôi Markdown là "code".

## 9. Acceptance criteria

| ID | Given / When / Then | Cách kiểm |
| --- | --- | --- |
| **AC-1** | Given một spec bất kỳ · When chạy `spec-compiler.py --compile-all` · Then mọi test sinh ra chạy được bằng `python3 -m unittest discover -s tests/contracts` | chạy thật |
| **AC-2** | Given một spec đã Approved khai một đường dẫn KHÔNG tồn tại · Then contract test ĐỎ | negative-test trong `scripts/test-next-gen-engines.sh` |
| **AC-3** | Given mọi đường dẫn đều tồn tại · Then contract test XANH (không đỏ oan) | đối chứng trong cùng test |
| **AC-4** | Given toàn bộ `docs/specs/` hiện tại · Then bộ contract test XANH | job CI `framework-lint` |
| **AC-5** | Given repo khung · When chạy `arch-health-radar.py` · Then tỷ lệ tài liệu phản ánh đúng thực tế (repo đa số là `.md`) | chạy thật, đối chiếu `find`/`wc` |

## 11. Architecture và code touchpoints

- `scripts/spec-compiler.py` + `scripts/spec-compiler.sh`
- `scripts/arch-health-radar.py` + `scripts/arch-health-radar.sh`
- `scripts/test-next-gen-engines.sh` (self-test, chạy trong job CI `framework-lint`)
- `.github/workflows/ci.yml`
- `CODEMAP.md`
