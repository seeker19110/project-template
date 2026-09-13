#!/usr/bin/env bash
# test-next-gen-engines.sh — Tự kiểm tra Spec-to-Contract Compiler và Architectural Health Radar Engine.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi

fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }

echo "== 1. Autonomous Spec-to-Contract Compiler Engine =="

out_compile="$(bash "$ROOT/scripts/spec-compiler.sh" --compile-all 2>&1)"
if echo "$out_compile" | grep -q "Compiled contract test"; then
  ok "spec-compiler --compile-all biên dịch thành công Markdown specs sang Executable Tests"
else
  bad "spec-compiler --compile-all thất bại"
fi

PYTHON_CMD="python3"
command -v python3 >/dev/null 2>&1 || PYTHON_CMD="python"

out_unittest="$("$PYTHON_CMD" -m unittest discover -s "$ROOT/tests/contracts" 2>&1)"
if echo "$out_unittest" | grep -q "OK"; then
  ok "Tất cả Executable Spec Contract Tests chạy thành công (PASSED)"
else
  bad "Executable Spec Contract Tests thất bại"
fi

echo "== 2. Architectural Health & Tech Debt Radar Engine =="

out_radar="$(bash "$ROOT/scripts/arch-health-radar.sh" --scan 2>&1)"
if echo "$out_radar" | grep -q "Architectural Health & Tech Debt Radar"; then
  ok "arch-health-radar --scan tạo báo cáo sức khỏe kiến trúc thành công"
else
  bad "arch-health-radar --scan thất bại"
fi

if [ "$fails" -eq 0 ]; then
  echo "OK — Tất cả kiểm tra Next-Gen Engines (Spec Compiler & Health Radar) đều XANH."
  exit 0
else
  echo "FAIL — Có $fails ca kiểm tra thất bại."
  exit 1
fi
