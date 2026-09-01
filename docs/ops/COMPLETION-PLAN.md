# COMPLETION-PLAN — Kế hoạch hoàn thiện (repo khung project-template)

> AI đọc/ghi file này để biết làm tới đâu — resume qua nhiều phiên.
> Trạng thái việc: ⬜ chưa làm · 🔄 đang làm · ✅ xong (kèm bằng chứng) · ➖ hủy (kèm lý do).

- Ngày lập: 2026-08-23  ·  Duyệt bởi người dùng: **ĐÃ DUYỆT 2026-08-23** ("duyệt kế hoạch, thực thi cả 4 đợt")
- Nguồn phát hiện: audit 3 nhánh ngày 2026-08-23 (tài liệu/quản trị · drop-ins & config · CI/CD & scripts).
  Danh mục phát hiện F-xxx ở cuối file. Lưu ý hồ sơ: đây là **repo khung/template** — "sản phẩm" là bộ
  tài liệu + drop-ins + scripts + CI, KHÔNG phải app chạy được (`package.json` vắng mặt là CHỦ ĐÍCH,
  đã xác minh tại `scripts/verify-dropins.sh:5-8` và `ci.yml`); DoC được chỉnh theo hồ sơ đó.

## Definition of Complete (đã duyệt 2026-08-23 — nghiệm thu ở cuối file)
- [x] 0 phát hiện mức **Cao** còn mở; mọi phát hiện Vừa/Thấp có kết cục ghi nhận (sửa / dời / chấp nhận rủi ro).
- [x] `verify-dropins.sh` PASS **bao gồm cả e2e mẫu** sau khi copy (dropins đầy đủ, dự án đích không mất file nào cấu hình tham chiếu tới).
- [x] `check-docs-consistency.sh` PASS + CLAUDE.md phản ánh đủ mọi tài liệu luật hiện có (standard-delivery, orchestration, docs/ops mới).
- [x] CI: mọi action ghim SHA, quyền tối thiểu theo job, PR từ fork không đỏ oan.
- [x] Chuẩn OSS đủ bộ: CODE_OF_CONDUCT, issue template không trùng lặp, CODEOWNERS cover `.claude/`.
- [x] `PROGRESS.md` đúng hiện trạng, theo cấu trúc `PROGRESS.template.md`.

## Đợt 1 — Đóng phát hiện CAO: tính toàn vẹn drop-ins (✅ xong)
| ID | Từ phát hiện | Việc | Tiêu chí nghiệm thu | Phụ thuộc | Ước lượng | Trạng thái | PR / bằng chứng |
|----|--------------|------|---------------------|-----------|-----------|-----------|-----------------|
| W-101 | F-001 | Thêm `e2e/` vào danh sách copy của `copy-framework.sh` + `.ps1` | `test-copy-framework.sh` PASS; dự án đích có `e2e/smoke.spec.ts` | – | S | ✅ | |
| W-102 | F-002 | Copy (dạng dropin, không đè) `.gitignore` + `.gitattributes` sang dự án đích | test copy PASS; dự án đích giữ luật `*.sh eol=lf` | W-101 | S | ✅ | |
| W-103 | F-101, F-102 | CLAUDE.md §1 bổ sung `standard-delivery.md`, `orchestration-3-tier.md`, 3 file docs/ops mới; đưa luật Feature gate `docs/specs/*` + Goal loop vào CLAUDE.md (đồng bộ AGENTS.md) | `check-docs-consistency.sh` PASS; không còn luật chỉ có ở AGENTS.md | – | M | ✅ | |
| W-104 | F-303 | Tạo `docs/specs/` (.gitkeep + mẫu spec) để cổng `pr-policy.yml` không chặn oan feat PR đầu tiên | feat PR mẫu qua được pr-policy | W-103 | S | ✅ | |

## Đợt 2 — Bảo mật CI/CD & supply-chain (✅ xong)
| ID | Từ phát hiện | Việc | Tiêu chí nghiệm thu | Phụ thuộc | Ước lượng | Trạng thái | PR / bằng chứng |
|----|--------------|------|---------------------|-----------|-----------|-----------|-----------------|
| W-201 | F-301, F-302, F-312 | Ghim toàn bộ actions theo full SHA (+ comment version), đồng bộ phiên bản checkout/setup-node giữa các workflow | mọi `uses:` dạng `@<sha> # vX`; CI xanh | – | M | ✅ | |
| W-202 | F-304 | Hạ `permissions` của `release.yml` xuống cấp job | job `check` chỉ còn read | – | S | ✅ | |
| W-203 | F-305, F-308 | Sửa `pre-commit-gate.sh`: thiếu jq → exit 0; regex bypass chỉ nhận `--no-verify` | test thủ công 3 ca (có jq/không jq/bypass) ghi vào PR | – | S | ✅ | |
| W-204 | F-306, F-311 | CODEOWNERS thêm `/.claude/`; thống nhất quy ước placeholder chủ repo | file cập nhật; check-docs PASS | – | S | ✅ | |
| W-205 | F-307 | CI: fallback env giả cho build trên PR fork (không lộ secret, không đỏ oan) | build job xanh khi secrets rỗng | W-201 | S | ✅ | |

## Đợt 3 — Chất lượng drop-ins & config (✅ xong)
| ID | Từ phát hiện | Việc | Tiêu chí nghiệm thu | Phụ thuộc | Ước lượng | Trạng thái | PR / bằng chứng |
|----|--------------|------|---------------------|-----------|-----------|-----------|-----------------|
| W-301 | F-004 | Cập nhật `lib/env.ts` sang API Zod 4 (`z.url()`, `z.treeifyError`) | `verify-dropins.sh` PASS trên zod mới | – | S | ✅ | |
| W-302 | F-003 | Kèm `next.config.ts` mẫu nối `@serwist/next` (hoặc ghi chú tiền điều kiện rõ trong dropin `app/sw.ts`) | verify-dropins PASS không cần cài tay | – | M | ✅ | |
| W-303 | F-007, F-315 | Playwright/LHCI: build trước start; đổi `vitest.config.ts` → `.mts` (hết cảnh báo ESM) | verify-dropins log sạch cảnh báo | – | S | ✅ | |
| W-304 | F-008, F-016 | Bổ sung `.prettierignore`; vitest exclude dùng `configDefaults` | format/test đúng phạm vi | – | S | ✅ | |
| W-305 | F-009, F-013, F-012 | `i18n/request.ts` bỏ ép kiểu (type guard); `theme-toggle` dùng next-intl (+ key vi/en); comment ngoại lệ hard-code màu ở `global-error.tsx` | lint/type PASS; key i18n khớp 2 ngôn ngữ | – | S | ✅ | |
| W-306 | F-019, F-005 | Migration mẫu idempotent (`drop trigger if exists`); cân nhắc `.nvmrc`/CI → Node 24 LTS (một ADR nhỏ nếu đổi) | verify-dropins PASS; 2 nơi Node đồng bộ | – | S | ✅ | |
| W-307 | F-017 | LHCI đảo preset sang mobile (khớp luật mobile-first §3.9) | lighthouserc.json cập nhật + ghi chú | – | S | ✅ | |

## Đợt 4 — Quản trị OSS & tài liệu đồng bộ (✅ xong)
| ID | Từ phát hiện | Việc | Tiêu chí nghiệm thu | Phụ thuộc | Ước lượng | Trạng thái | PR / bằng chứng |
|----|--------------|------|---------------------|-----------|-----------|-----------|-----------------|
| W-401 | F-114 | Thêm `CODE_OF_CONDUCT.md` (Contributor Covenant, tiếng Việt) | file tồn tại, README trỏ tới | – | S | ✅ | |
| W-402 | F-116 | Xóa cặp issue template `.md` cũ, thống nhất label với form `.yml` | chỉ còn 1 bộ template | – | S | ✅ | |
| W-403 | F-103 | Dịch CONTRIBUTING.md sang tiếng Việt (nhất quán toàn repo) | file tiếng Việt, nội dung không đổi nghĩa | – | S | ✅ | |
| W-404 | F-111, F-112, F-113, F-107 | Làm mới PROGRESS.md theo template (nén nhật ký, cập nhật mốc #44–46, xóa bàn giao ôi); CLAUDE.md §10 "Giai đoạn hiện tại" trỏ PROGRESS.md | PROGRESS đúng cấu trúc + hiện trạng | – | S | ✅ | |
| W-405 | F-109, F-117, F-115 | Sửa placeholder lọt trong README (mô tả ci.yml); CHANGELOG ghi chú đúng release-please; sinh SUPPORT/GOVERNANCE thật từ template | check-docs PASS; không còn `[ĐIỀN]` sai chỗ | – | S | ✅ | |
| W-406 | F-310, F-313 | CI cài shellcheck tường minh; verify-dropins schedule fail → tự mở issue | 2 workflow cập nhật, chạy xanh | W-201 | S | ✅ | |

## Nhật ký hội tụ (Pha 4)
| Ngày | Phạm vi quét lại | Kết quả (phát hiện mới? đóng được gì?) |
|------|------------------|----------------------------------------|
| 2026-08-23 | Tài liệu (`check-docs-consistency.sh`) + copy khung (`test-copy-framework.sh`) + cú pháp shell + YAML workflow | PASS toàn bộ; không phát hiện mới. |
| 2026-08-23 | Quyền workflow sau khi thêm bước mở issue | **Phát hiện MỚI (Vừa) F-021:** `verify-dropins.yml` chỉ có `contents: read` → bước mở issue sẽ 403; đã thêm `issues: write` ở cấp job. |
| 2026-08-23 | Drop-ins dựng thật (`verify-dropins.sh`) sau Đợt 3 | **Phát hiện MỚI (Cao) F-020:** `next.config.ts` mẫu nối `@serwist/next` (webpack) làm `next build` của Next 16 (Turbopack mặc định) ĐỎ → đã sửa: next.config.ts ghi rõ phải chạy `--webpack`, `verify-dropins.sh` dùng `next build --webpack`. Quét lại `verify-dropins.sh` sau khi sửa: **EXIT=0** — "dropins của hồ sơ Web app lint/biên dịch/build/test sạch trên Next.js mới nhất" (Serwist bundle `/sw.js` thành công, TypeScript 3.5s, 7/7 trang tĩnh). |

## Phát hiện chấp nhận rủi ro / dời đợt sau (phải có lý do)
- F-011 (`--theme-transition` dead token), F-014 (usage-guard số thập phân), F-309 (`dev-task.sh` fallback grep): mức Thấp,
  ảnh hưởng không đáng kể — **CHẤP NHẬN RỦI RO, người dùng đã xác nhận 2026-09-01.** Không sửa, không dời.
- F-006 (`dev-task.sh` eval `project-commands.sh`): escape-hatch có chủ đích; giảm nhẹ bằng W-204 (CODEOWNERS cover `.claude/`).

## Danh mục phát hiện (F-xxx)
**Nhánh drop-ins & config** — F-001 thiếu `e2e/` trong copy-framework (Cao) · F-002 không copy `.gitignore`/`.gitattributes` (Cao) · F-003 `app/sw.ts` thiếu next.config mẫu (Vừa) · F-004 Zod 4 API deprecated trong `lib/env.ts` (Vừa) · F-005 Node 22 vs 24 LTS (Vừa) · F-007 Playwright/LHCI không build trước start (Vừa) · F-008 `.prettierignore` thiếu mục (Vừa) · F-009 ép kiểu `as Locale` (Vừa) · F-011 dead token theme (Thấp) · F-012 hard-code màu global-error thiếu comment ngoại lệ (Thấp) · F-013 theme-toggle không dùng i18n (Thấp) · F-016 vitest exclude ghi đè default (Thấp) · F-017 LHCI preset desktop (Thấp) · F-019 migration không idempotent (Thấp).
**Nhánh tài liệu/quản trị** — F-101 CLAUDE.md thiếu standard-delivery + docs mới (Cao) · F-102 luật Feature gate/Goal loop chỉ ở AGENTS.md (Cao) · F-103 CONTRIBUTING tiếng Anh (Vừa) · F-107 §10 "Giai đoạn hiện tại" mâu thuẫn PROGRESS (Vừa) · F-109 placeholder lọt README (Thấp) · F-111 bàn giao PROGRESS ôi (Vừa) · F-112/F-113 PROGRESS thiếu mốc mới + sai template (Thấp) · F-114 thiếu CODE_OF_CONDUCT (Vừa) · F-115 thiếu SUPPORT/GOVERNANCE thật (Thấp) · F-116 issue template trùng lặp (Vừa) · F-117 CHANGELOG ghi chú sai công cụ (Thấp).
**Nhánh CI/scripts** — F-301 actions không ghim SHA (Vừa) · F-302 phiên bản action lệch nhau (Vừa) · F-303 pr-policy đòi `docs/specs/` không tồn tại (Vừa) · F-304 release.yml quyền write cấp workflow (Vừa) · F-305 pre-commit-gate fallback thiếu jq (Vừa) · F-306 CODEOWNERS thiếu `.claude/` (Vừa) · F-307 PR fork thiếu secrets đỏ oan (Vừa) · F-308 regex bypass lỏng (Thấp) · F-309 dev-task fallback grep (Thấp) · F-310 shellcheck không cài tường minh (Thấp) · F-311 placeholder CODEOWNERS (Thấp) · F-312 gitleaks unpinned (Thấp) · F-313 schedule fail không báo (Thấp) · F-315 cảnh báo ESM vitest.config (Thấp).

## Nghiệm thu (Pha 4 — 2026-08-23)

Bằng chứng chạy thật trên nhánh `claude/software-dev-standards-jc776c`:

| Cổng | Kết quả |
|------|---------|
| `scripts/check-docs-consistency.sh` | ✅ PASS — không link gãy / tên cũ / lệnh lệch |
| `scripts/test-copy-framework.sh` | ✅ PASS — 3 kịch bản (đích trống · không đè · chạy lại lần 2) |
| `scripts/verify-dropins.sh` | ✅ EXIT=0 — dựng Next.js mới nhất từ dropins, lint + type-check + build + test sạch |
| `bash -n` mọi `*.sh` + hook | ✅ PASS |
| YAML mọi workflow (`yaml.safe_load`) | ✅ hợp lệ |

**Kết luận:** 22/22 việc (W-101…W-406) ✅; 2 phát hiện Cao/Vừa MỚI sinh trong lúc sửa (F-020 Turbopack,
F-021 quyền issue) đã đóng ngay trong đợt; 0 phát hiện Cao còn mở. Các mục Thấp F-011, F-014, F-309
ở trạng thái **chấp nhận rủi ro — người dùng đã xác nhận 2026-09-01.**

**KẾ HOẠCH ĐÃ ĐÓNG (2026-09-01).** Definition of Complete đạt đủ 6/6 mục. Không còn việc mở.
