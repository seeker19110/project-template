/// <reference lib="webworker" />
// Service worker cho PWA/offline (Serwist). Được build qua @serwist/next — xem file mẫu
// `next.config.ts` ở gốc repo (dropin, kèm tiền điều kiện `npm i @serwist/next serwist`).
// LƯU Ý: Serwist chưa hỗ trợ Turbopack — chạy dev PWA bằng `next dev --webpack`.
// Dòng `reference lib="webworker"` ở trên là BẮT BUỘC: tsconfig của Next chỉ nạp lib DOM,
// nên `ServiceWorkerGlobalScope` không tồn tại và `tsc --noEmit` sẽ đỏ (TS2552). Khai theo
// từng-file thay vì thêm "webworker" vào `lib` toàn cục để không trộn kiểu DOM/Worker ở
// phần còn lại của app.
import { defaultCache } from '@serwist/next/worker';
import type { PrecacheEntry, SerwistGlobalConfig } from 'serwist';
import { Serwist } from 'serwist';

declare global {
  interface WorkerGlobalScope extends SerwistGlobalConfig {
    __SW_MANIFEST: (PrecacheEntry | string)[] | undefined;
  }
}

declare const self: ServiceWorkerGlobalScope;

const serwist = new Serwist({
  precacheEntries: self.__SW_MANIFEST,
  skipWaiting: true,
  clientsClaim: true,
  navigationPreload: true,
  runtimeCaching: defaultCache,
});

serwist.addEventListeners();
