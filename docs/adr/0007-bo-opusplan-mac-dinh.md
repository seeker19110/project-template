# ADR-0007: Bỏ `opusplan` làm chế độ/mặc định — lập kế hoạch & phân việc theo độ phức tạp, chọn model thủ công

- **Trạng thái:** Đã chấp nhận
- **Ngày:** 2026-09-15
- **Đảo ngược một phần:** ADR-0006 (mục 2 — "Mặc định vẫn là `opusplan` khi không có lý do đổi")

## Bối cảnh

`opusplan` từng là một **chế độ** của Claude Code CLI (`/model opusplan`): tự chuyển Opus khi lập kế
hoạch, tự chuyển Sonnet khi thực thi, trong cùng một phiên. Framework này (CLAUDE.md §2,
`docs/framework/models-and-automation.md`, `docs/framework/orchestration-3-tier.md`,
`.claude/settings.json`) đặt `opusplan` làm model mặc định dựa trên chế độ đó.

Người dùng xác nhận `/model opusplan` **không còn được hỗ trợ** ở phiên bản CLI hiện tại. Cấu hình
`"model": "opusplan"` trong `.claude/settings.json`/`settings-shared-*.json` và toàn bộ hướng dẫn
gõ `/model opusplan` trong tài liệu khung nay trỏ tới một lựa chọn không còn tồn tại.

## Quyết định

1. **Không còn tên/alias mặc định cố định cho "chế độ hai pha".** Thay bằng chính sách hai pha làm
   thủ công, đúng tinh thần ADR-0006 nhưng không phụ thuộc một tên lệnh CLI cụ thể:
   - **Pha lập kế hoạch** (trước tác vụ tự động/lập kế hoạch lớn — theo đúng câu chữ ADR-0006 mục
     2): chủ động chuyển sang **model cao cấp nhất đang sẵn có**, chọn theo độ phức tạp thật của
     vấn đề (Claude Opus 5 / Fable 5.1, hoặc hãng khác nếu `subagent-dispatch.py` đã có nhánh xử lý
     thật — không giới hạn một hãng, giữ nguyên ADR-0006 mục 1–2).
   - **Pha thực thi**: quay lại model tiêu chuẩn của dự án (mặc định repo: **Sonnet 5** —
     `.claude/settings.json`), rồi **phân việc/PR cho các subagent/model khác theo độ phức tạp**
     qua `scripts/subagent-dispatch.sh --tier <planning|complex|spec|standard|mechanical>` — giữ
     nguyên cơ chế `model-capability-tiers.json` của ADR-0006, không đổi.
2. `.claude/settings.json` và `.claude/settings-shared-default.json` (đổi tên từ
   `settings-shared-opusplan.json`) đặt `"model": "claude-sonnet-5"` — model tiêu chuẩn cho pha
   thực thi, không còn field nào tham chiếu một chế độ không tồn tại.
3. `session-guide.sh` bỏ việc so khớp `model_id` với chuỗi `"opusplan"` (không còn ý nghĩa) — chỉ
   còn hiển thị model phiên hiện tại và nhắc chính sách hai pha ở mục 1, không tự chấm ✅/⚠️ theo
   tên model nữa (không có gì để so khớp đúng-sai).
4. Toàn bộ tài liệu khung nêu `/model opusplan` được sửa thành hướng dẫn chung: "chuyển sang model
   cao cấp nhất đang sẵn có cho pha lập kế hoạch, quay lại model tiêu chuẩn cho pha thực thi" —
   không nêu đích danh một lệnh `/model <tên>` cố định, vì tên model/alias có thể đổi theo phiên
   bản CLI (đúng bài học của chính ADR này).
5. **Không đổi gì khác của ADR-0006**: bảng cấp năng lực (`planning|complex|spec|standard|
   mechanical`), `model-capability-tiers.json`, `subagent-dispatch.py --tier`, yêu cầu
   `verify_before_use` cho model chưa xác minh — tất cả giữ nguyên.

## Lý do

- Hard-code một alias CLI cụ thể (`opusplan`) làm mặc định trong hơn 20 file tài liệu/cấu hình đã
  tỏ ra dễ vỡ: một thay đổi phía nhà cung cấp CLI (rút alias) làm toàn bộ hàng rào tự xác
  nhận/cảnh báo của `session-guide.sh` mất tác dụng ngay lập tức, và người dùng phải tự phát hiện
  ra "sao lệnh này không còn nữa" thay vì được khung tự thích nghi.
- Chính sách thật sự framework cần (lập kế hoạch bằng model mạnh nhất, thực thi + phân việc theo
  độ phức tạp) đã được ADR-0006 mô tả đúng — chỉ riêng câu "mặc định vẫn là `opusplan`" là phần
  phụ thuộc tên lệnh cụ thể, nên ADR này chỉ đảo phần đó, không viết lại toàn bộ ADR-0006.
- Không tự bịa một alias mới thay thế (CLAUDE.md §4 "không tin lời khai" / không đoán tính năng CLI
  chưa xác nhận) — mô tả chính sách bằng hành vi thao tác tay (`/model <model-id>` khi cần), không
  giả định CLI còn hỗ trợ một cơ chế tự-chuyển-theo-pha nào khác.

## Các phương án đã cân nhắc

- **Tìm alias thay thế tương đương** (`/model auto` hay cơ chế mới của CLI): bị loại vì phiên hiện
  tại không xác nhận được sự tồn tại một cách sống (không có nguồn để `version-check`), sẽ là ảo
  giác nếu bịa ra.
- **Giữ nguyên `opusplan` trong cấu hình, chỉ sửa văn xuôi cảnh báo**: bị loại vì `.claude/
  settings.json` đặt `"model": "opusplan"` là cấu hình THẬT sẽ được CLI đọc mỗi phiên — để giá trị
  không hợp lệ ở đó gây lỗi/hành vi không xác định ngay khi mở phiên, không chỉ là vấn đề tài liệu.
- **Sửa ADR-0006 tại chỗ**: vi phạm luật "không sửa ADR cũ" (CLAUDE.md mục 1, khoản `docs/adr/`) —
  ADR mới ghi quyết định đảo ngược, giữ nguyên lịch sử ADR-0006.

## Hệ quả

- `.claude/settings.json`, `.claude/settings-shared-default.json` (đổi tên từ
  `settings-shared-opusplan.json`), `.claude/hooks/session-guide.sh`,
  `docs/framework/models-and-automation.md`, `docs/framework/orchestration-3-tier.md`,
  `docs/framework/new-project-runbook.md`, `docs/framework/case-study-greenfield-dry-run.md`,
  `CLAUDE.md` §2, `CODEMAP.md`, `README.md`, `copy-framework.sh`, các `.claude/commands/*.md` có
  nhắc model/effort, và `scripts/model-capability-tiers.json` (chú thích) cập nhật để bỏ tham chiếu
  `opusplan` — không sửa ADR-0006.
- Người dùng cần tự chọn model cho pha lập kế hoạch bằng tay mỗi khi bắt đầu việc lớn (không còn tự
  động chuyển theo pha trong một phiên) — đánh đổi chấp nhận được vì cơ chế cũ dù sao cũng không
  còn khả dụng.
