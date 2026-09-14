# Feature spec: Universal Subagent Dispatch Protocol & AI Telemetry Observability Engine

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Nâng cấp bộ khung hỗ trợ tương tác đa-harness (Hermes, Claude, Codex, Cursor) & đo lường telemetry |
| Spec owner | Hermes Agent |
| State | **Approved for implementation** |
| Approver / date | Người dùng (chat) / 2026-09-13 |
| Last updated | 2026-09-13 |

## 1. Problem, user và evidence

Các AI Coding Tool khác nhau (Hermes Agent, Claude Code, OpenAI Codex, Cursor, Windsurf) sử dụng giao thức gọi agent và format câu lệnh khác nhau. Môi trường Windows MSYS có sự lệch dòng ký tự (CRLF) gây đỏ gate kiểm tra.

## 2. Outcome, baseline, target và guardrails

Tạo công thức Subagent Dispatch Engine (`scripts/subagent-dispatch.py` & `.sh`) và Telemetry Engine (`scripts/telemetry-log.py` & `.sh`), bổ sung bộ test tự động (`scripts/test-telemetry-and-dispatch.sh`), chuẩn hoá xử lý ký tự xuống dòng trên Windows.

## 3. Research current state

Bộ khung hiện chỉ hỗ trợ subagent native qua Claude Code CLI (`.claude/agents/*.md`). Các AI harness khác thiếu giao thức nạp subagent và telemetry.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Giữ nguyên | Không thêm file script | Hạn chế đa-harness | Không chọn |
| Script Dispatcher & Telemetry Python/Bash | Tương thích 100% mọi AI harness, cross-platform | Cần thêm test suite tự kiểm | **Chọn** |

## 5. Scope / non-goals

Trong phạm vi: Subagent Dispatch Engine, AI Telemetry Logger, HTML Widget & Markdown summary, test suite, cross-platform fix cho Windows/MSYS.

## 7. Functional requirements

- **FR-1** `subagent-dispatch.py` đọc `.claude/agents/*.md` và xuất chỉ dẫn giao việc cho harness đích.
- **FR-2** Chỉ khai những harness **thật sự có nhánh xử lý**; không kê tên harness chưa hỗ trợ.
- **FR-3** Đầu ra cho mỗi harness phải là **cơ chế có thật** của harness đó — không sinh lệnh không tồn tại.
- **FR-4** `telemetry-log.py` ghi thời gian, LOC, trạng thái test và ước tính chi phí mỗi tác vụ AI.
- **FR-5** Bảng giá model **không hard-code** trong `.py`; đặt ở `scripts/model-rates.json` kèm
  `_verified_on` + `_source`. Model không khớp bảng → cảnh báo `stderr`, không im lặng dùng `default`.
- **FR-6** Mọi giá trị do người dùng nhập khi xuất HTML/Markdown phải được escape.

## 9. Acceptance criteria

| ID | Given / When / Then | Cách kiểm |
| --- | --- | --- |
| **AC-1** | Given `--agent <tên>` hợp lệ · Then xuất chỉ dẫn kèm đúng vai từ `.claude/agents/<tên>.md` | `scripts/test-telemetry-and-dispatch.sh` |
| **AC-2** | Given `--harness` không nằm trong danh sách hỗ trợ · Then báo lỗi rõ ràng, không đoán | chạy thật |
| **AC-3** | Given `--model claude-haiku-4-5`, 1M in + 1M out · Then chi phí = `$6.0000` (1.00 + 5.00) | chạy thật, đối chiếu `model-rates.json` |
| **AC-4** | Given model không có trong bảng giá · Then in cảnh báo ra `stderr` | chạy thật |
| **AC-5** | Given task chứa `<script>` · Then widget HTML xuất `&lt;script&gt;` | chạy thật |
| **AC-6** | Given thiếu/hỏng `model-rates.json` · Then thoát mã ≠ 0, không ước tính bằng số bịa | chạy thật |

## 11. Architecture và code touchpoints

- `scripts/subagent-dispatch.py` + `scripts/subagent-dispatch.sh`
- `scripts/telemetry-log.py` + `scripts/telemetry-log.sh`
- `scripts/model-rates.json`
- `scripts/test-telemetry-and-dispatch.sh` (self-test, chạy trong job CI `framework-lint`)
- `.claude/agents/`
- `CODEMAP.md`
