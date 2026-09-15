# Feature spec: Điều phối 3 tầng đa model, đa nhà cung cấp

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Trước tác vụ tự động/lập kế hoạch lớn phải chọn model cao cấp nhất sẵn có (không giới hạn Claude) theo độ phức tạp, rồi phân việc cho subagent đủ năng lực — yêu cầu trực tiếp của người dùng trong phiên 2026-09-15 |
| Spec owner | Phiên AI 2026-09-15 |
| State | **Approved for implementation** |
| Approver / date | donghanhcungban.org@gmail.com — 2026-09-15 ("đúng, làm theo 5 mục trên đi" — xác nhận kế hoạch 5 mục: ADR + CLAUDE.md §2 + orchestration-3-tier.md + models-and-automation.md + subagent-dispatch) |
| Last updated | 2026-09-15 |

## 1. Problem, user và evidence

`route:` (Tầng 3) và Tầng 1 (lập kế hoạch) trong `orchestration-3-tier.md` gán cứng vào đúng một
model Claude (`complex`→Opus, `standard`→Sonnet, `mechanical`→Haiku). Cơ chế đa nhà cung cấp thật
đã tồn tại từ trước (`scripts/maintain-run.sh` gọi được Claude Code/Hermes-Antigravity/Codex/
OpenCode qua CLI subscription cục bộ), nhưng chỉ phục vụ một subagent (`maintainer`), không áp
dụng cho luồng lập kế hoạch + điều phối + thực thi chính. Người dùng yêu cầu mở rộng nguyên tắc
"planner cao cấp nhất sẵn có + worker đủ năng lực" ra toàn bộ 3 tầng, không riêng bảo trì.

## 2. Outcome, baseline, target và guardrails

- Baseline: `route:` = ánh xạ 1-1 sang một model Claude; không có cơ chế tra ứng viên đa nhà cung
  cấp cho Tầng 1/3; `subagent-dispatch.py` chỉ có `--agent`/`--harness`/`--list`.
- Target: `route:` là **cấp năng lực** (không phải tên model); `scripts/subagent-dispatch.sh --tier
  <planning|complex|spec|standard|mechanical>` in ứng viên đa nhà cung cấp từ
  `scripts/model-capability-tiers.json`; tài liệu 3 tầng + model/automation phản ánh đúng.
- Guardrail: **không bịa phiên bản model** của hãng khác Claude — model chưa xác minh phải đánh
  `verify_before_use: true` (CLAUDE.md §4).
- Guardrail: hành vi mặc định (`opusplan`/Claude xuyên suốt, `--agent`/`--harness`/`--list` cũ)
  **không đổi** — đa nhà cung cấp là lựa chọn thêm, không phải bắt buộc đổi hãng.

## 3. Research current state

- `scripts/maintain-run.sh` đã có cú pháp CLI **đã xác minh** cho 4 harness (dòng 16–22 của file):
  dùng lại nguyên, không đoán cú pháp mới.
- `scripts/subagent-dispatch.py` đã có `build_dispatch_payload`/`--harness` cho
  `hermes|claude|codex|generic` — dùng lại cơ chế này, không viết engine mới.
- `scripts/model-rates.json` là khuôn có sẵn cho "bảng dữ liệu tách khỏi code, có `_verified_on`/
  `_source`" — áp cùng khuôn cho `model-capability-tiers.json`.
- Không có nguồn sống nào tra được trong phiên (không gọi WebFetch) cho số phiên bản model GPT/
  Gemini chính xác → mọi ứng viên ngoài Claude đánh `verify_before_use: true`.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Chỉ sửa văn xuôi tài liệu, không đổi script | 0 công | Không kiểm chứng được (vi phạm §11 "grep cổng đang chạy") | ❌ |
| Viết engine điều phối đa-provider mới (queue, adapter riêng) | "đầy đủ" hơn | Trùng lặp `maintain-run.sh`/`subagent-dispatch.py` đã có — vi phạm thang tối giản §3.4 | ❌ |
| Pin cứng phiên bản model từng hãng ngay trong PR này | Cụ thể ngay | Không có nguồn sống xác minh tại thời điểm viết → ảo giác (CLAUDE.md §4) | ❌ |
| Thêm `--tier` + JSON ứng viên (đánh `verify_before_use`), tận dụng `--harness` đã có | Tối giản, có test hồi quy, không bịa version | Chưa gọi CLI hãng khác thật (chỉ tra cứu) | ✅ |

## 5. Scope / non-goals

**Trong phạm vi:** `docs/adr/0006-da-model-da-nha-cung-cap-dieu-phoi.md` (mới) ·
`scripts/model-capability-tiers.json` (mới) · `scripts/subagent-dispatch.py` (`--tier`) ·
`scripts/test-telemetry-and-dispatch.sh` (2 ca mới) · `CLAUDE.md` §2 ·
`docs/framework/orchestration-3-tier.md` · `docs/framework/models-and-automation.md` §2b/§3 ·
`CODEMAP.md` · `PROGRESS.md`.

**Non-goals:** không tự động gọi CLI của hãng khác Claude trong Tầng 1/2/3 (vẫn cần CLI cài +
đăng nhập cục bộ, như `maintain-run.sh` đòi hỏi) · không đổi bảng route/model mặc định của
`.claude/agents/*.md` · không đổi hành vi `--agent`/`--harness`/`--list` hiện có · không pin phiên
bản model ngoài Claude chưa xác minh.

## 6. User journeys và mọi state

- Tầng 1 cần chọn planner cho việc lớn → chạy `--tier planning`, thấy ứng viên kèm cờ xác minh,
  quyết định dùng Claude (mặc định) hay đổi hãng (nếu CLI sẵn có + đã xác minh). (happy)
- Gọi `--tier` với giá trị không có trong `choices` → lỗi rõ, không chạy bừa. (lỗi input)
- File `model-capability-tiers.json` bị xoá/hỏng → `load_capability_tiers()` trả rỗng, `--tier`
  báo lỗi "không có trong file" thay vì crash. (thiếu dữ liệu)

## 7. Functional requirements

- **FR-1** `scripts/subagent-dispatch.py --tier <planning|complex|spec|standard|mechanical>` in
  danh sách ứng viên (provider, harness, model_hint, verify_before_use) từ
  `model-capability-tiers.json`, hỗ trợ `--json`.
- **FR-2** Giá trị `--tier` ngoài 5 cấp đã khai → thoát khác 0, không chạy.
- **FR-3** `--agent`/`--harness`/`--list` hiện có giữ nguyên hành vi (không có ca test cũ nào đổi
  kết quả).
- **FR-4** `model-capability-tiers.json` theo khuôn `model-rates.json`: có `_verified_on`,
  `_source`; mỗi ứng viên có `verify_before_use`.

## 8. Non-functional requirements

- Không thêm dependency Python mới (chỉ dùng `json`/`os` đã import sẵn).
- `--tier` chạy tức thời (đọc 1 file JSON nhỏ, không gọi mạng).

## 9. Acceptance criteria

- **AC-1** `bash scripts/subagent-dispatch.sh --tier standard` in được ≥ 2 nhà cung cấp khác nhau.
- **AC-2** `bash scripts/subagent-dispatch.sh --tier khong-ton-tai` thoát khác 0.
- **AC-3** `bash scripts/test-telemetry-and-dispatch.sh` xanh toàn bộ (gồm 6 ca cũ + 2 ca mới).
- **AC-4** `bash scripts/check-docs-consistency.sh` xanh (script mới đã khai ở CODEMAP.md).
- **AC-5** Không model/hãng nào ngoài Claude trong `model-capability-tiers.json` thiếu
  `verify_before_use` mà không có `_source` xác minh kèm theo.

## 10. UX/content/accessibility

n-a (cổng CLI nội bộ, không có UI người dùng cuối).

## 11. Architecture và code touchpoints

- `scripts/subagent-dispatch.py`
- `scripts/model-capability-tiers.json`
- `scripts/test-telemetry-and-dispatch.sh`
- `docs/framework/orchestration-3-tier.md`
- `docs/framework/models-and-automation.md`
- `CLAUDE.md`, `CODEMAP.md`, `PROGRESS.md`

## 12. API/event contract

`--tier <cấp>` in JSON (`--json`) hoặc text; hợp đồng: thoát 0 + in ứng viên khi cấp hợp lệ, thoát
khác 0 khi cấp không có trong `choices` hoặc không có trong file.

## 13. Data contract/migration

n-a — không có dữ liệu lưu trữ ngoài file JSON tĩnh trong repo.

## 14. Security/privacy/abuse cases

Không đụng bí mật/thông tin người dùng. File JSON chỉ chứa tên model/hãng công khai, không có
API key hay endpoint.

## 15. Observability và operations

Không có; đây là công cụ tra cứu cho phiên AI/người vận hành, không chạy trong pipeline CI tự
động (không phải cổng chặn).

## 16. Test/eval plan

`scripts/test-telemetry-and-dispatch.sh` mục "đa nhà cung cấp": ca `--tier standard` liệt kê được
≥ 2 hãng; ca `--tier khong-ton-tai` bị chặn.

## 17. Slice/PR plan

Một PR: ADR + JSON + `--tier` + test + tài liệu (phụ thuộc lẫn nhau, tách ra thì tài liệu trỏ tới
cơ chế chưa tồn tại).

## 18. Rollout/rollback

Rollback = revert PR; không có state tồn dư, `--tier` là cờ mới độc lập.

## 19. Risk, assumptions và open decisions

- **Rủi ro:** model_hint của hãng khác Claude có thể lỗi thời khi dùng thật. → Giảm bằng
  `verify_before_use: true` bắt buộc tra `version-check`/nguồn sống trước khi dùng, không tự suy
  đoán (CLAUDE.md §4).
- **Giả định:** người dùng đã đồng ý phạm vi "cả 3 tầng" + "planner chọn động" + "phân công theo
  xếp hạng năng lực" qua `AskUserQuestion` trong phiên trước khi triển khai.
- **Quyết định mở:** gọi CLI hãng khác thật trong Tầng 1/2 (không chỉ tra cứu ứng viên) để lại cho
  một thay đổi sau, khi có nhu cầu thực tế cụ thể (đúng luật §11 "chưa có phải ứng với sự cố thật").
