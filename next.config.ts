// next.config.ts — MẪU DROPIN nối @serwist/next (PWA/offline) vào Next.js.
//
// TIỀN ĐIỀU KIỆN (dự án đích phải cài trước khi build):
//   npm i @serwist/next serwist
//
// Đây là file MẪU của bộ khung: copy-framework chỉ chép sang dự án đích nếu ở đó
// CHƯA có next.config.* (không đè cấu hình sẵn có). Nếu dự án đã có next.config
// riêng, hãy tự bọc config bằng withSerwist như dưới đây.
//
// Cặp với `app/sw.ts` (mã nguồn service worker). LƯU Ý: Serwist chưa hỗ trợ
// Turbopack — chạy dev PWA bằng `next dev --webpack`.
import type { NextConfig } from 'next';
import withSerwistInit from '@serwist/next';

const withSerwist = withSerwistInit({
  swSrc: 'app/sw.ts', // nguồn service worker (TypeScript)
  swDest: 'public/sw.js', // file build ra — đã nằm trong .gitignore/.prettierignore
  disable: process.env.NODE_ENV === 'development', // tắt SW ở dev để khỏi cache dở dang
});

const nextConfig: NextConfig = {
  // Thêm cấu hình Next.js của dự án ở đây.
};

export default withSerwist(nextConfig);
