# ADR-0006: Điều phối 3 tầng đa model, đa nhà cung cấp AI

- **Trạng thái:** Đã chấp nhận
- **Ngày:** 2026-09-15

## Bối cảnh

Kiến trúc điều phối 3 tầng (`docs/framework/orchestration-3-tier.md`) trước ADR này mặc định
Tầng 1 (lập kế hoạch) chạy Opus/Claude, và bảng định tuyến Tầng 3 (`route:`) gán cứng từng nhãn
vào đúng một model Claude (`complex`→Opus, `standard`→Sonnet, `mechanical`→Haiku). Tầng bảo trì
(`/maintain` → `scripts/maintain-run.sh`) đã hỗ trợ chạy qua CLI subscription cục bộ của nhiều
nhà cung cấp (Claude Code, Hermes/Gemini qua Antigravity, Codex, OpenCode) từ trước, nhưng cơ chế
đó chỉ phục vụ một subagent (`maintainer`), không áp dụng cho luồng lập kế hoạch + điều phối +
thực thi chính.

Người dùng yêu cầu: trước khi chạy tác vụ tự động/lập kế hoạch lớn, phải dùng **model cao cấp
nhất sẵn có** (không giới hạn một hãng) để lên kế hoạch theo độ phức tạp của vấn đề, sau đó phân
việc cho các subagent **đủ năng lực** — chọn động, không cố định vào Claude.

## Quyết định

1. **Cả 3 tầng đều có thể chạy đa nhà cung cấp**, không riêng Tầng 3. `route:` không còn là ánh xạ
   1-1 sang một model Claude cụ thể mà là **cấp năng lực** (capability tier): `planning`,
   `complex`, `spec`, `standard`, `mechanical`. Mỗi cấp có một danh sách ứng viên đa nhà cung cấp
   trong `scripts/model-capability-tiers.json`.
2. **Chọn planner (Tầng 1) động theo độ phức tạp**, không cố định "luôn Opus thuần": so sánh các
   model cao cấp đang sẵn có (Claude Opus/Fable, và các hãng khác nếu CLI đã có nhánh xử lý thật
   trong `subagent-dispatch.py`/`maintain-run.sh`), chọn cái phù hợp/khả dụng nhất cho việc đó.
   Mặc định vẫn là `opusplan` khi không có lý do đổi — đây là **mở thêm lựa chọn**, không bỏ
   đường mặc định đã có.
3. **Phân công Tầng 3 theo xếp hạng năng lực/độ phức tạp việc**, dùng `scripts/subagent-dispatch.sh
   --tier <planning|complex|spec|standard|mechanical>` để tra ứng viên trước khi dispatch, thay vì
   suy luận "route X luôn là model Y".
4. Model/hãng ngoài Claude trong `model-capability-tiers.json` đều đánh dấu
   `verify_before_use` khi chưa có phiên bản đã xác minh trong repo — **không bịa số phiên bản**
   (CLAUDE.md §4); dùng subagent `version-check` hoặc nguồn sống để xác nhận trước khi chốt thật.
5. Cơ chế dispatch đa-harness (`--harness hermes|claude|codex|generic`) đã có từ trước trong
   `subagent-dispatch.py` **giữ nguyên và dùng chung** cho cả 3 tầng — không viết engine mới.

## Lý do

- Repo đã có sẵn hạ tầng multi-provider thật (không phải ý tưởng suông): `maintain-run.sh` chạy
  qua CLI cục bộ của 4+ hãng, `subagent-dispatch.py` đã sinh payload đúng cơ chế cho từng harness.
  Mở rộng cơ chế này ra 3 tầng là **tận dụng lại**, không phải dựng mới — đúng thang tối giản ở
  CLAUDE.md §3.4.
- Gán cứng `route:` vào một model Claude cụ thể làm mất khả năng chọn nhà cung cấp khác khi Claude
  không sẵn có, đắt hơn, hoặc khi một hãng khác mạnh hơn cho đúng loại việc đó — trái với yêu cầu
  "phân chia cho subagent đủ năng lực".
- Tách ánh xạ model↔cấp năng lực ra file JSON riêng (theo đúng khuôn `model-rates.json`) để việc
  cập nhật model mới không đụng code, và giữ được dấu vết "đã xác minh ngày nào, nguồn nào" —
  tránh ảo giác phiên bản.

## Các phương án đã cân nhắc

- **Viết engine điều phối đa-provider hoàn toàn mới** (queue, adapter riêng cho từng hãng): quá lớn
  so với nhu cầu thật, trùng lặp với `maintain-run.sh`/`subagent-dispatch.py` đã có — bị loại theo
  thang tối giản CLAUDE.md §3.4 (mục 2: đã có helper, dùng lại).
- **Chỉ đổi văn xuôi tài liệu, không đổi script** (nói "có thể dùng nhà cung cấp khác" nhưng không
  có cơ chế tra cứu/ánh xạ nào chạy được): bị loại vì không kiểm chứng được (đúng luật §11 "grep
  cổng đang chạy, đừng đọc văn xuôi") — tài liệu nói mà không có gì thực thi thì không phải quyết
  định thật.
- **Pin cứng model cụ thể của từng hãng ngay trong ADR này**: bị loại vì không có nguồn sống xác
  minh tại thời điểm viết cho GPT/Gemini phiên bản chính xác — sẽ là ảo giác. Thay vào đó đánh dấu
  `verify_before_use` và trỏ tới `version-check`.

## Hệ quả

- `docs/framework/orchestration-3-tier.md`, `docs/framework/models-and-automation.md`, và
  `CLAUDE.md` §2 cập nhật để phản ánh quyết định này (không sửa ADR cũ nào).
- `scripts/subagent-dispatch.py` thêm `--tier` (không đổi hành vi `--agent`/`--harness` cũ — tương
  thích ngược, `scripts/test-telemetry-and-dispatch.sh` đã có ca kiểm hồi quy).
- Việc thật sự gọi CLI của hãng khác trong Tầng 1/2 (không chỉ tra cứu ứng viên) vẫn cần CLI đó cài
  + đăng nhập subscription cục bộ, đúng ràng buộc đã có ở `maintain-run.sh` — ADR này không giả
  định có sẵn quyền truy cập API của hãng khác.
