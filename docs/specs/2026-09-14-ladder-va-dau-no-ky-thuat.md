# Feature spec: Thang kiểm trước khi viết code + dấu nợ `DEBT:` có điều kiện xem lại

| Thuộc tính | Giá trị |
| --- | --- |
| Issue / Goal | Tiếp nhận nguồn ngoài `DietrichGebert/ponytail` — bản đối chiếu: `docs/reports/2026-09-14-doi-chieu-ponytail.md` |
| Spec owner | Phiên AI 2026-09-14 |
| State | **Approved for implementation** |
| Approver / date | donghanhcungban.org@gmail.com — 2026-09-14 ("lấy tất những thứ hay", sau khi được trình bày đánh giá ba cột ở lượt trước) |
| Last updated | 2026-09-14 |

## 1. Problem, user và evidence

Hai lỗ hổng đã gây sự cố thật, cả hai đều lộ ra khi đối chiếu với nguồn ngoài:

- **P1 — không có bước kiểm "thứ này đã tồn tại chưa" ở cấp tác vụ.** Bằng chứng:
  `docs/framework/adopt-from-outside.md` §6 — mắc **hai lần liên tiếp trong một phiên (2026-09-14)**,
  cả hai lần định xây lại thứ đã có cổng đang chạy. Thêm: `TRAPS.md` mục 11.
- **P2 — chỗ cố ý làm tắt không ghi điều kiện xem lại nên mục âm thầm.** Bằng chứng: `TRAPS.md` mục 14
  ("không có cổng máy, chốt bằng quy ước") **TÁI PHÁT 2026-09-14, PR #111**, tệ hơn lần đầu. Cùng khuôn ở
  mục 12, 13, 16. Cổng hiện có (`maintenance-sweep.sh` dòng ~191) chỉ **đếm** TODO/FIXME/HACK, không biết
  khoản nào có trần, khoản nào có điều kiện quay lại.

## 2. Outcome, baseline, target và guardrails

- Baseline: 0 phép đo phân biệt "nợ có điều kiện xem lại" với "nợ mục".
- Target: `maintenance-sweep.sh` in ra số dấu `DEBT:` và **cảnh báo 🟡 riêng** cho dấu thiếu
  `xem lại khi:`; quy ước được ghi ở `CLAUDE.md` §3 A7 + `AGENTS.md`.
- Guardrail: không làm đỏ cổng của repo/dự án đang có 0 dấu `DEBT:` (thiếu dấu ≠ vi phạm — quy ước là
  *nếu* đã làm tắt thì phải ghi đủ, không phải *phải* làm tắt).

## 3. Research current state

- `grep -riE "trước khi viết (một dòng )?code|đã tồn tại chưa"` → 3 kết quả, đều là cổng **cấp dự án**
  (`new-project-runbook.md` Phần C, `/bootstrap`, `spec-driven-openspec.md`), không có cấp tác vụ.
- `scripts/maintenance-sweep.sh` dòng 190–193: mảng 3 đã đếm `TODO|FIXME|HACK|XXX`, ngưỡng
  `MAINT_TODO_WARN` (mặc định 20) → chỗ mắc thêm phép đo mới, không cần mảng mới.
- `scripts/test-maintenance-sweep.sh`: đã có repo-lỗi dựng tạm ở mục 3 → chỗ mắc negative test.
- `.claude/commands/audit-optimize.md` + `docs/ops/code-optimization-audit-prompt.md`: 4 nhóm phát hiện.
- Nguồn ngoài: clone `main` ngày 2026-09-14, đọc `skills/*/SKILL.md` (6 file), `hooks/`, `examples/`.

## 4. Alternatives và decision

| Option | Benefits | Cost/risk | Decision |
| --- | --- | --- | --- |
| Do nothing | 0 công | Hai sự cố ở §1 đã xảy ra và một cái đã tái phát | ❌ |
| Chép cả 6 skill ponytail vào `.claude/commands/` | "đầy đủ" | Nhân bản luật đã có (audit/review), cấy mâu thuẫn với §9 + §7 (xem đối chiếu §4) | ❌ |
| Chỉ ghi quy ước vào tài liệu, không thêm cổng | rẻ nhất | Đúng khuôn hỏng của `TRAPS.md` mục 11/14: luật không có cổng = trang trí | ❌ |
| **Lấy 3 điểm nông, mỗi điểm mắc vào cơ chế sẵn có, N-2 có cổng máy + negative test** | nhỏ, không thêm file engine, có cổng chứng minh | Thêm ~25 dòng script | ✅ |

## 5. Scope / non-goals

**Trong phạm vi:** `CLAUDE.md` §3 A4 + A7 · `AGENTS.md` (mirror) ·
`docs/framework/quality-supplements-group2.md` mục 9 (chi tiết quy ước `DEBT:`) ·
`scripts/maintenance-sweep.sh` (phép đo mới) · `scripts/test-maintenance-sweep.sh` (negative test) ·
`.claude/commands/audit-optimize.md` + `docs/ops/code-optimization-audit-prompt.md` (nhóm 5).

**Non-goals:** không thêm slash command mới · không thêm skill/persona · không chế độ cường độ · không
đổi luật văn phong (§7 giữ nguyên) · không đụng `TRAPS.md` (không có khuôn lỗi MỚI trong PR này).

## 6. User journeys và mọi state

- Repo có 0 dấu `DEBT:` → báo cáo in `- Dấu nợ DEBT:: 0` + ℹ️, không 🟡. (state: rỗng)
- Có dấu đủ `xem lại khi:` → ℹ️ kèm số lượng. (happy)
- Có dấu thiếu `xem lại khi:` → 🟡 "nợ không có điều kiện xem lại". (cảnh báo)
- Không phải git repo → mảng 3 bỏ qua phép đo như các phép đo git khác, không crash. (n-a)

## 7. Functional requirements

- **FR-1** `CLAUDE.md` §3 mục A4 có thang ≤ 6 nấc, chạy **sau khi đã hiểu vấn đề**, dừng ở nấc đầu tiên khớp.
- **FR-2** `CLAUDE.md` §3 mục A7 khai quy ước dấu: `DEBT: <giản lược gì> | trần: <giới hạn> | xem lại khi: <điều kiện>`.
- **FR-3** `maintenance-sweep.sh` mảng 3 đếm dấu `DEBT:` trong mã đã track.
- **FR-4** Dấu `DEBT:` không chứa `xem lại khi:` → phát hiện mức 🟡, mảng "Nợ kỹ thuật".
- **FR-5** `/audit-optimize` có **nhóm 5** "viết lại thứ stdlib/nền tảng đã có", dùng nhãn `stdlib:`/`native:`, báo cáo kết bằng `net: -N dòng, -M dependency`.
- **FR-6** `AGENTS.md` mirror FR-1 + FR-2 (luật cốt lõi phải khớp hai file — `CLAUDE.md` §1).

## 8. Non-functional requirements

- Phép đo mới chạy ≤ 1s trên repo khung; không cần mạng; không phụ thuộc stack.
- Không làm tăng `CLAUDE.md` quá 200 dòng (quy ước `CONVENTIONS.md` mục B).

## 9. Acceptance criteria

- **AC-1** `bash scripts/test-maintenance-sweep.sh` xanh, có thêm 2 khẳng định: bắt được dấu thiếu điều kiện xem lại (🟡) **và** không báo 🟡 khi dấu ghi đủ.
- **AC-2** `bash scripts/check-docs-consistency.sh` xanh (mọi đường dẫn backtick mới tồn tại thật).
- **AC-3** `wc -l CLAUDE.md` < 200.
- **AC-4** `bash scripts/maintenance-sweep.sh --no-deps` trên chính repo này thoát 0 và có dòng đếm `DEBT:`.

## 10. UX/content/accessibility

n-a (không có UI). Văn bản tiếng Việt, khớp giọng tài liệu hiện có.

## 11. Architecture và code touchpoints

- `CLAUDE.md`
- `AGENTS.md`
- `docs/framework/quality-supplements-group2.md`
- `scripts/maintenance-sweep.sh`
- `scripts/test-maintenance-sweep.sh`
- `.claude/commands/audit-optimize.md`
- `docs/ops/code-optimization-audit-prompt.md`
- `docs/reports/2026-09-14-doi-chieu-ponytail.md`

## 12. API/event contract

n-a.

## 13. Data contract/migration

n-a — dấu `DEBT:` là comment trong mã, không có dữ liệu lưu trữ. Dấu `TODO/FIXME/HACK` cũ vẫn được đếm như trước (không thay thế, không migration).

## 14. Security/privacy/abuse cases

Phép đo chỉ đọc file đã track, không in nội dung dòng khớp ra báo cáo ngoài số đếm → không rò rỉ nội dung mã.

## 15. Observability và operations

Đã có: báo cáo `maintenance-sweep` chạy trong `maintenance.yml` + `maintain-cron.sh`. Số dấu `DEBT:` và số dấu thiếu điều kiện xem lại xuất hiện ở đó mỗi lượt quét.

## 16. Test/eval plan

Negative test trong `scripts/test-maintenance-sweep.sh` (quy ước `CONVENTIONS.md` mục A: mọi assertion mới phải chứng minh bắt được vi phạm) — dựng repo tạm có 1 dấu đủ + 1 dấu thiếu, khẳng định đúng một 🟡.

## 17. Slice/PR plan

Một PR duy nhất (thay đổi nhỏ, mọi mảnh phụ thuộc lẫn nhau: quy ước ↔ cổng ↔ tài liệu).

## 18. Rollout/rollback

Rollback = revert PR; không có state tồn dư.

## 19. Risk, assumptions và open decisions

- **Rủi ro:** thêm một quy ước đánh dấu thứ ba (`TODO` / `ponytail-like DEBT:` / ADR) có thể gây phân vân "dùng cái nào". → Giảm bằng một câu phân vai trong `quality-supplements-group2.md`: `TODO` = việc còn dở; `DEBT:` = **cố ý** dừng ở một trần đã biết; ADR = quyết định kiến trúc.
- **Giả định:** dự án đích dùng comment `//` hoặc `#`. Phép đo grep theo chuỗi `DEBT:` nên không phụ thuộc kiểu comment.
- **Open:** chưa chốt ngưỡng cảnh báo cho tổng số dấu `DEBT:` — vòng đầu chỉ cảnh báo dấu thiếu điều kiện xem lại, thêm ngưỡng khi có dữ liệu thật.

## Approval

**Approved for implementation** — donghanhcungban.org@gmail.com, 2026-09-14.
