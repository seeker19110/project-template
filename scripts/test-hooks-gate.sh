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
skips=0
skip() { echo "  ⏭  BỎ QUA (thiếu jq): $1"; skips=$((skips+1)); }

# Hook đọc lệnh từ payload JSON bằng jq. Thiếu jq → hook fail-open theo thiết kế, nên mọi ca
# "phải chặn" lẫn "không chặn oan" đều cho exit 0 — xanh giả hoặc đỏ sai bản chất. Báo BỎ QUA
# trung thực thay vì kết luận "cổng không hoạt động" (CLAUDE.md §7). CI có jq nên vẫn chứng minh đủ.
HAS_JQ=0; command -v jq >/dev/null 2>&1 && HAS_JQ=1
if [ "$HAS_JQ" = "0" ]; then
  echo "⚠️  Máy này KHÔNG có jq → hook fail-open; chỉ kiểm được ca fail-open (mục 5)."
  echo "   Cài jq để chạy đủ bộ (xem README → Yêu cầu môi trường)."
  echo ""
fi

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
      src="$(command -v "$b" 2>/dev/null)" && [ -n "$src" ] &&         { ln -sf "$src" "$WORK/nojq-bin/$b" 2>/dev/null || cp "$src" "$WORK/nojq-bin/$b" 2>/dev/null; }
    done
    # PATH giả phải thật sự chạy được: trên Windows/MSYS `ln -s` có thể không tạo được binary
    # dùng được, hook sẽ chết với exit 127 và test báo "chặn oan" — sai bản chất.
    # Dự phòng: giữ nguyên PATH thật, chỉ bỏ các thư mục có chứa jq.
    if env -i PATH="$WORK/nojq-bin" bash -c 'true' 2>/dev/null; then
      path_override="$WORK/nojq-bin"
    else
      local d filtered=""
      while IFS= read -r d; do
        [ -n "$d" ] || continue
        [ -x "$d/jq" ] || [ -x "$d/jq.exe" ] && continue
        filtered="${filtered:+$filtered:}$d"
      done <<< "$(printf '%s' "$PATH" | tr ':' '
')"
      path_override="$filtered"
    fi
  fi
  if [ -n "$path_override" ]; then
    printf '%s' "$payload" | env -i PATH="$path_override" CLAUDE_PROJECT_DIR="$dir" bash "$hook" 2>"$WORK/stderr.txt"
  else
    printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$dir" bash "$hook" 2>"$WORK/stderr.txt"
  fi
  echo $?
}

red="$(setup_project 1)"
green="$(setup_project 0)"

echo "== 1. Cổng ĐỎ + lệnh git commit → PHẢI chặn (exit 2) =="
if [ "$HAS_JQ" = "0" ]; then skip "hook không đọc được lệnh nên không thể chứng minh việc chặn"; else
rc="$(run_hook "$red" 'git commit -m "test"')"
[ "$rc" = "2" ] && ok "hook chặn commit (exit 2)" || bad "hook KHÔNG chặn khi cổng đỏ (exit $rc, kỳ vọng 2)"

echo "== 2. Cổng XANH + git commit → phải cho qua (exit 0) =="
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

fi

# Máy đã thiếu jq sẵn thì không cần dựng PATH giả — điều kiện cần kiểm đã đúng sẵn.
echo "== 5. Thiếu jq → fail-open nhưng PHẢI có cảnh báo (không im lặng) =="
mode5="no-jq"; [ "$HAS_JQ" = "1" ] || mode5=""
rc="$(run_hook "$red" 'git commit -m "test"' "$mode5")"
if [ "$rc" = "0" ] && grep -q "jq" "$WORK/stderr.txt"; then
  ok "fail-open kèm cảnh báo ra stderr"
elif [ "$rc" = "0" ]; then
  bad "fail-open nhưng IM LẶNG — người dùng mất cổng mà không biết"
else
  bad "thiếu jq mà chặn commit (exit $rc) — hook phải fail-open"
fi

echo "== 6. NEGATIVE TEST: hook hỏng (luôn exit 0) PHẢI làm test này đỏ =="
if [ "$HAS_JQ" = "0" ]; then skip "mục 6–10 — vô nghĩa khi mục 1/7 không chạy được"; else
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
  "$(printf 'cat <<-EOF\nnoi dung\n\tEOF\ngit reset --hard HEAD~1')|lệnh nguy hiểm SAU heredoc <<- đóng bằng dòng có TAB đầu" \
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
  "$(printf 'git commit -F - <<-EOF\n\tquay ve main roi push\n\tEOF\ngit push -u origin claude/abc --force-with-lease')|heredoc <<- (thân thụt TAB): chữ 'main' chỉ nằm trong thân, KHÔNG được chặn oan" \
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

fi

echo ""

# ==============================================================================
# 10b–13. BỐN HOOK TRƯỚC ĐÂY KHÔNG CÓ TEST NÀO (audit F-401)
# ==============================================================================
# auto-format.sh, session-guide.sh, session-resume.sh, usage-guard.sh đều có nhánh điều kiện thật
# (ADR-0005 bắt buộc test), nhưng `grep -ln <tên hook> scripts/test-*.sh` trước đây ra NONE cho cả
# bốn. Sửa sai một ngưỡng/marker → hành vi hỏng, không cổng nào đỏ, và copy-framework.sh vẫn phát
# hook hỏng đó sang MỌI dự án đích.

# Dựng một "dự án khung" giả đủ để các hook nhận ra và chạy.
mk_fw_project() {  # $1 = nội dung dòng "Giai đoạn hiện tại" (rỗng = không có PROGRESS.md)
  local dir="$WORK/fw-$RANDOM"
  mkdir -p "$dir/docs/framework" "$dir/.claude/commands" "$dir/scripts"
  if [ -n "${1:-}" ]; then
    printf '# PROGRESS\n\n## Giai đoạn hiện tại\n\n- %s\n' "$1" > "$dir/PROGRESS.md"
  fi
  printf '%s\n' "$dir"
}

echo "== 10b. auto-format.sh =="
AF="$ROOT/.claude/hooks/auto-format.sh"
if [ "$HAS_JQ" = "1" ]; then
  fw="$(mk_fw_project 'GĐ 4')"
  # (a) Có dev-task.sh thực thi được → hook gọi nó và luôn exit 0.
  printf '#!/usr/bin/env bash\necho "[dev-task] format-file $*"\n' > "$fw/scripts/dev-task.sh"
  chmod +x "$fw/scripts/dev-task.sh"
  out="$(printf '{"tool_input":{"file_path":"a.md"}}' | CLAUDE_PROJECT_DIR="$fw" bash "$AF" 2>&1)"; rc=$?
  [ "$rc" = "0" ] && ok "có dev-task.sh: exit 0 (không cản luồng)" \
                  || bad "có dev-task.sh: exit $rc (phải luôn 0)"
  # (b) THIẾU dev-task.sh → fail-open nhưng PHẢI NÓI RA (luật: bỏ qua thì phải nói).
  fw2="$(mk_fw_project 'GĐ 4')"
  out="$(printf '{"tool_input":{"file_path":"a.md"}}' | CLAUDE_PROJECT_DIR="$fw2" bash "$AF" 2>&1)"; rc=$?
  [ "$rc" = "0" ] && ok "thiếu dev-task.sh: exit 0" || bad "thiếu dev-task.sh: exit $rc"
  printf '%s' "$out" | grep -q 'auto-format' \
    && ok "thiếu dev-task.sh: CÓ cảnh báo ra stderr (không no-op im lặng)" \
    || bad "thiếu dev-task.sh: im lặng — người dùng tưởng auto-format đang chạy"
  # (c) Payload không có file_path → no-op, exit 0.
  printf '{"tool_input":{}}' | CLAUDE_PROJECT_DIR="$fw2" bash "$AF" >/dev/null 2>&1
  [ $? = "0" ] && ok "không có file_path: no-op exit 0" || bad "không có file_path: exit khác 0"
else
  skip "auto-format.sh (cần jq)"
fi

echo "== 11. session-guide.sh: hai nhánh thông điệp theo trạng thái =="
SG="$ROOT/.claude/hooks/session-guide.sh"
if [ "$HAS_JQ" = "1" ]; then
  # (a) KHÔNG phải dự án khung → phải no-op im lặng (không quấy dự án lạ).
  plain="$WORK/plain-$RANDOM"; mkdir -p "$plain"
  out="$(printf '{}' | CLAUDE_PROJECT_DIR="$plain" bash "$SG" 2>/dev/null)"
  [ -z "$out" ] && ok "dự án KHÔNG dùng khung: no-op im lặng" \
                || bad "dự án không dùng khung vẫn in thông điệp (quấy dự án lạ)"
  # (b) Dự án khung, CHƯA có tiến độ → gợi ý bắt đầu.
  fwA="$(mk_fw_project '')"
  outA="$(printf '{}' | CLAUDE_PROJECT_DIR="$fwA" bash "$SG" 2>/dev/null)"
  [ -n "$outA" ] && ok "chưa có tiến độ: CÓ sinh thông điệp" || bad "chưa có tiến độ: không sinh gì"
  # (c) Dự án khung, ĐANG làm dở → thông điệp phải KHÁC nhánh (b).
  fwB="$(mk_fw_project 'GĐ 4. Đang làm tính năng X')"
  outB="$(printf '{}' | CLAUDE_PROJECT_DIR="$fwB" bash "$SG" 2>/dev/null)"
  [ -n "$outB" ] && ok "đang làm dở: CÓ sinh thông điệp" || bad "đang làm dở: không sinh gì"
  [ "$outA" != "$outB" ] && ok "hai trạng thái cho thông điệp KHÁC nhau (nhánh thật sự rẽ)" \
                         || bad "hai trạng thái cho CÙNG thông điệp — nhánh theo phase không hoạt động"
  # (d) Output phải là JSON hợp lệ (Claude Code parse nó).
  printf '%s' "$outB" | jq empty 2>/dev/null \
    && ok "output là JSON hợp lệ" || bad "output KHÔNG phải JSON hợp lệ — harness sẽ bỏ qua"
else
  skip "session-guide.sh (cần jq)"
fi

echo "== 12. session-resume.sh: nạp ngữ cảnh + xoá marker wind-down =="
SR="$ROOT/.claude/hooks/session-resume.sh"
if [ "$HAS_JQ" = "1" ]; then
  fwC="$(mk_fw_project 'GĐ 7. Mốc gần nhất: abc')"
  mkdir -p "$fwC/.claude"; touch "$fwC/.claude/.winddown-nudged"
  out="$(printf '{}' | CLAUDE_PROJECT_DIR="$fwC" bash "$SR" 2>/dev/null)"
  [ ! -f "$fwC/.claude/.winddown-nudged" ] \
    && ok "xoá marker .winddown-nudged (phiên mới được nhắc lại)" \
    || bad "KHÔNG xoá marker — usage-guard sẽ im lặng mãi ở mọi phiên sau"
  printf '%s' "$out" | grep -q 'GĐ 7' \
    && ok "nạp nội dung PROGRESS.md vào ngữ cảnh" || bad "không nạp được PROGRESS.md"
  printf '%s' "$out" | jq empty 2>/dev/null \
    && ok "output là JSON hợp lệ" || bad "output KHÔNG phải JSON hợp lệ"
  # Không có PROGRESS.md → vẫn không được chết.
  fwD="$(mk_fw_project '')"
  printf '{}' | CLAUDE_PROJECT_DIR="$fwD" bash "$SR" >/dev/null 2>&1
  [ $? = "0" ] && ok "không có PROGRESS.md: exit 0" || bad "không có PROGRESS.md: exit khác 0"
else
  skip "session-resume.sh (cần jq)"
fi

echo "== 13. usage-guard.sh: ngưỡng + nhắc MỘT lần/phiên =="
UG="$ROOT/.claude/hooks/usage-guard.sh"
if [ "$HAS_JQ" = "1" ]; then
  # Stub usage-estimate.sh trả OVERALL cố định → kiểm nhánh ngưỡng mà không cần transcript thật.
  mk_ug() {  # $1 = OVERALL, $2 = THRESHOLD
    local dir="$WORK/ug-$RANDOM"; mkdir -p "$dir/scripts" "$dir/.claude"
    printf '#!/usr/bin/env bash\necho "OVERALL=%s"\necho "THRESHOLD=%s"\necho "opus=10"\n' "$1" "$2" \
      > "$dir/scripts/usage-estimate.sh"
    chmod +x "$dir/scripts/usage-estimate.sh"
    printf 'x\n' > "$dir/transcript.jsonl"
    printf '%s\n' "$dir"
  }
  pay() { printf '{"transcript_path":"%s/transcript.jsonl"}' "$1"; }

  # (a) DƯỚI ngưỡng → im lặng.
  d1="$(mk_ug 10 70)"
  out="$(pay "$d1" | CLAUDE_PROJECT_DIR="$d1" bash "$UG" 2>/dev/null)"
  [ -z "$out" ] && ok "dưới ngưỡng (10 < 70): im lặng" || bad "dưới ngưỡng vẫn nhắc — sẽ nhắc mỗi lượt"
  [ ! -f "$d1/.claude/.winddown-nudged" ] && ok "dưới ngưỡng: KHÔNG tạo marker" \
                                          || bad "dưới ngưỡng vẫn tạo marker — nhắc thật sau này bị nuốt"
  # (b) TRÊN ngưỡng → nhắc, và tạo marker.
  d2="$(mk_ug 85 70)"
  out="$(pay "$d2" | CLAUDE_PROJECT_DIR="$d2" bash "$UG" 2>/dev/null)"
  [ -n "$out" ] && ok "trên ngưỡng (85 >= 70): CÓ nhắc" || bad "trên ngưỡng nhưng KHÔNG nhắc"
  [ -f "$d2/.claude/.winddown-nudged" ] && ok "trên ngưỡng: tạo marker" || bad "không tạo marker"
  # (c) Lần hai trong CÙNG phiên → im lặng (marker còn đó).
  out2="$(pay "$d2" | CLAUDE_PROJECT_DIR="$d2" bash "$UG" 2>/dev/null)"
  [ -z "$out2" ] && ok "lần hai cùng phiên: im lặng (nhắc đúng MỘT lần)" \
                 || bad "nhắc lặp lại mỗi lượt — đúng thứ marker sinh ra để chặn"
  # (d) OVERALL=NA (chưa khai budget) → tự tắt.
  d3="$(mk_ug NA 70)"
  out="$(pay "$d3" | CLAUDE_PROJECT_DIR="$d3" bash "$UG" 2>/dev/null)"
  [ -z "$out" ] && ok "OVERALL=NA: tự tắt" || bad "OVERALL=NA vẫn nhắc"
  # (e) Ngưỡng tuỳ biến: 85 >= 90 là SAI → phải im lặng.
  d4="$(mk_ug 85 90)"
  out="$(pay "$d4" | CLAUDE_PROJECT_DIR="$d4" bash "$UG" 2>/dev/null)"
  [ -z "$out" ] && ok "tôn trọng THRESHOLD tuỳ biến (85 < 90 → im lặng)" \
                || bad "bỏ qua THRESHOLD — dùng số cứng"

  # (f) NEGATIVE TEST: hook hỏng (luôn im lặng) PHẢI làm ca (b) đỏ.
  broken="$WORK/ug-broken.sh"; printf '#!/usr/bin/env bash\nexit 0\n' > "$broken"; chmod +x "$broken"
  d5="$(mk_ug 85 70)"
  out="$(pay "$d5" | CLAUDE_PROJECT_DIR="$d5" bash "$broken" 2>/dev/null)"
  [ -z "$out" ] && ok "negative test: hook hỏng thì ca 'trên ngưỡng phải nhắc' sẽ đỏ" \
                || bad "negative test sai: hook hỏng vẫn sinh output"
else
  skip "usage-guard.sh (cần jq)"
fi


echo "== 14. pre-commit-gate.sh: heredoc nhắc 'git commit' là DỮ LIỆU, không phải lệnh (F-304) =="
# Bản vá bỏ-thân-heredoc trước đây CHỈ áp cho hook anh em block-dangerous-git.sh. pre-commit-gate.sh
# chỉ bỏ phần trong nháy, nên một lệnh `cat` viết tài liệu/fixture có heredoc nhắc `git commit` bị
# hiểu là commit thật → chạy TOÀN BỘ dev-task.sh gate cho một lệnh cat; ở dự án đích đang đỏ thì
# hook exit 2 và CHẶN OAN một lệnh không liên quan.
# Chặn oan nguy hiểm vì nó dạy người dùng gõ --no-verify thành phản xạ → mất luôn cổng thật.
if [ "$HAS_JQ" = "1" ]; then
  red_proj="$(setup_project 1)"   # dev-task.sh gate LUÔN ĐỎ → nếu hook coi là commit thật thì exit 2
  heredoc_data="$(printf 'cat > huong-dan.md <<EOF\nBuoc 3: chay git commit -m "xong"\nEOF')"
  rc="$(run_hook "$red_proj" "$heredoc_data" "" "$HOOK")"
  [ "$rc" = "0" ] && ok "heredoc nhắc 'git commit' làm dữ liệu: KHÔNG chặn oan (exit 0)" \
                  || bad "CHẶN OAN lệnh cat có heredoc (exit $rc) — dạy người dùng gõ --no-verify phản xạ"

  # Đối chứng: commit THẬT đứng sau một heredoc vẫn phải bị chặn khi cổng đỏ.
  real_after="$(printf 'cat > a.md <<EOF\nnoi dung\nEOF\ngit commit -m "that"')"
  rc="$(run_hook "$red_proj" "$real_after" "" "$HOOK")"
  [ "$rc" = "2" ] && ok "commit THẬT đứng sau heredoc: vẫn chặn (exit 2)" \
                  || bad "để LỌT commit thật sau heredoc (exit $rc) — vá quá tay theo chiều nguy hiểm"

  # Đối chứng: heredoc `<<-` thụt TAB cũng phải xử lý đúng (cùng khuôn TRAPS 30).
  dash_data="$(printf 'cat > b.md <<-EOF\n\tBuoc: git commit -m x\n\tEOF')"
  rc="$(run_hook "$red_proj" "$dash_data" "" "$HOOK")"
  [ "$rc" = "0" ] && ok "heredoc <<- thụt TAB: KHÔNG chặn oan" \
                  || bad "chặn oan heredoc <<- (exit $rc)"
else
  skip "pre-commit-gate heredoc (cần jq)"
fi

if [ "$fails" -eq 0 ] && [ "$skips" -gt 0 ]; then
  echo "⚠️  $skips nhóm ca BỊ BỎ QUA vì máy thiếu jq — chưa chứng minh được cổng chặn."
  echo "OK (không có ca nào ĐỎ) — cài jq rồi chạy lại để có bằng chứng đầy đủ."
elif [ "$fails" -eq 0 ]; then
  echo "OK — hook cổng CHẶN thật + hook chặn lệnh git nguy hiểm hoạt động."
else
  echo "❌ $fails ca thất bại — cổng chặn commit KHÔNG hoạt động như tài liệu mô tả."
  exit 1
fi
