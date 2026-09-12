import { configDefaults, defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './vitest.setup.ts',
    // Loại E2E (Playwright) khỏi Vitest — hai bộ chạy riêng.
    // Spread configDefaults.exclude để GIỮ các mẫu mặc định (node_modules, dist...)
    // thay vì ghi đè mất chúng.
    exclude: [...configDefaults.exclude, 'e2e/**', '.next/**'],
    // Golden/snapshot test (quality-supplements.md Nhóm 2 mục 6, mục b): đưa mọi snapshot
    // (`toMatchSnapshot`/`toMatchFileSnapshot`) vào `__golden__/` cạnh file test — nhất quán với
    // quy ước lưu fixture của khung, thay vì thư mục `__snapshots__/` mặc định của Vitest.
    resolveSnapshotPath: (testPath, snapExtension) =>
      path.join(path.dirname(testPath), '__golden__', `${path.basename(testPath)}${snapExtension}`),
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      // Sàn an toàn tối thiểu (KHÔNG phải mục tiêu) — bắt việc "quên viết test".
      // Ưu tiên chất lượng test ở đường đi quan trọng + ca biên hơn con số %.
      thresholds: { lines: 70, functions: 70, branches: 70, statements: 70 },
      exclude: ['e2e/**', '**/*.config.*', '**/*.d.ts', 'vitest.setup.ts'],
    },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './') },
  },
});
