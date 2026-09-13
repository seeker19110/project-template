#!/usr/bin/env bash
# subagent-dispatch.sh — Wrapper script cho Universal Subagent Dispatcher Engine.
# Hoạt động an toàn trên mọi hệ điều hành (Linux, macOS, Windows/MSYS).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi

PYTHON_CMD=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD="python"
else
  echo "Error: Python 3 là bắt buộc để chạy subagent-dispatch engine." >&2
  exit 1
fi

exec "$PYTHON_CMD" "$ROOT/scripts/subagent-dispatch.py" "$@"
