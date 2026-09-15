#!/usr/bin/env bash
# test-telemetry-and-dispatch.sh — Tự kiểm tra Universal Subagent Dispatch & Telemetry Engine.

set -uo pipefail   # cố ý KHÔNG -e: script test gom kết quả nhiều ca; -e sẽ dừng ở ca đỏ ĐẦU TIÊN và giấu các ca còn lại (xem docs/CONVENTIONS.md §A)

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

# --- Đa model/đa nhà cung cấp (2026-09-15): --tier tra ứng viên theo cấp năng lực,
# không gắn cứng vào Claude — xem docs/framework/orchestration-3-tier.md.
out_tier="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier standard 2>&1)"
if echo "$out_tier" | grep -q "harness=claude" && echo "$out_tier" | grep -qi "google\|hermes\|opencode"; then
  ok "subagent-dispatch --tier standard liệt kê ứng viên đa nhà cung cấp"
else
  bad "subagent-dispatch --tier standard không liệt kê được ứng viên đa nhà cung cấp"
fi

if bash "$ROOT/scripts/subagent-dispatch.sh" --tier khong-ton-tai >/dev/null 2>&1; then
  bad "subagent-dispatch --tier chấp nhận giá trị không hợp lệ (choices= chưa chặn)"
else
  ok "subagent-dispatch --tier chặn giá trị không hợp lệ"
fi

# --- F-207: dữ liệu hỏng phải báo ĐÚNG CHỖ, không đổ lỗi cho tham số người dùng -------------
# Đường dẫn này là thứ AI TỰ CHẠY (ADR-0006) — không có người đọc lỗi tại chỗ. Một thông điệp đổ
# lỗi sai chỗ hoặc một traceback trần giữa phiên tự động tốn hẳn một vòng chẩn đoán.
# Khuôn đúng đã có sẵn ở telemetry-log.py:load_rates() — "thiếu file/hỏng JSON → dừng hẳn" với
# thông điệp nêu đúng nguyên nhân. File chị em này chưa theo.
TIERS_FILE="$ROOT/scripts/model-capability-tiers.json"
BACKUP="$(mktemp)"; cp "$TIERS_FILE" "$BACKUP"
restore_tiers() { cp "$BACKUP" "$TIERS_FILE"; }
trap restore_tiers EXIT

# (a) File KHÔNG tồn tại → thông điệp phải nói THIẾU FILE, không phải "tier không có trong ...".
mv "$TIERS_FILE" "$TIERS_FILE.hidden"
out_missing="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier standard 2>&1)"; rc_missing=$?
mv "$TIERS_FILE.hidden" "$TIERS_FILE"
[ "$rc_missing" != "0" ] && ok "thiếu file bảng cấp: thoát khác 0" || bad "thiếu file bảng cấp vẫn thoát 0"
echo "$out_missing" | grep -qiE 'không đọc được|không tìm thấy|thiếu' \
  && ok "thiếu file bảng cấp: thông điệp nói ĐÚNG nguyên nhân (thiếu file)" \
  || bad "thiếu file bảng cấp: thông điệp đổ lỗi sai chỗ — '$out_missing'"

# (b) JSON hỏng cú pháp → phải nói hỏng JSON, không phải traceback trần.
printf '{ hong json' > "$TIERS_FILE"
out_broken="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier standard 2>&1)"; rc_broken=$?
restore_tiers
[ "$rc_broken" != "0" ] && ok "JSON hỏng: thoát khác 0" || bad "JSON hỏng vẫn thoát 0"
echo "$out_broken" | grep -q 'Traceback' \
  && bad "JSON hỏng: traceback Python trần — không phải thông điệp cố ý" \
  || ok "JSON hỏng: KHÔNG có traceback trần"

# (c) Đổi CẤU TRÚC (mất khoá gốc 'tiers') → phải nói SAI CẤU TRÚC, khác hẳn ca (a).
printf '{"levels": {}}' > "$TIERS_FILE"
out_struct="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier standard 2>&1)"; rc_struct=$?
restore_tiers
[ "$rc_struct" != "0" ] && ok "sai cấu trúc: thoát khác 0" || bad "sai cấu trúc vẫn thoát 0"
# Không grep chữ "tiers" trần: chuỗi đó có sẵn trong TÊN FILE (model-capability-tiers.json) nên ca
# này từng xanh GIẢ. Đòi một cụm chỉ xuất hiện khi code thật sự phân biệt được "sai cấu trúc".
echo "$out_struct" | grep -qiE "thiếu khoá|khoá gốc" \
  && ok "sai cấu trúc: thông điệp nêu đúng khoá gốc bị thiếu" \
  || bad "sai cấu trúc: không nêu khoá thiếu — '$out_struct'"

# (d) Ứng viên thiếu trường bắt buộc → không được ném KeyError trần.
python3 - "$TIERS_FILE" <<'PYX'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["tiers"]["standard"]["candidates"][0].pop("model_hint", None)
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
PYX
out_key="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier standard 2>&1)"; rc_key=$?
restore_tiers
echo "$out_key" | grep -q 'Traceback' \
  && bad "ứng viên thiếu trường: KeyError traceback trần (rc=$rc_key)" \
  || ok "ứng viên thiếu trường: KHÔNG có traceback trần"

# (e) Danh sách tier phải SINH TỪ JSON, không hard-code: thêm tier vào file thì dùng được ngay.
python3 - "$TIERS_FILE" <<'PYX'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["tiers"]["tier-moi-cho-test"] = {"desc": "tier thêm lúc chạy", "candidates": []}
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
PYX
out_new="$(bash "$ROOT/scripts/subagent-dispatch.sh" --tier tier-moi-cho-test 2>&1)"; rc_new=$?
restore_tiers
[ "$rc_new" = "0" ] && ok "tier thêm vào JSON dùng được ngay (choices sinh từ dữ liệu)" \
                    || bad "tier thêm vào JSON bị argparse chặn — choices đang hard-code, JSON chưa từng được đọc"

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
