#!/usr/bin/env bash
# test-telemetry-and-dispatch.sh — Tự kiểm tra Universal Subagent Dispatch & Telemetry Engine.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi

source "$ROOT/scripts/_test-lib.sh"

echo "== 1. Subagent Dispatcher Engine =="

out_list="$(bash "$ROOT/scripts/subagent-dispatch.sh" --list 2>&1)"
if echo "$out_list" | grep -q "security-reviewer"; then
  ok "subagent-dispatch --list liệt kê thành công subagents"
else
  bad "subagent-dispatch --list thất bại"
fi

# --- A-03 (audit 2026-09-13): đầu ra cho mỗi harness phải là CƠ CHẾ CÓ THẬT ---
# Bản cũ sinh "/subagent <tên> <task>" cho Claude Code, nhưng .claude/commands/ không có
# subagent.md — dán vào Claude Code sẽ không chạy. Cơ chế thật là tool Task + subagent_type.
out_claude="$(bash "$ROOT/scripts/subagent-dispatch.sh" --agent tester --task "Kiem tra" --harness claude 2>&1)"
if echo "$out_claude" | grep -q '/subagent'; then
  bad "A-03: đầu ra cho Claude Code vẫn chứa '/subagent' — lệnh này KHÔNG tồn tại"
else
  ok "A-03: đầu ra cho Claude Code không còn lệnh '/subagent' không tồn tại"
fi
if echo "$out_claude" | grep -q 'subagent_type="tester"'; then
  ok "A-03: đầu ra nêu đúng cơ chế thật (tool Task + subagent_type)"
else
  bad "A-03: đầu ra không nêu tool Task/subagent_type"
fi

# Đối chứng: mọi lệnh slash sinh ra (nếu có) phải có file thật trong .claude/commands/.
for slash in $(echo "$out_claude" | grep -oE '(^|[[:space:]])/[a-z][a-z0-9-]*' | tr -d ' /' | sort -u); do
  if [ ! -f "$ROOT/.claude/commands/$slash.md" ]; then
    bad "A-03: đầu ra nhắc lệnh /$slash nhưng .claude/commands/$slash.md không tồn tại"
  fi
done

# Harness không được hỗ trợ phải BÁO LỖI rõ, không đoán bừa (FR-2).
if bash "$ROOT/scripts/subagent-dispatch.sh" --agent tester --task d --harness cursor >/dev/null 2>&1; then
  bad "A-03: harness 'cursor' chưa hỗ trợ nhưng vẫn chạy — đang đoán bừa"
else
  ok "A-03: harness chưa hỗ trợ → báo lỗi rõ, không đoán bừa"
fi

out_hermes="$(bash "$ROOT/scripts/subagent-dispatch.sh" --agent security-reviewer --task "Test Task" --harness hermes 2>&1)"
if echo "$out_hermes" | grep -q '"tasks"'; then
  ok "subagent-dispatch --harness hermes xuất JSON delegate_task hợp lệ"
else
  bad "subagent-dispatch --harness hermes thất bại"
fi

# Ca này TRƯỚC ĐÂY assert đầu ra PHẢI chứa "/subagent complex-implementer" — tức là test
# khoá chặt đúng cái lỗi A-03 thay vì bắt nó. Một test viết theo hành vi sai sẽ bảo vệ
# hành vi sai. Nay assert theo CƠ CHẾ THẬT của Claude Code.
out_claude_ci="$(bash "$ROOT/scripts/subagent-dispatch.sh" --agent complex-implementer --task "Test Task" --harness claude 2>&1)"
if echo "$out_claude_ci" | grep -q 'subagent_type="complex-implementer"'; then
  ok "subagent-dispatch --harness claude nêu đúng subagent_type cho tool Task"
else
  bad "subagent-dispatch --harness claude không nêu subagent_type đúng"
fi

echo "== 2. Telemetry & Observability Engine =="

out_rec="$(bash "$ROOT/scripts/telemetry-log.sh" --record --agent test-agent --harness test-harness --task "Self Test" --duration 1.5 --test-status PASSED 2>&1)"
if echo "$out_rec" | grep -q "Recorded telemetry entry"; then
  ok "telemetry-log --record ghi nhận entry thành công"
else
  bad "telemetry-log --record thất bại"
fi

out_sum="$(bash "$ROOT/scripts/telemetry-log.sh" --summary 2>&1)"
if echo "$out_sum" | grep -q "AI Execution & Observability Summary"; then
  ok "telemetry-log --summary sinh báo cáo Markdown thành công"
else
  bad "telemetry-log --summary thất bại"
fi

out_widget="$(bash "$ROOT/scripts/telemetry-log.sh" --widget 2>&1)"
if echo "$out_widget" | grep -q "::preview{file="; then
  ok "telemetry-log --widget sinh HTML widget thành công"
else
  bad "telemetry-log --widget thất bại"
fi

if [ "$fails" -eq 0 ]; then
  echo "OK — Tất cả kiểm tra Universal Subagent Dispatch & Telemetry đều XANH."
  exit 0
else
  echo "FAIL — Có $fails ca kiểm tra thất bại."
  exit 1
fi
