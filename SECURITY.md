# Chính sách bảo mật

Bảo mật là một trụ cột của bộ khung này (CLAUDE.md mục 3). Tài liệu này nói **cách báo cáo lỗ hổng**
và **các hàng rào bảo mật tự động** đang chạy.

## Báo cáo lỗ hổng

**Đừng** mở issue công khai cho lỗ hổng bảo mật. Thay vào đó:

- Dùng **GitHub Security Advisories**: tab **Security → Report a vulnerability** (private disclosure), hoặc
- Gửi email tới người bảo trì repo.

Vui lòng kèm: mô tả, bước tái hiện, ảnh hưởng dự kiến, và phiên bản/commit liên quan.
Mục tiêu phản hồi: xác nhận trong vòng **72 giờ**; thống nhất mốc vá trước khi công bố.

## Hàng rào bảo mật tự động trong repo

| Lớp | Công cụ | Bắt gì |
|-----|---------|--------|
| Bí mật | gitleaks (`.github/workflows/secret-scan.yml`) | API key/token/mật khẩu lỡ commit |
| Phụ thuộc | Dependabot (`.github/dependabot.yml`) | phiên bản action/thư viện có lỗ hổng đã biết |

Repo khung không đóng gói sẵn app nên không có sẵn phụ thuộc npm/mã nguồn để quét CodeQL/`npm audit`.
Ở **dự án đích** (đã chọn stack qua `/consult`), bổ sung tương ứng: SAST (vd CodeQL cho JS/TS, hoặc
công cụ tương đương ngôn ngữ khác), `npm audit`/công cụ quét phụ thuộc của stack đã chọn, validate
biến môi trường lúc khởi động (vd Zod cho Node), và kiểm soát truy cập dữ liệu (RLS/ACL) nếu có CSDL —
xem `CLAUDE.md` §3 mục 1–2 + `docs/framework/03-tech-selection-and-proactive-advice.md`.

## Nguyên tắc bất biến (không bao giờ phá)

- **Bí mật không bao giờ vào Git** — dùng biến môi trường (`.env*` đã bị `.gitignore` chặn).
- **Không tin client** — logic nhạy cảm (kiểm tra quyền, tính toán quan trọng) luôn ở server.
- Truy vấn **tham số hóa** (chống SQL injection); **escape** dữ liệu ra HTML (chống XSS).
- **RLS bật và đã test** trước khi mở cho người ngoài.
- Mọi đầu vào (người dùng/API/CSDL) **validate lúc chạy** trước khi dùng.
