#!/usr/bin/env bash
# test-telemetry-and-dispatch.sh — Tự kiểm tra Universal Subagent Dispatch & Telemetry Engine.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi

fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }

echo "== 1. Subagent Dispatcher Engine =="

out_list="$(bash "$ROOT/scripts/subagent-dispatch.sh" --list 2>&1)"
if echo "$out_list" | grep -q "security-reviewer"; then
  ok "subagent-dispatch --list liệt kê thành công subagents"
else
  bad "subagent-dispatch --list thất bại"
fi

out_hermes="$(bash "$ROOT/scripts/subagent-dispatch.sh" --agent security-reviewer --task "Test Task" --harness hermes 2>&1)"
if echo "$out_hermes" | grep -q '"tasks"'; then
  ok "subagent-dispatch --harness hermes xuất JSON delegate_task hợp lệ"
else
  bad "subagent-dispatch --harness hermes thất bại"
fi

out_claude="$(bash "$ROOT/scripts/subagent-dispatch.sh" --agent complex-implementer --task "Test Task" --harness claude 2>&1)"
if echo "$out_claude" | grep -q "/subagent complex-implementer"; then
  ok "subagent-dispatch --harness claude xuất lệnh /subagent hợp lệ"
else
  bad "subagent-dispatch --harness claude thất bại"
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
