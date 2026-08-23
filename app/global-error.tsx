'use client';
// Bắt lỗi ở chính root layout (hiếm). Phải tự render <html>/<body>.
// NGOẠI LỆ CÓ CHỦ ĐÍCH với luật design token (CLAUDE.md §3.10): global-error render
// một cây <html> riêng khi root layout đã sập — stylesheet (styles/theme.css) có thể
// CHƯA/KHÔNG được nạp, nên các biến --token không tồn tại. Vì vậy màu ở đây được
// hard-code (khớp giá trị Dark blue của theme) để trang lỗi vẫn đọc được trong mọi
// tình huống. Đừng "sửa" lại thành token.
import { useEffect } from 'react';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <html lang="vi" data-theme="dark">
      <body
        style={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '1rem',
          padding: '1.5rem',
          textAlign: 'center',
          background: '#0b1220',
          color: '#e8eef8',
          fontFamily: 'system-ui, sans-serif',
        }}
      >
        <h1 style={{ fontSize: '1.5rem', fontWeight: 600 }}>Đã có lỗi nghiêm trọng</h1>
        <p>Vui lòng tải lại trang.</p>
        <button
          type="button"
          onClick={reset}
          style={{
            background: '#5b9dff',
            color: '#06101f',
            border: 'none',
            borderRadius: '0.5rem',
            padding: '0.5rem 1rem',
            fontWeight: 500,
            cursor: 'pointer',
          }}
        >
          Thử lại
        </button>
      </body>
    </html>
  );
}
