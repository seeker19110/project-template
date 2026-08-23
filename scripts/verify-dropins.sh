#!/usr/bin/env bash
#
# verify-dropins.sh — Chứng minh rằng bộ dropins của hồ sơ Web app THẬT SỰ chạy được.
#
# Vấn đề nó giải: repo khung cố ý KHÔNG có package.json (nó là drop-in cho một dự án
# create-next-app), nên `app/*.tsx`, `lib/env.ts`, `components/*.tsx`, `e2e/*.ts`,
# `eslint.config.mjs`, `vitest.config.mts`... chưa từng được biên dịch hay lint lần nào.
# Khung đang phát cho người khác những file mà chính nó không chứng minh được là chạy.
#
# Kịch bản: dựng một dự án Next.js sạch trong thư mục tạm → chạy copy-framework.sh vào đó
# → merge _framework-dropins/ → làm đúng Phần D của new-project-runbook.md (cài gói, thêm
# scripts, bật cờ TS strict) → chạy lint/type-check/build/test thật.
#
# Đây cũng là CẢM BIẾN VERSION DRIFT: khi Next/ESLint/Tailwind ra bản mới làm dropins gãy,
# job này đỏ TRƯỚC khi người dùng gặp lỗi.
#
# Dùng:  bash scripts/verify-dropins.sh [thư-mục-làm-việc]
# Cần:   mạng (npm), Node 22+. Chạy vài phút.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

WORKDIR="${1:-$(mktemp -d)}"
mkdir -p "$WORKDIR"
APP="$WORKDIR/app-duoi-thu"

echo "Khung nguồn: $SRC"
echo "Thư mục thử: $APP"
echo ""

# ── 1. Dự án Next.js sạch (đúng như runbook Bước 3: TypeScript + Tailwind + ESLint) ──
echo "== 1/6 create-next-app =="
rm -rf "$APP"
npx --yes create-next-app@latest "$APP" \
  --ts --tailwind --eslint --app --no-src-dir --turbopack \
  --import-alias '@/*' --use-npm --yes

# create-next-app tự `git init`; giữ nguyên để copy-framework.sh không cảnh báo.

# ── 2. Mang khung sang (đúng đường người dùng thật đi) ──
echo ""
echo "== 2/6 copy-framework.sh =="
bash "$SRC/copy-framework.sh" "$APP"

# ── 3. Merge _framework-dropins/ ──
# Ở đây merge TOÀN BỘ (không chọn lọc như hướng dẫn brownfield) vì dự án thử này đúng
# bằng hồ sơ Web app mặc định — mục đích là kiểm chính những file đó.
echo ""
echo "== 3/6 merge _framework-dropins/ =="
if [ -d "$APP/_framework-dropins" ]; then
  cp -R "$APP/_framework-dropins/." "$APP/"
  rm -rf "$APP/_framework-dropins"
  echo "  đã merge và xóa _framework-dropins/"
fi
# Bản .framework-new chỉ là bản để người dùng tự so — không tham gia build.
find "$APP" -name '*.framework-new' -prune -exec rm -rf {} + 2>/dev/null || true

# ── 4. Phần D của runbook: cài gói + scripts + cờ TS strict ──
echo ""
echo "== 4/6 Phần D — gói, scripts, tsconfig =="
cd "$APP"

# Phần D Bước 1. Gồm cả next-intl/serwist vì i18n/request.ts và app/sw.ts trong dropins
# import chúng — không có thì type-check không thể chạy (dropins tự quyết định phụ thuộc).
npm install --save-dev --no-audit --no-fund \
  prettier prettier-plugin-tailwindcss \
  husky lint-staged \
  @commitlint/cli @commitlint/config-conventional \
  vitest @vitejs/plugin-react jsdom \
  @testing-library/react @testing-library/jest-dom @vitest/coverage-v8 \
  @playwright/test @axe-core/playwright \
  @lhci/cli \
  serwist
npm install --no-audit --no-fund zod next-intl @serwist/next

# Phần D Bước 2 + Bước 5 — sửa package.json và tsconfig.json bằng Node (JSON hợp lệ,
# không sed mù). Ghi đè có chủ đích: đây là dự án dùng-một-lần.
node - <<'NODE'
const fs = require('fs');

const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = {
  ...pkg.scripts,
  dev: 'next dev',
  build: 'next build',
  start: 'next start',
  lint: 'eslint . --max-warnings 0',
  'lint:fix': 'eslint . --fix',
  'type-check': 'tsc --noEmit',
  format: 'prettier --write .',
  'format:check': 'prettier --check .',
  test: 'vitest run',
  'test:coverage': 'vitest run --coverage',
  'test:e2e': 'playwright test',
  lhci: 'lhci autorun',
};
// `prepare: husky` cần .husky đã init; job này không commit nên bỏ để npm ci không lỗi.
delete pkg.scripts.prepare;
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');

const ts = JSON.parse(fs.readFileSync('tsconfig.json', 'utf8'));
Object.assign(ts.compilerOptions, {
  strict: true,
  noUncheckedIndexedAccess: true,
  noImplicitReturns: true,
  noFallthroughCasesInSwitch: true,
  noUnusedLocals: true,
  noUnusedParameters: true,
  forceConsistentCasingInFileNames: true,
});
fs.writeFileSync('tsconfig.json', JSON.stringify(ts, null, 2) + '\n');

console.log('  package.json scripts + tsconfig strict: xong');
NODE

# lib/env.ts đọc biến môi trường lúc build → cấp giá trị giả để build không chết vì
# thiếu secret (giá trị thật đến từ GitHub Secrets ở dự án thật).
cat > .env.local <<'ENV'
NEXT_PUBLIC_SUPABASE_URL=https://example.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=verify-dropins-placeholder-anon-key
ENV

# ── 5. Định dạng trước khi kiểm ──
# Mục tiêu của script là dropins có BIÊN DỊCH/LINT được không, không phải scaffold của
# Next có hợp .prettierrc của khung không → format một lượt rồi mới check.
echo ""
echo "== 5/6 prettier =="
npm run format >/dev/null
npm run format:check

# ── 6. Cổng thật ──
echo ""
echo "== 6/6 lint · type-check · build · test =="
npm run lint
npm run type-check
npm run build
# --passWithNoTests: khung cố ý không kèm test mẫu (test là của dự án thật). Ở đây chỉ cần
# biết vitest.config.mts + vitest.setup.ts nạp được, không cần có ca test nào.
npx vitest run --passWithNoTests

echo ""
echo "OK — dropins của hồ sơ Web app lint/biên dịch/build/test sạch trên Next.js mới nhất."
