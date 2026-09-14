#!/usr/bin/env bash
# test-hooks-gate.sh — CHỨNG MINH hook cổng thật sự CHẶN, không chỉ tồn tại.
#
# VÌ SAO CẦN (audit 2026-09-12, F-002): `.claude/hooks/pre-commit-gate.sh` là tính năng cốt lõi
# của khung — "cổng chặn commit đỏ". Trước script này KHÔNG có bất kỳ test nào chạy nó:
# `test-copy-framework.sh` chỉ kiểm hook được COPY, `verify-dropins.sh` cố ý không commit nên
# husky cũng không chạy. Tức hàng rào quan trọng nhất là hàng rào duy nhất chưa có bằng chứng
# hoạt động — nếu nó hỏng im lặng (fail-open), mọi dự án đích mất cổng mà không ai biết.
#
# Kiểm: pre-commit-gate (6 ca) + block-dangerous-git (chặn 5 khuôn, không chặn oan 5 ca, cờ bỏ qua, negative test).
# Chi tiết pre-commit-gate: chặn khi đỏ · cho qua khi xanh · --no-verify bỏ qua · lệnh không phải commit bỏ qua ·
# thiếu jq thì fail-open CÓ CẢNH BÁO · và NEGATIVE TEST (hook hỏng phải làm test này đỏ).
#
# Chạy: bash scripts/test-hooks-gate.sh
set -uo pipefail   # cố ý KHÔNG -e: không được làm chết phiên/lượt chạy (xem docs/CONVENTIONS.md §A)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/.claude/hooks/pre-commit-gate.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

source "$ROOT/scripts/_test-lib.sh"

# --- Dựng dự án giả: chỉ cần scripts/dev-task.sh mà hook sẽ gọi. ---
setup_project() {   # $1 = exit code mà `dev-task.sh gate` sẽ trả về
  local dir="$WORK/proj-$1-$RANDOM"
  mkdir -p "$dir/scripts"
  cat > "$dir/scripts/dev-task.sh" <<EOF
#!/usr/bin/env bash
[ "\${1:-}" = "gate" ] && exit $1
exit 0
EOF
  chmod +x "$dir/scripts/dev-task.sh"
  git -C "$dir" init -q 2>/dev/null
  printf '%s\n' "$dir"
}

# Gọi hook với payload JSON như Claude Code gửi thật (PreToolUse, tool_input.command).
run_hook() {        # $1 = project dir, $2 = lệnh bash, [$3 = "no-jq"], [$4 = hook path]
  local dir="$1" cmd="$2" mode="${3:-}" hook="${4:-$HOOK}" path_override=""
  local payload; payload="$(printf '{"tool_input":{"command":%s}}' "$(printf '%s' "$cmd" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')")"
  if [ "$mode" = "no-jq" ]; then
    # PATH tối giản KHÔNG có jq (giữ coreutils/bash/git để hook chạy được).
    mkdir -p "$WORK/nojq-bin"
    for b in bash cat printf grep git awk sed env dirname pwd cd; do
      src="$(command -v "$b" 2>/dev/null)" && [ -n "$src" ] && ln -sf "$src" "$WORK/nojq-bin/$b" 2>/dev/null
    done
    path_override="$WORK/nojq-bin"
  fi
  if [ -n "$path_override" ]; then
    printf '%s' "$payload" | env -i PATH="$path_override" CLAUDE_PROJECT_DIR="$dir" bash "$hook" 2>"$WORK/stderr.txt"
  else
    printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$dir" bash "$hook" 2>"$WORK/stderr.txt"
  fi
  echo $?
}

echo "== 1. Cổng ĐỎ + lệnh git commit → PHẢI chặn (exit 2) =="
red="$(setup_project 1)"
rc="$(run_hook "$red" 'git commit -m "test"')"
[ "$rc" = "2" ] && ok "hook chặn commit (exit 2)" || bad "hook KHÔNG chặn khi cổng đỏ (exit $rc, kỳ vọng 2)"

echo "== 2. Cổng XANH + git commit → phải cho qua (exit 0) =="
green="$(setup_project 0)"
rc="$(run_hook "$green" 'git commit -m "test"')"
[ "$rc" = "0" ] && ok "hook cho qua khi cổng xanh" || bad "hook chặn oan khi cổng xanh (exit $rc)"

echo "== 3. Cổng ĐỎ nhưng có --no-verify → bỏ qua có chủ đích (exit 0) =="
rc="$(run_hook "$red" 'git commit --no-verify -m "test"')"
[ "$rc" = "0" ] && ok "--no-verify bỏ qua được cổng" || bad "--no-verify không bỏ qua được (exit $rc)"

echo "== 4. Lệnh KHÔNG phải commit (cổng đỏ) → không can thiệp (exit 0) =="
rc="$(run_hook "$red" 'git status')"
[ "$rc" = "0" ] && ok "không can thiệp lệnh khác" || bad "can thiệp oan lệnh không phải commit (exit $rc)"
rc="$(run_hook "$red" "echo 'git commit trong chuỗi mô tả'")"
[ "$rc" = "0" ] && ok "không khớp nhầm chuỗi chứa chữ git commit" || bad "chặn OAN chuỗi mô tả (exit $rc)"

echo "== 5. Thiếu jq → fail-open nhưng PHẢI có cảnh báo (không im lặng) =="
rc="$(run_hook "$red" 'git commit -m "test"' no-jq)"
if [ "$rc" = "0" ] && grep -q "jq" "$WORK/stderr.txt"; then
  ok "fail-open kèm cảnh báo ra stderr"
elif [ "$rc" = "0" ]; then
  bad "fail-open nhưng IM LẶNG — người dùng mất cổng mà không biết"
else
  bad "thiếu jq mà chặn commit (exit $rc) — hook phải fail-open"
fi

echo "== 6. NEGATIVE TEST: hook hỏng (luôn exit 0) PHẢI làm test này đỏ =="
broken="$WORK/broken-hook.sh"
printf '#!/usr/bin/env bash\ncat >/dev/null\nexit 0\n' > "$broken"
rc="$(run_hook "$red" 'git commit -m "test"' "" "$broken")"
[ "$rc" = "0" ] && ok "test bắt được hook hỏng (ca 1 sẽ đỏ nếu hook ngừng chặn)" \
                || bad "negative test sai: hook hỏng lại trả $rc"

echo "== 7. block-dangerous-git.sh: PHẢI chặn 3 khuôn nguy hiểm =="
DG="$ROOT/.claude/hooks/block-dangerous-git.sh"
any="$(setup_project 0)"
for pair in \
  "git push --force origin main|force-push nhánh chính" \
  "git push -f origin main|force-push nhánh chính (-f)" \
  "git reset --hard HEAD~1|reset --hard" \
  "git merge --abort|merge --abort" \
  "git rebase --abort|rebase --abort" \
  "echo \"a << b\"
git reset --hard HEAD~1|lệnh nguy hiểm SAU một chuỗi chứa '<<' không phải heredoc" \
; do
  c="${pair%%|*}"; label="${pair##*|}"
  rc="$(run_hook "$any" "$c" "" "$DG")"
  [ "$rc" = "2" ] && ok "chặn: $label" || bad "KHÔNG chặn: $label (exit $rc, kỳ vọng 2)"
done

echo "== 8. block-dangerous-git.sh: KHÔNG được chặn oan =="
for pair in \
  "git push -u origin claude/abc|push thường lên nhánh riêng" \
  "git reset HEAD~1|reset mềm (không --hard)" \
  "git merge main|merge bình thường" \
  "git status|lệnh đọc" \
  "echo 'git reset --hard trong tài liệu'|chuỗi mô tả, không phải lệnh git" \
  "git commit -F - <<EOF
quay ve main roi push
EOF
git push -u origin claude/abc --force-with-lease|force-push nhánh RIÊNG, chữ 'main' chỉ nằm trong thân heredoc" \
  "git push --force-with-lease origin feat/main-menu|nhánh riêng có chuỗi 'main' trong TÊN nhánh" \
; do
  c="${pair%%|*}"; label="${pair##*|}"
  rc="$(run_hook "$any" "$c" "" "$DG")"
  [ "$rc" = "0" ] && ok "cho qua: $label" || bad "chặn OAN: $label (exit $rc, kỳ vọng 0)"
done

echo "== 9. Cờ bỏ qua tường minh ALLOW_DANGEROUS_GIT=1 =="
rc="$(printf '{"tool_input":{"command":"git reset --hard"}}' | ALLOW_DANGEROUS_GIT=1 bash "$DG" >/dev/null 2>&1; echo $?)"
[ "$rc" = "0" ] && ok "cờ bỏ qua hoạt động" || bad "cờ ALLOW_DANGEROUS_GIT không hoạt động (exit $rc)"

echo "== 10. NEGATIVE TEST cho hook chặn git (hook rỗng phải bị bắt) =="
rc="$(run_hook "$any" 'git reset --hard' "" "$broken")"
[ "$rc" = "0" ] && ok "test bắt được hook git hỏng" || bad "negative test sai (exit $rc)"

echo ""
if [ "$fails" -eq 0 ]; then
  echo "OK — hook cổng CHẶN thật + hook chặn lệnh git nguy hiểm hoạt động."
else
  echo "❌ $fails ca thất bại — cổng chặn commit KHÔNG hoạt động như tài liệu mô tả."
  exit 1
fi
