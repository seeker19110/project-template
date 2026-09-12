# ADR-0004: Gỡ scaffold Web (Next.js + Supabase) mặc định — không còn hồ sơ mặc định

- **Trạng thái:** Đã chấp nhận
- **Ngày:** 2026-09-12
- **Liên quan:** ADR-0001 (đảo ngược, KHÔNG sửa — xem dưới), `copy-framework.sh`/`.ps1`,
  `.github/workflows/ci.yml`, `README.md`, `CLAUDE.md` §0b, KHUNG-3 PHẦN C

## Bối cảnh

ADR-0001 (2026-06-29) chọn Next.js + Supabase + Vercel làm **stack tham chiếu mặc định**, đóng
gói sẵn ở gốc repo khung dưới dạng file thật (`app/`, `lib/`, `styles/`, `e2e/`, `i18n/`,
`messages/`, `components/`, `supabase/`, cấu hình ESLint/Prettier/Vitest/Playwright/Lighthouse,
`.husky/*`) — gọi là **"Lớp 2"** trong cơ chế `copy-framework.sh` (KHÔNG đè file dự án đích, đưa
vào `_framework-dropins/` để tự merge).

Mục 0b của `CLAUDE.md` nêu rõ khung **hỗ trợ mọi loại dự án** (web, mobile, desktop, backend/API,
CLI/thư viện, data/ML, game, blockchain, monorepo...), với hồ sơ công nghệ chọn theo
**research-first** (KHUNG-3 PHẦN A0 + PHẦN C, 10 hồ sơ C1–C10). Việc đóng gói cứng MỘT hồ sơ
(Web) làm "mặc định" trong chính repo khung mâu thuẫn với nguyên tắc đó: nó ngầm định "Web app"
là lựa chọn khởi điểm, dù `/consult` luôn phải research lại từ đầu cho ý tưởng cụ thể — scaffold
mặc định trở thành harness minh hoạ, không phải một phần phương pháp phổ quát.

## Quyết định

**Gỡ hẳn Lớp 2 (scaffold Web) khỏi repo khung.** Repo chỉ còn:

- **Lớp 1 — phương pháp phổ quát:** `docs/framework/`, `docs/ops/`, `.claude/commands/`,
  `CLAUDE.md`, `AGENTS.md`, script tự kiểm của khung (`check-docs-consistency.sh`,
  `check-ci-policy.sh`, `test-copy-framework.sh`, `test-hooks-gate.sh`, `dev-task.sh`,
  `usage-estimate.sh`), `copy-framework.sh`/`.ps1`.
- **Lớp 2 (định nghĩa lại) — CI/quy ước GitHub tổng quát, không đè file đích:**
  `.github/workflows/{ci,pr-policy,secret-scan,dependency-review,release,stale-pr-alert}.yml`,
  `.github/pull_request_template.md`, `.github/dependabot.yml`, `.github/ISSUE_TEMPLATE`,
  `.github/CODEOWNERS`, `.gitignore`, `.gitattributes` — vẫn **stage** vào
  `_framework-dropins/` vì có thể trùng tên với CI đã có ở dự án đích, nhưng không còn nội dung
  đặc thù một stack cụ thể (`ci.yml` chỉ còn 3 job tự kiểm của khung: `framework-lint`,
  `docs-consistency`, `copy-framework-smoke`, cộng job tổng hợp `gate`).

Xoá: `app/`, `lib/`, `styles/`, `e2e/`, `i18n/`, `messages/`, `components/`, `supabase/`,
`next.config.ts`, `playwright.config.ts`, `postcss.config.mjs`, `lighthouserc.json`,
`eslint.config.mjs`, `vitest.config.mts`, `vitest.setup.ts`, `commitlint.config.cjs`,
`.prettierrc`, `.prettierignore`, `.lintstagedrc.json`, `.husky/`, `.env.example`,
`.github/workflows/{codeql,lighthouse-ci,verify-dropins}.yml`, `scripts/verify-dropins.sh`.
Giữ `scripts/ci-workflow-policy.test.ts` (dropin CI-policy tổng quát cho dự án Node bất kỳ, không
đặc thù Web) và `.nvmrc` (ghim Node cho chính CI của khung — 3 job tự kiểm chạy trên `ubuntu-latest`,
không cần Node nhưng `.nvmrc` vẫn là quy ước neo phiên bản khi dự án đích dùng Node).

**KHÔNG sửa ADR-0001** (luật bất biến: không sửa ADR cũ) — nó vẫn đúng lịch sử tại thời điểm
2026-06-29. ADR này ghi quyết định **đảo ngược** kể từ 2026-09-12.

## Lý do

- Nhất quán với chính nguyên tắc "hỗ trợ mọi loại dự án, chọn công nghệ research-first" —
  không có hồ sơ nào xứng đáng là "mặc định" hơn hồ sơ khác.
- Giảm diện tích bảo trì của repo khung: trước đây mỗi lần Next.js/React/Supabase ra bản mới,
  khung phải tự cập nhật scaffold demo dù không ai dùng thẳng nó (mọi copy đều qua
  `_framework-dropins/` để tự merge, không ai chạy `npm install` ngay trên repo khung).
  `scripts/verify-dropins.sh` (149 dòng) + `.github/workflows/verify-dropins.yml` tồn tại chỉ để
  chứng minh scaffold này biên dịch được — gỡ scaffold thì gỡ luôn cơ chế minh chứng nó.
- `docs/framework/` (KHUNG-1/2/3) đã đủ để research-first chọn đúng stack cho **từng dự án cụ
  thể** — không cần một bản demo "ví dụ chạy được" mới dùng được phương pháp.

## Đánh đổi

- Mất ví dụ **chạy thật** minh hoạ golden test (`lib/order-summary.ts`), theme tokens
  (`styles/theme.css`), RLS mẫu (`supabase/migrations/`) — các mục này giờ chỉ còn ở dạng
  hướng dẫn/snippet trong `docs/framework/quality-supplements.md`, không còn file thật để
  chạy `npm test` ngay trong repo khung.
- Người mới quen thao tác trực quan hơn khi thấy code thật; giờ phải tự tưởng tượng qua ví dụ
  trong tài liệu.
- `case-study-greenfield-dry-run.md` mô tả một lượt dựng dự án Next.js thật từ khung — vẫn giữ
  nguyên làm tường thuật lịch sử (đã miễn trừ ở `check-docs-consistency.sh`), không còn phản ánh
  luồng "giải nén trực tiếp" nữa mà là luồng research-first → chọn Next.js → dựng từ đầu.

## Phương án đã loại

- **Giữ scaffold nhưng đổi label "tham khảo" thay vì "mặc định":** không giải quyết gốc rễ — vẫn
  là một stack được ưu ái hơn 9 hồ sơ còn lại về khối lượng tài liệu/ví dụ đi kèm.
- **Thêm scaffold cho MỌI hồ sơ (C1–C10):** chi phí bảo trì nhân 10, không khả thi cho một repo
  khung tự thân không chạy production.
