# Kiến trúc điều phối 3 tầng

> Mô hình vận hành tự động của khung: tách bạch **NGHĨ** (lập kế hoạch) — **CHẠY** (điều phối) —
> **LÀM** (thực thi), định tuyến worker theo 2 trục *độ phức tạp × độ kín đặc tả*.
> Đây là bản mở rộng của `models-and-automation.md`: opusplan vẫn là nền, 3 tầng là cách tổ chức
> khi một thay đổi đủ lớn để cần điều phối nhiều worker song song.

## Sơ đồ tổng thể

```
TẦNG 1 — NGƯỜI LẬP KẾ HOẠCH  (phiên chính · opusplan/Fable 5) — phần "NGHĨ"
   Hiểu yêu cầu → thiếu đặc tả thì HỎI (AskUserQuestion) → viết đặc tả chi tiết
   (schema DDL, API, điểm chạm code, tiêu chí chấp nhận) → gắn nhãn `route:` từng việc
   → xuất PLAN.md → (cuối) DUYỆT kết quả.  KHÔNG tự code, KHÔNG babysit worker.
                                  │  PLAN.md (đã người dùng duyệt)
                                  ▼
TẦNG 2 — NGƯỜI ĐIỀU PHỐI  (coordinator · Opus · low) — phần "CHẠY"
   Nhận NGUYÊN VĂN PLAN.md → git fetch đồng bộ → tạo nhánh/worktree từng việc
   → dispatch theo `route:` → nghiệm thu (tiêu chí chấp nhận) → gọi reviewer soát diff
   → tích hợp (số migration, rebase) → báo cáo tổng hợp về Tầng 1.
   CỨNG: không đổi kế hoạch/đặc tả · không tự code · không merge.
                                  │  dispatch theo nhãn
                                  ▼
TẦNG 3 — WORKERS  (định tuyến 2 trục: độ phức tạp × độ kín đặc tả)
   route:complex     → complex-implementer  (Opus · high)
   route:spec        → spec-executor        (Opus · low)
   route:standard    → standard-worker      (Sonnet · medium)  [kế thừa coder cũ]
   route:mechanical  → mechanical-worker    (Haiku)            [kế thừa mechanical cũ]

   reviewer (Sonnet) — hậu kiểm bằng skill `code-review` sau khi worker xong,
   trước khi Tầng 1 duyệt cuối. KHÔNG nằm trong bảng route.
```

## Bảng định tuyến (2 trục)

| `route:` | Agent | Model · effort | Khi nào |
|---|---|---|---|
| `complex` | `complex-implementer` | Opus · high | Phức tạp, còn chỗ **tự quyết** trong ranh giới brief (thuật toán, cấu trúc dữ liệu, tổ chức module chưa chốt) |
| `spec` | `spec-executor` | Opus · low | Phức tạp nhưng **đặc tả kín** — chỉ thi hành, zero phán đoán |
| `standard` | `standard-worker` | Sonnet · medium | Việc **vừa**, có đặc tả cụ thể (test theo spec, boilerplate, cập nhật docs, sửa cơ học nhiều file) |
| `mechanical` | `mechanical-worker` | Haiku | **Cơ học** theo mẫu/thông báo, khép kín, gần như không phán đoán |

Hai trục quyết định nhãn:
- **Độ phức tạp** (cần chiều sâu lý luận?) → Opus vs Sonnet/Haiku.
- **Độ kín đặc tả** (còn chỗ tự quyết?) → effort cao (`complex`) vs effort thấp/chỉ-thi-hành (`spec`).

## Luật cứng theo tầng

**Tầng 1 (Người lập kế hoạch):**
- Thiếu đặc tả → **hỏi người dùng** bằng `AskUserQuestion`. **Không tự chế đặc tả**; **không** hạ nhãn xuống `complex` chỉ để né phải hỏi.
- Đặc tả phải đủ để Tầng 2/3 thi hành: schema DDL, chữ ký API, điểm chạm code (`path`), tiêu chí chấp nhận, và nhãn `route:` cho từng việc.
- Không tự code, không giám sát worker từng bước — chỉ duyệt kết quả cuối.

**Tầng 2 (Người điều phối):**
- Thi hành **đúng** PLAN.md: không đổi kế hoạch/đặc tả, không tự code, không merge.
- Worker vướng đặc tả → **dừng việc đó và báo lên** Tầng 1. Không tự vá spec, không route lại để né chỗ khó.
- FIFO/không nhảy cóc, đánh số migration tuần tự, rebase nhánh sau lên phần đã tích hợp.

**Tầng 3 (Workers):**
- Làm đúng phạm vi việc; gặp spec thiếu/mâu thuẫn/mơ hồ → **dừng, nêu rõ, trả lại** (không tự đoán).
- Không quyết định kiến trúc-cấp-dự-án, không chọn công nghệ, không đụng §9 (đẩy lên).
- Không commit/merge (do `/gate` điều phối). Chống ảo giác §4.

## Định dạng PLAN.md (Tầng 1 xuất, Tầng 2 đọc nguyên văn)

```markdown
# PLAN.md — <tên thay đổi>

## Bối cảnh & mục tiêu
<1–3 câu: vấn đề, kết quả mong muốn>

## Đặc tả dùng chung
- Schema/DDL: <bảng, cột, ràng buộc, index>
- API: <chữ ký endpoint/hàm, kiểu vào/ra, mã lỗi>
- Quy ước: <đặt tên, thư mục, migration>

## Danh sách việc
### T1 — <tên việc>   `route: standard`
- Điểm chạm: `<đường-dẫn-file-1>`, `<đường-dẫn-file-2>`
- Đặc tả: <cụ thể tới mức worker thi hành không phải đoán>
- Phụ thuộc: <none | T?>
- Tiêu chí chấp nhận: <kiểm được: test nào xanh, hành vi nào đúng>

### T2 — <tên việc>   `route: complex`
- ... (chừa rõ phần được tự quyết, nêu ranh giới)

## Thứ tự tích hợp & migration
<T1 → T2; ai đánh số migration; điểm rebase>

## Duyệt cuối (Tầng 1)
<những gì Tầng 1 sẽ kiểm khi nghiệm thu tổng>
```

## Ranh giới với phần còn lại của khung
- **Không thay** `PROJECT.md` (cái-gì), các cổng `/gate` (commit/merge), hay ADR (`/adr`). 3 tầng chỉ là **cách điều phối thực thi**.
- **opusplan** vẫn là model nền của phiên chính; 3 tầng dùng khi thay đổi đủ lớn để cần nhiều worker. Thay đổi nhỏ gọn trong một PR vẫn có thể làm thẳng ở pha-code opusplan + subagent như trước.
- Subagent read-only `lookup` (Haiku) và `version-check` (Haiku) vẫn phục vụ Tầng 1 ở bước research-first; chúng không nằm trong bảng route (chỉ tra cứu, không thực thi thay đổi).
