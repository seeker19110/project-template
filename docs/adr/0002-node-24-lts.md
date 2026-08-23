# ADR-0002: Nâng Node.js lên 24 (Active LTS)

- **Trạng thái:** Đã chấp nhận
- **Ngày:** 2026-08-23
- **Liên quan:** `.nvmrc`, `.github/workflows/ci.yml` (F-005, W-306)

## Bối cảnh

Bộ khung đang ghim Node 22 trong `.nvmrc` và CI. Từ **10/2025**, Node **24** là dòng
**Active LTS** (Node 22 chuyển sang Maintenance). Khung research-first yêu cầu bám
phiên bản ổn định hiện hành.

## Quyết định

Dùng **Node 24 (Active LTS)** làm phiên bản chuẩn của khung: `.nvmrc` = `24`, và
CI (`ci.yml` `node-version`) phải đồng bộ cùng giá trị.

## Lý do

- Node 24 là Active LTS hiện hành: nhận tính năng + vá bảo mật dài hạn nhất.
- Next.js/tooling trong stack tham chiếu hỗ trợ đầy đủ Node 24.
- Đồng bộ một phiên bản duy nhất giữa `.nvmrc` và CI tránh lỗi "chạy được local, đỏ trên CI".

## Các phương án đã cân nhắc

- **Giữ Node 22:** vẫn được hỗ trợ (Maintenance) nhưng ngắn hạn hơn, đi ngược tinh thần research-first.
- **Node 25 (Current):** không phải LTS — không dùng cho nền dự án.

## Hệ quả

- Tích cực: vòng đời hỗ trợ dài, hiệu năng V8 mới hơn.
- Việc cần làm: cập nhật `node-version` trong `.github/workflows/ci.yml` sang `24` cho khớp `.nvmrc`.
- Đánh đổi: máy dev cần cài Node 24 (`nvm install`).
