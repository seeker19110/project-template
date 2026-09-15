#!/usr/bin/env bash
# dev-task.sh — điểm vào ỔN ĐỊNH, KHÔNG phụ thuộc stack, cho các tác vụ dev.
#
# Vì sao tồn tại: template hỗ trợ MỌI loại dự án (web/mobile/backend/CLI/data/…),
# nên KHÔNG được hardcode lệnh (npm/ruff/go…) vào hook hay settings. Thay vào đó
# hook chỉ gọi `dev-task.sh <task>`; script này tự phân giải lệnh đúng cho dự án.
#
# Thứ tự phân giải (đầu tiên thắng):
#   1) KHAI BÁO: nếu có .claude/project-commands.sh và định nghĩa biến <task> → chạy.
#   2) TỰ DÒ: nhận diện hệ sinh thái (node/python/go/rust/make) → chạy lệnh quy ước.
#   3) NO-OP: không có gì khớp → in thông báo skip, exit 0 (KHÔNG làm gãy dự án nào).
#
# Task hỗ trợ: format | lint | typecheck | test | build | gate
#   gate = chạy tuần tự build→typecheck→lint→test (cái nào phân giải được), đỏ 1 cái → fail.
#
# Dùng: scripts/dev-task.sh <task>
set -uo pipefail   # cố ý KHÔNG -e: không được làm chết phiên/lượt chạy (xem docs/CONVENTIONS.md §A)

TASK="${1:-}"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DECL="$ROOT/.claude/project-commands.sh"

log() { printf '[dev-task] %s\n' "$*" >&2; }

if [ -z "$TASK" ]; then
  log "thiếu tên task. Dùng: dev-task.sh format|lint|typecheck|test|build|gate"
  exit 2
fi

# --- 1) Lệnh KHAI BÁO (escape hatch cho mọi dự án đặc thù) --------------------
declared_cmd() {
  # In ra lệnh khai báo cho $1 nếu có, ngược lại rỗng.
  [ -f "$DECL" ] || return 0
  # Nạp trong subshell để không rò biến; lấy giá trị biến trùng tên task.
  # shellcheck source=/dev/null  # $DECL là file khai báo của DỰ ÁN ĐÍCH, không tồn tại ở repo khung
  ( set +u; . "$DECL" >/dev/null 2>&1; eval "printf '%s' \"\${$1:-}\"" )
}

# --- 2) TỰ DÒ theo hệ sinh thái ---------------------------------------------
node_pm() {
  if   [ -f "$ROOT/pnpm-lock.yaml" ]; then echo "pnpm"
  elif [ -f "$ROOT/yarn.lock" ];      then echo "yarn"
  elif [ -f "$ROOT/bun.lockb" ];      then echo "bun"
  else echo "npm"; fi
}
node_has_script() {
  # $1 = tên script; true nếu package.json khai báo nó.
  [ -f "$ROOT/package.json" ] || return 1
  if command -v jq >/dev/null 2>&1; then
    jq -e --arg s "$1" '.scripts[$s] // empty' "$ROOT/package.json" >/dev/null 2>&1
  else
    grep -Eq "\"$1\"[[:space:]]*:" "$ROOT/package.json"
  fi
}

# Mỗi hệ sinh thái một hàm dò riêng: in lệnh cho task $1 rồi return 0, hoặc return 1 nếu
# hệ sinh thái này không nhận task đó. Tách ra vì `detected_cmd` gộp cả năm từng ở CC 18 — trên
# trần 12 mà `scripts/check-shell-complexity.sh` cưỡng chế; thêm một hệ sinh thái nữa là thêm
# một hàm + một dòng trong danh sách dưới, không phải thêm một nhánh vào hàm đã quá tải.
_cmd_node() {
  [ -f "$ROOT/package.json" ] && node_has_script "$1" || return 1
  echo "$(node_pm) run $1"
}
_cmd_python() {
  [ -f "$ROOT/pyproject.toml" ] || return 1
  case "$1" in
    format)    command -v ruff >/dev/null 2>&1 && { echo "ruff format ."; return 0; }
               command -v black >/dev/null 2>&1 && { echo "black ."; return 0; } ;;
    lint)      command -v ruff >/dev/null 2>&1 && { echo "ruff check ."; return 0; } ;;
    typecheck) command -v mypy >/dev/null 2>&1 && { echo "mypy ."; return 0; } ;;
    test)      command -v pytest >/dev/null 2>&1 && { echo "pytest -q"; return 0; } ;;
  esac
  return 1
}
_cmd_go() {
  [ -f "$ROOT/go.mod" ] || return 1
  case "$1" in
    format) echo "gofmt -l -w ." ;;
    lint)   echo "go vet ./..." ;;
    test)   echo "go test ./..." ;;
    build)  echo "go build ./..." ;;
    *)      return 1 ;;
  esac
}
_cmd_rust() {
  [ -f "$ROOT/Cargo.toml" ] || return 1
  case "$1" in
    format) echo "cargo fmt" ;;
    lint)   echo "cargo clippy -- -D warnings" ;;
    test)   echo "cargo test" ;;
    build)  echo "cargo build" ;;
    *)      return 1 ;;
  esac
}
_cmd_make() {
  [ -f "$ROOT/Makefile" ] && grep -Eq "^$1:" "$ROOT/Makefile" || return 1
  echo "make $1"
}

detected_cmd() {
  # In ra lệnh tự-dò cho task $1, hoặc rỗng nếu không dò được.
  # THỨ TỰ LÀ HÀNH VI: Node trước (script khai trong package.json thắng mọi suy đoán khác),
  # rồi Python/Go/Rust, Makefile cuối cùng (chỉ khớp khi có target trùng tên).
  local eco
  for eco in _cmd_node _cmd_python _cmd_go _cmd_rust _cmd_make; do
    "$eco" "$1" && return 0
  done
  return 0
}

resolve() { # $1=task -> in lệnh (khai báo ưu tiên), rỗng nếu không có
  local c; c="$(declared_cmd "$1")"; [ -n "$c" ] && { echo "$c"; return 0; }
  detected_cmd "$1"
}

run_task() { # $1=task -> chạy; 0 nếu ok hoặc no-op, khác 0 nếu lệnh fail
  local cmd; cmd="$(resolve "$1")"
  if [ -z "$cmd" ]; then log "skip: chưa cấu hình/dò được '$1'"; return 0; fi
  log "run [$1]: $cmd"
  ( cd "$ROOT" && bash -c "$cmd" )
}

# --- format-file: format ĐÚNG file vừa sửa (dùng cho auto-format hook) --------
declared_format_file() {
  [ -f "$DECL" ] || return 0
  # shellcheck source=/dev/null  # như trên: đường dẫn chỉ có ở dự án đích
  ( set +u; . "$DECL" >/dev/null 2>&1; eval "printf '%s' \"\${format_file:-}\"" )
}
resolve_format_file() { # $1=path -> in lệnh format 1 file, rỗng nếu không có per-file formatter
  local p="$1" tmpl ext
  tmpl="$(declared_format_file)"
  if [ -n "$tmpl" ]; then printf '%s' "${tmpl//\{\}/$p}"; return 0; fi
  ext="${p##*.}"
  case "$ext" in
    js|jsx|ts|tsx|mjs|cjs|json|css|scss|md|mdx|html|yaml|yml)
      if command -v npx >/dev/null 2>&1 && [ -f "$ROOT/package.json" ]; then
        echo "npx --no-install prettier --write \"$p\""; return 0; fi ;;
    py)
      command -v ruff  >/dev/null 2>&1 && { echo "ruff format \"$p\""; return 0; }
      command -v black >/dev/null 2>&1 && { echo "black \"$p\"";       return 0; } ;;
    go)  command -v gofmt   >/dev/null 2>&1 && { echo "gofmt -w \"$p\""; return 0; } ;;
    rs)  command -v rustfmt >/dev/null 2>&1 && { echo "rustfmt \"$p\"";  return 0; } ;;
  esac
  return 0
}

# --- Điều phối ---------------------------------------------------------------
case "$TASK" in
  format|lint|typecheck|test|build)
    run_task "$TASK"; exit $? ;;
  format-file)
    P="${2:-}"; [ -n "$P" ] || { log "format-file: thiếu path"; exit 0; }
    C="$(resolve_format_file "$P")"
    [ -n "$C" ] || { log "skip format-file: không có per-file formatter cho '$P'"; exit 0; }
    log "format-file: $C"; ( cd "$ROOT" && bash -c "$C" ) || true
    exit 0 ;;
  gate)
    rc=0
    for t in build typecheck lint test; do
      run_task "$t" || { rc=1; log "GATE ĐỎ ở '$t' → dừng"; break; }
    done
    [ "$rc" -eq 0 ] && log "GATE XANH (hoặc no-op)"
    exit "$rc" ;;
  *)
    log "task không hợp lệ: '$TASK' (format|lint|typecheck|test|build|gate)"; exit 2 ;;
esac
