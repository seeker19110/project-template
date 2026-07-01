# .claude/usage-budget.sh — BUDGET token/5h theo GÓI của bạn (tự hiệu chỉnh)
#
# Copy file này thành `.claude/usage-budget.sh` rồi điền số. Có file này thì
# tính năng ước tính % quota 5h + nhắc wind-down (Stop hook) mới bật.
# KHÔNG có file → OVERALL=NA → tính năng tự tắt (không báo động sai).
#
# VÌ SAO PHẢI TỰ ĐIỀN: Anthropic không công bố hạn mức token/5h của từng model
# dạng số máy đọc được, và nó phụ thuộc GÓI (Pro / Max 5x / Max 20x). Đây là MẪU SỐ
# ước tính — bạn tự hiệu chỉnh từ kinh nghiệm (vd auto mode ~1h là chạm trần → hạ số
# xuống cho tới khi % chạm ~100% đúng lúc bạn thực sự bị giới hạn).
#
# Đơn vị: TỔNG token trong cửa sổ 5h (input + output + cache_creation + 0.1*cache_read).
# Chỉ cần điền model bạn thực sự dùng; để 0 = bỏ qua model đó.

# --- Ví dụ khởi điểm (SỬA theo gói & thực tế của bạn) ---
BUDGET_OPUS=0
BUDGET_SONNET=0
BUDGET_HAIKU=0
BUDGET_FABLE=0

# Trọng số token cache-read so với token thường (cache rẻ hơn) — 0.0..1.0
CACHE_READ_WEIGHT=0.1

# Ngưỡng % để nhắc wind-down (mặc định 70)
WINDDOWN_THRESHOLD=70
