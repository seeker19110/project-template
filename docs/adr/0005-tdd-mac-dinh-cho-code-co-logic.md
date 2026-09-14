# ADR-0005: TDD là mặc định bắt buộc cho code MỚI có logic, với danh sách ngoại lệ đóng

- **Trạng thái:** Đề xuất
- **Ngày:** 2026-09-14

## Bối cảnh

Luật hiện tại (`CLAUDE.md` §3.6, `AGENTS.md`, `quality-supplements-group2.md` Nhóm 2 mục 6) chia
làm hai mức:

- **Bắt buộc:** commit `fix:` phải có test tái hiện chạy **đỏ trước khi sửa**.
- **Khuyến nghị:** vòng đỏ-xanh cho code **MỚI** (chưa có bug).

Mức khuyến nghị đó **không phải chỗ trống chưa ai nghĩ tới** — nó có lý do viết sẵn:

> "Vòng đỏ-xanh là kỹ thuật để viết code MỚI — dùng khi có chủ đích, khuyến nghị, không bắt buộc
> cho mọi thay đổi (ép test-trước lên scaffolding/rename/docs là **nghi thức rỗng**)."

Đợt đối chiếu 2026-09-14 với `seeker19110/Claude-Agents` (`docs/reports/2026-09-14-doi-chieu-…`)
tìm thấy repo đó chạy TDD **cứng tuyệt đối**:

```
KHÔNG CODE SẢN XUẤT NÀO ĐƯỢC VIẾT TRƯỚC KHI CÓ TEST ĐỎ CHO NÓ
```

kèm `fail_under = 100` (dòng **và** nhánh) trên 5 package, 2889 test — và nó hoạt động thật.
Đối chiếu đó xếp hạng mục này vào diện "cần một PR riêng có ADR" thay vì lấy ngay, đúng vì hai lẽ
mà ADR này phải giải quyết: nó **mâu thuẫn với một luật đang có**, và nó **lan sang mọi dự án đích**
qua `copy-framework.sh`.

## Quyết định

Nâng vòng đỏ-xanh cho code MỚI từ **khuyến nghị** lên **mặc định bắt buộc**, kèm một **danh sách
ngoại lệ đóng** (liệt kê được, không phải "tuỳ ngữ cảnh"):

**Bắt buộc test đỏ trước** khi code mới chứa **nhánh điều kiện, tính toán, hoặc xử lý lỗi/quyền** —
tức mọi thứ ngoài danh sách dưới.

**Ngoại lệ, không cần test-trước** (PR ghi **một dòng** nói rơi vào ngoại lệ nào):

1. Scaffolding / boilerplate sinh từ template hoặc công cụ (`create-next-app`, generator…).
2. Đổi tên, di chuyển file, thay đổi cơ học không đổi hành vi.
3. Thay đổi chỉ chạm tài liệu, comment, hoặc **config thuần** (không có nhánh logic).
4. Code **sinh tự động** — sửa nguồn rồi sinh lại, không sửa tay bản dẫn xuất.
5. Prototype vứt đi (spike có timebox), khai rõ là sẽ xoá.

**Không** áp bản cứng tuyệt đối của `Claude-Agents` (xem "Các phương án đã cân nhắc", B).

## Lý do

**Vì sao nâng.** "Khuyến nghị" không có điểm chạm nào trong quy trình: không cổng nào hỏi, không mục
nào trong PR template buộc trả lời, nên trên thực tế nó tương đương "không có luật". Mức bắt buộc
tạo ra **một câu phải trả lời trong PR** — và đó là toàn bộ cơ chế: người viết phải nói ra mình đã
làm gì, thay vì im lặng bỏ qua.

**Vì sao giữ ngoại lệ thay vì cứng tuyệt đối.** Phản đối trong `quality-supplements-group2.md` là
**đúng và có dữ liệu**: ép test-trước lên scaffolding/rename/docs sinh ra test vô nghĩa, và chính
tài liệu đó đã chỉ ra ba khuôn test-vô-dụng (implementation-coupled, tautological, horizontal
slicing) mà nghi thức rỗng làm trầm trọng thêm. Bỏ phản đối đó để chép một luật từ repo khác là
đúng thứ `CLAUDE.md` §11 cấm: *hạng mục mâu thuẫn với luật đang có thì không lấy dù chưa có*.

**Vì sao ngoại lệ phải ĐÓNG, không phải "tuỳ ngữ cảnh".** `TRAPS.md` §6 của `Claude-Agents` ghi hẳn
một bảng "câu tự biện hộ thường gặp trước khi né luật" — *"quá đơn giản nên khỏi test"*, *"test sau
cũng như nhau"*, *"đã tự tay thử rồi"*. Một ngoại lệ mở là chỗ cho đúng những câu đó. Năm mục trên
đều kiểm được bằng mắt trong 5 giây khi review.

**Vì sao bối cảnh hai repo khác nhau, và điều đó có ý nghĩa.** `Claude-Agents` là **một** repo,
**một** ngôn ngữ, sản phẩm chính là *logic quyết định* (guard/gate/fail-closed) — chính
`companies/keeper/pyproject.toml` của nó viết: *"với một repo mà sản phẩm chính là logic quyết định,
nhánh mới là thứ đáng chặn"*. Khung này phục vụ **10 hồ sơ** (C1–C10: web, mobile, desktop, backend,
site tĩnh, CLI/thư viện, data/ML, game, blockchain, monorepo). "TDD cứng cho mọi code, mọi hồ sơ" là
một khẳng định **mạnh hơn hẳn** thứ repo kia đã chứng minh. Quyết định này lấy phần đã được chứng
minh (code có logic thì test trước), không lấy phần suy rộng.

## Các phương án đã cân nhắc

**A. Giữ nguyên "khuyến nghị".** Không mâu thuẫn gì, chi phí bằng 0. Bỏ vì nó tương đương không có
luật: không chỗ nào trong quy trình hỏi tới nó.

**B. Chép nguyên bản cứng tuyệt đối của `Claude-Agents`** ("không code sản xuất nào trước khi có
test đỏ", ngoại lệ phải *hỏi người trước*). Bỏ vì ba lý do: (1) mâu thuẫn trực diện với lý luận
"nghi thức rỗng" đã viết trong khung, mà lý luận đó đúng; (2) khung phục vụ 10 hồ sơ, không phải một
repo Python; (3) nó đi kèm `fail_under = 100` dòng+nhánh — **không** chép phần đó thì bản cứng mất
một nửa cơ chế, mà chép thì áp một ngưỡng coverage lên mọi dự án đích, một quyết định lớn hơn nữa và
không thuộc phạm vi ADR này.

**C. Bắt buộc theo hồ sơ dự án** (cứng cho C4 backend/C9 blockchain, khuyến nghị cho C5 site tĩnh…).
Bỏ vì nó đẩy một phán đoán khó xuống người đọc đúng lúc họ đang muốn né luật, và vì ranh giới thật
không nằm ở *loại dự án* mà ở *đoạn code có logic hay không* — một site tĩnh vẫn có hàm tính giá.

**D. Thêm cổng máy cưỡng chế** (CI đòi bằng chứng test đỏ). Bỏ **trong ADR này**: repo khung không có
test runner (cố ý, ADR-0004), và ở dự án đích thì "test này từng đỏ" không đọc được từ trạng thái
cuối của repo — cưỡng chế nó cần đổi quy trình commit (vd bắt hai commit test→code), một thay đổi
riêng. Ghi vào "Việc cần làm tiếp theo" thay vì giả vờ đã giải quyết.

## Hệ quả

**Tích cực**
- Code mới có logic mà không có test giờ là **vi phạm luật**, không còn là lựa chọn phong cách.
- Mỗi lần bỏ qua để lại **một dòng trong PR** — người review thấy được, người sau đọc lại được.
- Ngoại lệ đóng, nên "quá đơn giản nên khỏi test" không còn là đường thoát hợp lệ.

**Đánh đổi / rủi ro phải chấp nhận**
- **Không có cổng máy.** Đây là luật cho người và AI đọc, cưỡng chế bằng review — cùng hạng với
  `CLAUDE.md` §9 hay luật "chủ động góp ý". Nói thẳng ở đây để không ai tưởng có cổng canh.
- Ranh giới "có nhánh điều kiện / tính toán" vẫn cần chút phán đoán ở ca biên. Chọn ranh giới này vì
  nó nằm ở **đoạn code**, quan sát được trong diff, thay vì ở ý định của người viết.
- Dự án đích đã copy khung bản cũ **không tự động nhận** luật mới (`CLAUDE.md` là `copy_if_absent`);
  họ nhận ở lần copy kế hoặc phải tự merge. Đây là đánh đổi có sẵn của cơ chế copy, không phải của
  ADR này.

**Điểm chạm trong quy trình** (làm ngay trong PR này — nếu không, luật mới lại thành "khuyến nghị"
trá hình, đúng lỗi mà ADR này chỉ ra ở phương án A):
- `CLAUDE.md` §5 (cổng commit) và §7 (khuôn Báo cáo xác thực) có dòng
  `Đỏ-trước cho code mới có logic ✅/❌/ngoại lệ-N`.
- `.claude/commands/gate.md` Bước 3 soi mục này song song với mục `fix:`, và nêu thẳng ba câu biện
  hộ không được tính là ngoại lệ.

**Việc cần làm tiếp theo**
- Cân nhắc một mục tương ứng trong **PR template của dự án đích** — chưa làm để giữ phạm vi; mở
  riêng nếu luật này tỏ ra bị bỏ qua.
- Phương án D (cổng máy) để mở: xem lại khi có dữ liệu cho thấy luật bị né thật, không làm trước.
- **Không** kèm ngưỡng coverage. Nếu muốn siết coverage thì đó là ADR riêng, và
  `quality-supplements-group2.md` §"Sổ trần cho LỐI THOÁT khỏi cổng coverage" là chỗ bắt đầu.
