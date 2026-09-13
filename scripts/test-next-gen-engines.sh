#!/usr/bin/env bash
# test-next-gen-engines.sh — Tự kiểm tra Spec-to-Contract Compiler và Architectural Health Radar Engine.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v cygpath >/dev/null 2>&1; then ROOT="$(cygpath -m "$ROOT")"; fi

fails=0
ok()  { echo "  ✅ $1"; }
bad() { echo "  ❌ $1"; fails=$((fails+1)); }

echo "== 1. Autonomous Spec-to-Contract Compiler Engine =="

PYTHON_CMD="python3"
command -v python3 >/dev/null 2>&1 || PYTHON_CMD="python"

out_compile="$(bash "$ROOT/scripts/spec-compiler.sh" --compile-all 2>&1)"
if echo "$out_compile" | grep -q "Compiled contract test"; then
  ok "spec-compiler --compile-all biên dịch thành công Markdown specs sang Executable Tests"
else
  bad "spec-compiler --compile-all thất bại"
fi

out_unittest="$("$PYTHON_CMD" -m unittest discover -s "$ROOT/tests/contracts" 2>&1)"
if echo "$out_unittest" | grep -q "OK"; then
  ok "Tất cả Executable Spec Contract Tests chạy thành công (PASSED)"
else
  bad "Executable Spec Contract Tests thất bại"
fi

# --- Negative-test cho AC-2/AC-3 (audit 2026-09-13, A-01) ---
# VÌ SAO BẮT BUỘC: bản đầu của spec-compiler sinh 82/82 assertion `assertTrue(len(x) >= 0)` —
# hằng đúng, nên "OK" ở trên KHÔNG chứng minh được gì. Một bộ test không bao giờ đỏ cũng in "OK".
# Hai ca dưới chứng minh contract test THẬT SỰ bắt lỗi, và KHÔNG đỏ oan.
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/docs/specs" "$scratch/tests/contracts" "$scratch/scripts"
# Test sinh ra tính ROOT_DIR = 3 cấp trên chính nó (<scratch>/tests/contracts/x.py -> <scratch>),
# nên ca đối chứng phải trỏ tới file có thật TRONG scratch, không phải trong repo.
printf '#!/usr/bin/env bash\nexit 0\n' > "$scratch/scripts/file-co-that.sh"

# (a) spec đã Approved khai một đường dẫn KHÔNG tồn tại → contract test phải ĐỎ (AC-2)
cat > "$scratch/docs/specs/2099-01-01-ca-am.md" <<'SPEC'
# Feature spec: ca âm

| Thuộc tính | Giá trị |
| --- | --- |
| State | **Approved for implementation** |

## 7. Functional requirements

- **FR-1** Phải có file không tồn tại.

## 11. Architecture và code touchpoints

- `scripts/file-chac-chan-khong-ton-tai.sh`
SPEC
"$PYTHON_CMD" "$ROOT/scripts/spec-compiler.py" --spec "$scratch/docs/specs/2099-01-01-ca-am.md"   --out-dir "$scratch/tests/contracts" >/dev/null 2>&1
if "$PYTHON_CMD" -m unittest discover -s "$scratch/tests/contracts" >/dev/null 2>&1; then
  bad "AC-2: contract test KHÔNG đỏ dù spec Approved trỏ tới file không tồn tại (assertion rỗng?)"
else
  ok "AC-2: contract test ĐỎ đúng lúc — spec Approved trỏ tới file không tồn tại"
fi

# (b) đối chứng: cùng spec nhưng trỏ tới file CÓ THẬT → phải XANH (không đỏ oan) (AC-3)
rm -f "$scratch/tests/contracts"/*.py
sed -i 's|scripts/file-chac-chan-khong-ton-tai.sh|scripts/file-co-that.sh|' "$scratch/docs/specs/2099-01-01-ca-am.md"
"$PYTHON_CMD" "$ROOT/scripts/spec-compiler.py" --spec "$scratch/docs/specs/2099-01-01-ca-am.md"   --out-dir "$scratch/tests/contracts" >/dev/null 2>&1
if "$PYTHON_CMD" -m unittest discover -s "$scratch/tests/contracts" >/dev/null 2>&1; then
  ok "AC-3: contract test XANH khi mọi đường dẫn tồn tại (không đỏ oan)"
else
  bad "AC-3: contract test đỏ oan dù mọi đường dẫn đều tồn tại"
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
