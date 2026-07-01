# Cấu hình Opusplan dùng chung cho mọi dự án (Shared Config)

> **Mục đích:** Cung cấp cấu hình Claude Code tiêu chuẩn sử dụng **Opusplan** cho bất kỳ dự án nào khi áp dụng bộ khung CLAUDE.md.
> **Khi nào dùng:** Khi tích hợp khung vào dự án mới hoặc dự án có sẵn, muốn sử dụng **Opusplan** để chạy tự động với subagent Haiku tối ưu chi phí.

---

## 0. TL;DR — Dùng ngay

Khi áp dụng khung vào dự án của bạn bằng `copy-framework.sh` hoặc `copy-framework.ps1`:

```bash
# Từ repo khung, chạy:
bash copy-framework.sh /đường-dẫn/tới/dự-án-của-bạn
```

Script sẽ copy cấu hình Opusplan vào `_framework-dropins/.claude/settings-shared-opusplan.json`. Sau đó:

1. **Nếu dự án của bạn chưa có `.claude/settings.json`:**
   ```bash
   cp _framework-dropins/.claude/settings-shared-opusplan.json .claude/settings.json
   ```

2. **Nếu dự án của bạn đã có `.claude/settings.json`:**
   - Mở file `.claude/settings.json` hiện tại
   - Thay `"model": "..."` thành `"model": "opusplan"`
   - Thay `"fallbackModel": [...]` thành `"fallbackModel": ["claude-sonnet-5", "claude-haiku-4-5"]`
   - Copy phần `"hooks"` từ `_framework-dropins/.claude/settings-shared-opusplan.json` nếu cần

---

## 1. File cấu hình tiêu chuẩn là gì?

**`.claude/settings-shared-opusplan.json`** — file cấu hình Claude Code mặc định cho mọi dự án áp khung:

### Model (vai trò chính)
- **`"model": "opusplan"`** — Chạy toàn bộ khung CLAUDE.md ở chế độ Opusplan:
  - Opus 4.8 làm lập kế hoạch (quyết định kiến trúc, research-first, tư vấn)
  - Sonnet 5 làm code (nhanh, đủ tốt cho mọi task)
  - Subagent Haiku 4.5 làm việc phụ (tìm kiếm, kiểm tra file, tối ưu chi phí)
  - ✅ **Chi phí**: gấp ~2 lần Sonnet 5 thuần, nhưng chất lượng cao hơn nhiều
  - ✅ **Thích hợp**: dự án tầm trung→lớn (10k+ LOC), kiến trúc phức tạp, rủi ro cao

### Fallback model
- **`"fallbackModel": ["claude-sonnet-5", "claude-haiku-4-5"]`** — Nếu Opusplan không khả dụng:
  1. Thử Sonnet 5 trước (vẫn tốt, rẻ hơn)
  2. Thử Haiku 4.5 nếu cần (rẻ nhất, cho việc đơn giản)

### Permissions (quyền hạn)
Cho phép các công cụ cần thiết:
- **Read/Edit/Write:** chỉnh sửa file
- **Bash git:** quản lý git (add, commit, push, fetch)
- **Bash build/test:** chạy lệnh dev của dự án (npm/pnpm/yarn/pytest/go/cargo/…)
- **Deny:** chặn các thao tác nguy hiểm (rm -rf, force push, sudo, xem .env)

### Hooks (tự động chạy)
- **SessionStart:** Kiểm tra nạp file PROGRESS.md, hướng dẫn phiên
- **PreToolUse (Bash):** Cổng pre-commit trước mỗi thao tác Bash (chặn công việc bẩn)
- **PostToolUse (Edit/Write):** Auto-format file vừa sửa
- **Stop:** Guard sử dụng (cảnh báo nếu dùng quá nhiều token)

---

## 2. Khi nào dùng Opusplan?

| Tiêu chí | Dùng Opusplan? | Lý do |
|---|---|---|
| **Dự án nhỏ** (script, landing, prototype, <5k LOC) | ❌ Dùng Sonnet 5 thay | Chi phí không đáng, Sonnet 5 đủ |
| **Dự án tầm trung** (web+API, 10–50k LOC) | ✅ **CÓ** | Cân bằng chi phí/chất lượng tốt |
| **Dự án lớn/phức tạp** (nhiều dịch vụ, realtime, >50k LOC) | ✅ **CÓ** | Rủi ro cao, cần Opus lập kế hoạch |
| **Yêu cầu mơ hồ, nhiều đánh đổi** | ✅ **CÓ** | Opus tốt hơn lúc trade-off |
| **Kiến trúc nhạy cảm, breaking change** | ✅ **CÓ** | Opus bắt được vấn đề Sonnet hỏng |

**Nguyên tắc vàng:** Dùng **Sonnet 5 nếu chắc chắn đủ**; **Opusplan ở dự án rủi ro cao**.

---

## 3. Cách chọn model cho dự án của bạn

### Tùy chọn A — Dùng ngay Opusplan (khuyến nghị cho dự án có sẵn)
File `.claude/settings-shared-opusplan.json` đã cấu hình sẵn Opusplan. Dùng nó ngay!

### Tùy chọn B — Dùng Sonnet 5 (tiết kiệm chi phí)
Nếu dự án nhỏ hoặc bạn muốn tiết kiệm chi phí, sửa file `.claude/settings.json`:
```json
{
  "model": "claude-sonnet-5",
  "fallbackModel": ["claude-haiku-4-5"]
}
```

### Tùy chọn C — Hybrid (Sonnet 5 mặc định, Opus ở task khó)
Dùng Sonnet 5 cho công việc thường ngày, Opus cho quyết định kiến trúc:
1. Cấu hình `.claude/settings.json` dùng **`"model": "claude-sonnet-5"`**
2. Khi cần Opus (KHUNG-3 trade-off, `/adr`, `/su-co`), chạy:
   ```bash
   /model claude-opus-4-8
   ```
   hoặc yêu cầu "Hãy dùng Opus cho việc này"

---

## 4. Áp dụng cấu hình cho dự án của bạn

### 4a. Dự án MỚI (vừa tạo)

1. Clone repo khung (hoặc đã ở trong repo khung):
   ```bash
   cd /đường-dẫn/tới/repo-khung
   ```

2. Copy khung sang dự án của bạn:
   ```bash
   bash copy-framework.sh /đường-dẫn/tới/dự-án-mới
   ```

3. Vào dự án, copy cấu hình Opusplan:
   ```bash
   cd /đường-dẫn/tới/dự-án-mới
   mkdir -p .claude
   cp _framework-dropins/.claude/settings-shared-opusplan.json .claude/settings.json
   ```

4. Mở phiên Claude Code → AI tự nạp cấu hình Opusplan và chạy khung 🎉

### 4b. Dự án CÓ SẴN (brownfield)

1. Copy khung vào dự án:
   ```bash
   cd /đường-dẫn/tới/repo-khung
   bash copy-framework.sh /đường-dẫn/tới/dự-án-cũ
   ```

2. **Nếu dự án chưa có `.claude/settings.json`:**
   ```bash
   cd /đường-dẫn/tới/dự-án-cũ
   mkdir -p .claude
   cp _framework-dropins/.claude/settings-shared-opusplan.json .claude/settings.json
   ```

3. **Nếu dự án đã có `.claude/settings.json` (cấu hình cũ):**
   - Đọc file hiện tại
   - Mở `_framework-dropins/.claude/settings-shared-opusplan.json` để so sánh
   - **Chọn một trong:**
     - **A)** Thay toàn bộ: `cp _framework-dropins/.claude/settings-shared-opusplan.json .claude/settings.json`
     - **B)** Merge từng phần: giữ permissions/hooks cũ, chỉ thay model → Opusplan
   - Ghi commit riêng: "chore(.claude): apply Opusplan config"

4. Xóa `_framework-dropins/` khi không cần (hoặc giữ lại để so sánh):
   ```bash
   rm -rf _framework-dropins/
   ```

5. Mở phiên Claude Code → AI tự nạp cấu hình Opusplan và tiếp tục phát triển 🎉

---

## 5. Tuỳ chỉnh cấu hình cho dự án đặc thù

### Thêm permission tùy chỉnh
Nếu dự án dùng công cụ khác (vd `make`, `docker`, `kubectl`):

```json
{
  "permissions": {
    "allow": [
      ...cũ...,
      "Bash(make *)",
      "Bash(docker *)",
      "Bash(kubectl *)"
    ]
  }
}
```

### Loại bỏ hook không cần
Nếu không dùng pre-commit gate (vd dự án backend không cần auto-format):

```json
{
  "hooks": {
    "SessionStart": [...],
    "Stop": [...]
    // Bỏ "PreToolUse" và "PostToolUse" nếu không cần
  }
}
```

### Thêm hook mới (tuỳ chọn)
Xem `CLAUDE.md` mục "update-config" để thêm hook tùy chỉnh (vd chạy vitest tự động).

---

## 6. Kiểm tra cấu hình đã áp đúng

Khi mở phiên Claude Code lần đầu:

✅ **Kiểm tra:**
1. Dòng trạng thái Claude Code hiển thị **"Opusplan"** (không phải Sonnet/Haiku)
2. Phiên khởi động gọi hook `session-resume.sh` (xem PROGRESS.md)
3. Có thông báo "chế độ chạy tự động" với Opus/Sonnet/Haiku (từ hook `session-guide.sh`)
4. Mỗi lần Edit/Write, file tự format (hook `auto-format.sh`)

❌ **Nếu không thấy:**
- Kiểm tra file `.claude/settings.json` có tồn tại không: `ls -la .claude/settings.json`
- Kiểm tra model được cấu hình: `grep '"model"' .claude/settings.json`
- Đóng/mở phiên Claude Code lại (reload cấu hình)
- Nếu vẫn sai, kiểm tra `.claude/hooks/` có tồn tại không

---

## 7. Q&A

### Q: Tôi muốn dùng Sonnet 5 thay vì Opusplan, phải làm gì?
**A:** Sửa `.claude/settings.json`:
```bash
jq '.model = "claude-sonnet-5"' .claude/settings.json > /tmp/settings.json && mv /tmp/settings.json .claude/settings.json
```
Hoặc mở file và thay `"opusplan"` → `"claude-sonnet-5"`.

### Q: Tôi có thể tạo nhiều file cấu hình cho nhiều dự án khác nhau không?
**A:** Có! Tạo các file:
- `.claude/settings-sonnet.json` — cho dự án nhỏ
- `.claude/settings-opus.json` — cho dự án lớn
- `.claude/settings.json` — file hiện tại (cái mà Claude Code nạp)

Sau đó copy cái cần: `cp .claude/settings-sonnet.json .claude/settings.json`

### Q: File này có tương thích với mọi loại dự án không?
**A:** **Có, nhưng...** 
- ✅ Permissions tổng quát cho Node/Python/Go/Rust/Makefile
- ✅ Hooks không phụ thuộc stack
- ⚠️ Một vài hook (vd `auto-format`) cần `scripts/dev-task.sh` — nếu dự án không có, hook sẽ no-op (không lỗi)
- Nếu dự án dùng công cụ độc lạ, thêm permissions tùy chỉnh (xem mục 5)

### Q: Opusplan có hỗ trợ các dự án mobile, desktop, backend không?
**A:** **Có!** Opusplan là cấu hình **Claude Code chạy khung CLAUDE.md**, không giới hạn loại dự án.
- ✅ Web (Next, Remix, Svelte, Astro, Vue)
- ✅ Mobile (React Native, Flutter — qua CLI/backend)
- ✅ Backend (Python FastAPI, Node Express, Go, Rust)
- ✅ Desktop (Electron, Tauri)
- ✅ CLI / SDK / Library
- ✅ Data / ML / AI
- Nó áp dụng **quy trình CLAUDE.md** (9 giai đoạn, cổng, research-first) cho bất kỳ stack nào.

### Q: Chi phí Opusplan bao nhiêu so với Sonnet 5?
**A:** Tính theo model:
- **Sonnet 5 thuần:** $2–3 / 1M token input (intro pricing → $3 normal)
- **Opus 4.8:** $5 / 1M token input
- **Haiku 4.5:** $1 / 1M token input

**Opusplan (trung bình phụ thuộc workflow):**
- Đa số việc code: **Sonnet 5** (rẻ)
- Khi cần lập kế hoạch: **Opus 4.8** (đắt hơn)
- Việc tìm kiếm/thống kê: **Haiku 4.5** (rẻ nhất)

→ **Chi phí: ~1.5–2.5× so với Sonnet 5 thuần**, tùy thuộc vào tỷ lệ Opus dùng. Với bộ khung, Opus chỉ được gọi ở ~20–30% các task (quyết định/lập kế hoạch), nên **trung bình rẻ hơn nếu dùng Opus 100%**.

---

## 8. Tiếp theo

Sau khi áp dụng cấu hình:
1. ✅ Commit file `.claude/settings.json` vào git
2. ✅ Mở phiên Claude Code, mô tả dự án → AI tự chạy khung
3. ✅ Đọc `AP-DUNG-vao-du-an-co-san.md` nếu dự án cũ (brownfield)
4. ✅ Đọc `KHOI-TAO-du-an-moi.md` nếu dự án mới (greenfield)

---

**Happy building! 🚀**
