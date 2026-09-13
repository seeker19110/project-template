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
