#!/usr/bin/env bash
# check-python-complexity.sh — CỔNG MÁY cưỡng chế ngưỡng độ phức tạp vòng (cyclomatic
# complexity) cho mọi engine Python trong `scripts/`.
#
# VÌ SAO CÓ FILE NÀY: ngưỡng "CC ≤ 12" đã được nhắc ở nhiều chỗ trong repo (ADR-0005,
# `scripts/test-engine-characterization.sh`, dấu nợ kỹ thuật của `arch-health-radar.py`) nhưng
# CHƯA từng có cổng nào cưỡng chế — nó chỉ nằm trong văn xuôi. Đúng khuôn hỏng ghi ở
# `TRAPS.md` mục 14: luật không có cổng là trang trí, mục âm thầm rồi tái phát. Dấu nợ kỹ thuật
# của `format_markdown_report` ghi rõ điều kiện xem lại là "repo dựng cổng máy cưỡng chế
# CC <= 12" — file này là cổng đó, nên dấu ấy được giải (hàm đã tách xuống dưới ngưỡng).
#
# NGƯỠNG LÀ TRẦN, KHÔNG PHẢI MỤC TIÊU: nâng `PY_CC_MAX` để CI xanh là tự bịt mắt mình —
# muốn nâng thì phải nêu lý do đo được trong PR. KHÔNG có cơ chế miễn trừ theo hàm: một
# ngoại lệ im lặng là cổng xanh giả.
#
# Chạy: bash scripts/check-python-complexity.sh        (cần: python3 -m pip install radon)
set -uo pipefail   # cố ý KHÔNG -e: cổng gom MỌI vi phạm trong một lượt rồi mới thoát; cố ý ĐỎ khi thiếu radon (xem docs/CONVENTIONS.md §A)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi
cd "$ROOT" || exit 1

MAX="${PY_CC_MAX:-12}"

PYTHON_CMD="python3"
command -v python3 >/dev/null 2>&1 || PYTHON_CMD="python"

if ! "$PYTHON_CMD" -m radon --version >/dev/null 2>&1; then
  # CỐ Ý đỏ chứ không "skip": cổng tự tắt khi thiếu công cụ là cổng xanh giả (cùng lý do
  # với `test-py-coverage.sh`).
  echo "::error::Thiếu radon — cài bằng: $PYTHON_CMD -m pip install radon" >&2
  exit 1
fi

mapfile -t PY_FILES < <(find scripts -name '*.py' | sort)
if [ "${#PY_FILES[@]}" -eq 0 ]; then
  echo "::error::Không tìm thấy file .py nào trong scripts/ — cổng này lẽ ra phải có gì đó để đo." >&2
  exit 1
fi

echo "== Độ phức tạp vòng (radon CC) — trần: $MAX =="

RAW="$(mktemp)"
trap 'rm -f "$RAW"' EXIT
if ! "$PYTHON_CMD" -m radon cc --json "${PY_FILES[@]}" > "$RAW" 2>"$RAW.err"; then
  echo "::error::radon chạy lỗi:" >&2; cat "$RAW.err" >&2; rm -f "$RAW.err"; exit 1
fi
rm -f "$RAW.err"

# PYTHONIOENCODING: console Windows mặc định cp1252 → in tiếng Việt sẽ UnicodeEncodeError
# (TRAPS.md bẫy 24 — khối reconfigure trong file .py không áp cho heredoc inline này).
MAX="$MAX" PYTHONIOENCODING=utf-8 "$PYTHON_CMD" - "$RAW" <<'PYEOF'
import json, os, sys

max_cc = int(os.environ["MAX"])
with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)

violations = []
measured = 0
worst = ("—", 0)

for path, blocks in sorted(data.items()):
    if isinstance(blocks, dict) and "error" in blocks:
        # radon không đọc được file (cú pháp hỏng) → ĐỎ, không bỏ qua im lặng.
        msg = blocks["error"]
        print("::error file=%s::radon không phân tích được: %s" % (path, msg))
        sys.exit(1)
    for b in blocks:
        measured += 1
        cc = b["complexity"]
        if cc > worst[1]:
            worst = ("%s::%s" % (path, b["name"]), cc)
        if cc > max_cc:
            violations.append((path, b["lineno"], b["name"], cc))

print("Đã đo %d khối (hàm/lớp/method) trong %d file." % (measured, len(data)))
print("Cao nhất: %s = CC %d" % worst)

for path, line, name, cc in violations:
    print("::error file=%s,line=%d::`%s` có CC %d > trần %d — tách hàm (hoặc chuyển nhánh "
          "lặp lại thành bảng dữ liệu) trước khi commit." % (path, line, name, cc, max_cc))

if violations:
    print("\nFAIL — %d khối vượt trần CC %d. Đừng nâng trần để CI xanh." % (len(violations), max_cc))
    sys.exit(1)

print("OK — mọi khối Python trong scripts/ đều ≤ CC %d." % max_cc)
PYEOF
