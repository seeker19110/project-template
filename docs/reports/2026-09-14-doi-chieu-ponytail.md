# Đối chiếu ba cột — nguồn ngoài: `DietrichGebert/ponytail`

> Phương pháp: `docs/framework/adopt-from-outside.md` (§1 ba cột · §2 cổng "sự cố thật" · §3 grep cổng
> đang chạy · §4 kiểm mâu thuẫn luật). Ngày: 2026-09-14. Bản clone đã đọc: 166 file, `main`, MIT.
> Yêu cầu của người dùng: *"lấy tất những thứ hay"* — "tất" ở đây được hiểu theo phương pháp: **mọi hạng
> mục qua được ba cột + cổng §2**, không phải "chép mọi thứ".

## 0. Nguồn là gì

Bộ skill/rules "lập trình viên lười" cho agent: 6 skill (`ponytail`, `-review`, `-audit`, `-debt`,
`-gain`, `-help`), hook `.js` cho ~15 harness, rules file nhân bản cho từng nền tảng
(`.cursor/`, `.windsurf/`, `.kiro/`, `.clinerules/`, `.qoder/`, `.github/copilot-instructions.md`…),
12 file `examples/`, benchmark tự công bố ("54% ít code, ~20% rẻ, ~27% nhanh").

Hạt nhân là **thang quyết định trước khi viết code** (YAGNI → đã có trong repo → stdlib → tính năng
native → dependency đã cài → một dòng → bản tối thiểu), cộng một **quy ước đánh dấu chỗ cố ý làm tắt**
(`ponytail: <trần>, <đường nâng cấp>`) và một skill gom các dấu đó thành sổ nợ.

## 1. Cột "ĐÃ CÓ và SÂU HƠN" — không lấy gì

| Hạng mục nguồn | Ở đây đã có | Mạnh hơn ở chỗ nào |
|---|---|---|
| `ponytail-audit` (audit repo tìm chỗ cắt) | `/audit-optimize` + `docs/ops/code-optimization-audit-prompt.md` | Đo bằng **công cụ thật** (knip/depcheck/jscpd/ESLint complexity/bundle-analyzer) chứ không bằng phán đoán của model; bắt buộc **đo baseline trước, DỪNG chờ duyệt**, mỗi sửa có test bảo vệ + PR riêng |
| `ponytail-review` (review chỉ săn phức tạp) | skill `code-review` + `.claude/agents/reviewer.md` | Cùng lượt bắt cả correctness lẫn đơn giản hóa; `reviewer` là một tầng độc lập trong kiến trúc 3 tầng, không chỉ là một prompt |
| "Bug fix = root cause, không phải triệu chứng" | `.claude/commands/debug.md` (5 pha) + `TRAPS.md` + §3.6 (test tái hiện đỏ trước) | `/debug` bắt dựng **feedback loop đỏ-được chạy thật** trước khi ra giả thuyết; ponytail chỉ có một đoạn khuyên |
| "Never simplify away: validation, error handling, security, a11y" | `CLAUDE.md` §3.1–3.3, §3.8, §9 | Là luật có cổng (lint a11y, review bảo mật, dừng-và-hỏi), không phải một đoạn cảnh báo |
| Chống phình phạm vi / gold-plating cấp yêu cầu | §2 Feature gate (spec Approved mới được code) + §2 "chủ động góp ý" + §9 | Cưỡng chế bằng `pr-policy.yml` trên mọi PR `feat` |
| "Lazy code without its check is unfinished" (mỗi logic không tầm thường để lại 1 check) | §3.6 + ADR-0005 (đỏ-trước cho code mới có nhánh/tính toán/xử lý lỗi-quyền) | Danh sách ngoại lệ ĐÓNG, phải khai trong PR |
| `ponytail-debt` phần *cơ chế quét* | `scripts/maintenance-sweep.sh` mảng 3 (đếm TODO/FIXME/HACK/XXX, ngưỡng `MAINT_TODO_WARN`) | Là engine có self-test + chạy trong CI/cron, không phải một lượt `grep` do model tự gọi |

## 2. Cột "ĐÃ CÓ nhưng NÔNG HƠN" — lấy ĐÚNG điểm nông (3 mục)

### N-1. Thiếu bước kiểm "thứ này đã tồn tại chưa" **TRƯỚC** khi viết code

- **Nông ở đâu:** khung siết "ít code" chủ yếu *sau khi viết* — `/audit-optimize`, `/completion`,
  `code-review`, §3.7 ("trước khi đóng một mảng/tính năng"). `grep -riE "trước khi viết (một dòng )?code|
  đã tồn tại chưa|có cần .* này"` trên toàn repo chỉ ra 3 kết quả, **cả 3 đều là cổng cấp DỰ ÁN**
  (`new-project-runbook.md` Phần C "Sẵn sàng phát triển", `/bootstrap`, `spec-driven-openspec.md`),
  không có gì ở **cấp tác vụ**.
- **Sự cố thật (cổng §2):** `docs/framework/adopt-from-outside.md` §6 gạch đầu dòng 1 — *"Đọc văn xuôi mô
  tả vấn đề rồi tin là chỗ đó còn trống. Mắc **hai lần liên tiếp** trong cùng một phiên 2026-09-14 […]
  cả hai lần thứ định 'bổ sung' đều đã có cổng thật đang chạy, và bản có sẵn mạnh hơn."* Đúng là rung 2
  của thang ("đã có trong codebase chưa? — viết lại thứ nằm cách vài file là loại rác phổ biến nhất").
  Bổ sung: `TRAPS.md` mục 11 (thêm code chạy được mà không nối cổng → code chết).
- **Lấy:** 5 dòng vào `CLAUDE.md` §3 mục A4 — thang rút gọn, chạy **sau khi đã hiểu vấn đề**, dừng ở nấc
  đầu tiên khớp. KHÔNG lấy: chế độ `lite/full/ultra`, persona "lazy senior dev", luật rút ngắn văn nói.

### N-2. Dấu nợ kỹ thuật không có cấu trúc → không ai biết bao giờ xem lại

- **Nông ở đâu:** `maintenance-sweep.sh` dòng 191 **đã có cổng** đếm `TODO|FIXME|HACK|XXX` và cảnh báo
  khi vượt ngưỡng. Nhưng nó chỉ đếm *số lượng*: một `TODO` không nói **trần** (giới hạn đã chấp nhận) và
  **điều kiện xem lại**. Nghịch lý: chính `adopt-from-outside.md` §2 đã bắt mọi quyết định "chưa cần"
  phải kèm **điều kiện xem lại** — luật đó tồn tại cho *quyết định tiếp nhận*, nhưng **không** áp cho
  *chỗ làm tắt trong code*.
- **Sự cố thật (cổng §2):** `TRAPS.md` mục 14 — bẫy được chốt bằng "không có cổng máy, chốt bằng quy ước",
  rồi **TÁI PHÁT 2026-09-14 (PR #111)** qua một đường khác và tệ hơn. Một khoản hoãn có trần nhưng không
  có điều kiện xem lại đã mục đúng như dự đoán. Cùng khuôn: mục 12, 13, 16 đều "không có cổng máy".
- **Lấy:** quy ước dấu `DEBT:` (`DEBT: <đã giản lược gì> | trần: <giới hạn> | xem lại khi: <điều kiện>`)
  + một phép đo mới ở `maintenance-sweep.sh` mảng 3: đếm dấu `DEBT:` và **cảnh báo 🟡 riêng cho dấu
  không có "xem lại khi:"** (đúng tag `no-trigger` của nguồn). KHÔNG lấy: tên `ponytail:`, skill riêng để
  hiển thị sổ (engine sẵn có đã in ra báo cáo).

### N-3. Audit tối ưu không có nhóm "tự viết lại thứ stdlib/nền tảng đã có"

- **Nông ở đâu:** `/audit-optimize` chia 4 nhóm (dead code · trùng lặp/độ phức tạp · dependency thừa ·
  bundle). Công cụ nó dùng đo được *dependency không ai import* (depcheck/knip), **không** đo được
  *dependency đang làm thứ stdlib/nền tảng đã làm* hay *hàm tự viết trùng stdlib* — đó là phán đoán, phải
  hỏi model tường minh mới có.
- **Sự cố thật (cổng §2):** cùng sự cố với N-1 (viết lại thứ đã có), ở mức thư viện thay vì mức repo.
- **Lấy:** thêm **nhóm 5** vào `/audit-optimize` + `code-optimization-audit-prompt.md`, kèm 2 nhãn
  `stdlib:` / `native:` của nguồn và chỉ số tổng `net: -N dòng, -M dependency`. KHÔNG lấy: nhãn
  `delete:`/`yagni:`/`shrink:` — trùng nhóm 1–2 đã có.

## 3. Cột "CHƯA CÓ" — đối chiếu cổng §2

| Hạng mục | Sự cố thật? | Quyết định |
|---|---|---|
| Ba mức cường độ `lite / full / ultra` | Không | **Không lấy — mâu thuẫn luật** (§4 dưới) |
| `ponytail-gain`: bảng điểm lợi ích từ benchmark | Không | **Không lấy.** Số do chính nguồn tự công bố, chưa ai kiểm độc lập; `CLAUDE.md` §4 cấm nói con số không tự chứng minh được. (Ghi nhận: phần "Honesty boundary" của nó — *không bao giờ in số tiết kiệm cho repo cụ thể vì bản-chưa-viết không có baseline* — là một luật ĐÚNG và đã nằm sẵn trong §4/§7 của khung) |
| `ponytail-help`: thẻ tra cứu lệnh | Không | **Không lấy.** `CLAUDE.md` §1 đã là mục lục một-nguồn-sự-thật, có cổng 2 chiều `check-docs-consistency.sh` §3 |
| Rules file nhân bản cho ~15 harness | Không | **Không lấy.** `AGENTS.md` (chuẩn mở agents.md) đã phủ; 15 bản sao tay là đúng thứ `CONVENTIONS.md` gọi là nguồn lệch |
| `examples/*.md` (12 ví dụ "50 dòng → 1 dòng") | Không | **Chưa cần**, kèm **điều kiện xem lại:** khi thang ở N-1 bị bỏ qua ≥ 2 lần có ghi nhận (PR phải làm lại vì viết lại thứ đã có) → lúc đó thêm 3–4 ví dụ vào `quality-supplements-group2.md` mục 9, không tạo thư mục riêng |
| Hook `.js` tự kích hoạt chế độ mỗi phiên + statusline | Không | **Chưa cần**, kèm **điều kiện xem lại:** khi có bằng chứng agent quên áp thang dù đã ghi ở `CLAUDE.md` §3 (thứ `CLAUDE.md` được nạp mỗi phiên vốn đã bảo đảm) |
| Quy ước `# ponytail:` đặt tên theo thương hiệu nguồn | — | **Không lấy tên**, chỉ lấy cấu trúc (xem N-2) |

## 4. Kiểm mâu thuẫn luật (§4 của phương pháp)

- **`lite/full/ultra` ↔ `CLAUDE.md` §2 + §9.** Mức `ultra` ("YAGNI extremist, thách thức yêu cầu trong
  cùng một hơi") và luật `full` "**Never stall on an answer you can default**" nói **ngược** với §9 (danh
  sách BẮT BUỘC dừng và hỏi: yêu cầu mơ hồ, breaking change, đụng bảo mật/thanh toán/dữ liệu thật) và với
  §2 Feature gate (chưa Approved thì không được sửa source). Cấy vào đây là cấy một mâu thuẫn mà agent sẽ
  chọn ngẫu nhiên tuỳ phiên — đúng ví dụ ở §4 của `adopt-from-outside.md`. → không lấy.
- **Luật văn phong "code first, tối đa 3 dòng giải thích, xoá mọi prose" ↔ §7 Báo cáo xác thực** (bắt in
  đủ khuôn Build/Type/Lint/Format/Test + rủi ro + góp ý) và ↔ §2 "chủ động góp ý (BẮT BUỘC)". → không lấy.
- Hai mâu thuẫn này **được nêu ra chứ không tự hoà giải**: nếu muốn một chế độ "nói ngắn", đó là một
  quyết định riêng của người dùng, không phải hệ quả của việc tiếp nhận nguồn này.

## 5. Kết luận — thực sự lấy

**3 / ~14 hạng mục** (tỷ lệ này nằm đúng khoảng §5 của phương pháp coi là bình thường):

1. **N-1** thang kiểm trước khi viết code → `CLAUDE.md` §3 A4 (+ `AGENTS.md` mirror).
2. **N-2** quy ước dấu `DEBT:` có trần + điều kiện xem lại → `CLAUDE.md` §3 A7, chi tiết ở
   `docs/framework/quality-supplements-group2.md` mục 9, **có cổng** ở `scripts/maintenance-sweep.sh`
   + negative test ở `scripts/test-maintenance-sweep.sh`.
3. **N-3** nhóm 5 "viết lại thứ stdlib/nền tảng đã có" → `.claude/commands/audit-optimize.md` +
   `docs/ops/code-optimization-audit-prompt.md`.

Không lấy: 6 skill dưới dạng skill, hook đa nền tảng, rules 15 bản sao, benchmark/scoreboard, ba mức
cường độ, luật văn phong.

## 6. Đính chính giữ nguyên (§5 của phương pháp)

- **Nhận định đầu tiên khi mới đọc README là SAI một nửa.** Lượt trả lời đầu (chỉ đọc README qua WebFetch)
  kết luận "giá trị ≈ một mục nhỏ: thêm thang 6 bước, còn lại khung đã phủ sâu hơn". Sau khi clone và đọc
  file thật, `ponytail-debt` — thứ README gần như không nhắc — lại là hạng mục **có bằng chứng sự cố mạnh
  nhất** (`TRAPS.md` mục 14 tái phát). Bài học đúng như §3 của phương pháp, chỉ là chiều ngược: **đọc văn
  xuôi (README) cũng làm lỡ thứ có giá trị, không chỉ làm tưởng nhầm chỗ trống.** Phải đọc nguồn thật.
- **Cũng ở lượt đầu, đã định xếp `ponytail-debt` vào "chưa có → chưa cần vì không có sự cố".** Bị chính
  cổng §2 lật lại khi `grep` `TRAPS.md`: bốn mục liên tiếp chốt bằng "không có cổng máy, chốt bằng quy
  ước", một trong số đó đã tái phát thật. Ứng viên bị loại **sau khi đo** chứ không phải sau khi nghĩ —
  và ở đây phép đo cứu lại ứng viên, không loại nó.
