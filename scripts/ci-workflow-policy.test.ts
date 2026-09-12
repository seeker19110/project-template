// scripts/ci-workflow-policy.test.ts — bản VITEST của scripts/check-ci-policy.sh, cho DỰ ÁN ĐÍCH
// (repo khung không có package.json nên không chạy được vitest — xem CODEMAP.md của khung).
//
// VÌ SAO CẦN (docs/specs/2026-09-12-traps-codemap-ci-policy.md, lỗ hổng C): `ci.yml` có nhiều job
// PHẲNG, không `needs:` — không có job tổng hợp để gom, nên branch protection trên GitHub phải
// liệt kê ĐÚNG TÊN từng job. Đổi tên/xoá một job id mà quên cập nhật danh sách required checks thì
// hỏng theo kiểu IM LẶNG: workflow vẫn chạy, vẫn xanh, nhưng required check cũ không bao giờ báo
// cáo nữa (PR kẹt vĩnh viễn) hoặc job mới không được tính vào cổng bắt buộc (đỏ vẫn merge được).
//
// CỐ Ý chỉ kiểm CẤU TRÚC (job id có khớp danh sách khai báo không), KHÔNG kiểm nội dung từng bước —
// ép nội dung sẽ biến test thành vật cản mỗi lần thêm một bước kiểm mới.
//
// LƯU Ý cho dự án đích đã tự thêm job tổng hợp (`quality`/`e2e` có `needs:`, chia mảnh E2E…):
// đó là quy ước RIÊNG của dự án, không phải bất biến của khung — thêm test riêng cho quy ước đó,
// đừng sửa file này để giả định một cấu trúc mà khung không áp đặt.

import { describe, it, expect } from 'vitest'
import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

const ROOT = process.cwd()
const WORKFLOW_FILES = ['ci.yml', 'pr-policy.yml']
const SETTINGS_FILE = join(ROOT, 'docs', 'ops', 'repository-settings.md')

// Tự tách khối job thay vì kéo thêm một thư viện YAML: chỉ cần biết id job (thụt lề 2 khoảng,
// đúng chuẩn Prettier giữ cho *.yml), không cần phần thân.
function parseJobIds(yml: string): string[] {
  const lines = yml.split('\n')
  const start = lines.findIndex((l) => l === 'jobs:')
  if (start === -1) return []
  const ids: string[] = []
  for (const line of lines.slice(start + 1)) {
    const header = /^ {2}([A-Za-z0-9_-]+):/.exec(line)
    if (header?.[1]) ids.push(header[1])
    else if (/^[A-Za-z]/.test(line)) break // về lại cột 0 → hết khối jobs
  }
  return ids
}

// Khối fenced code block ĐẦU TIÊN trong repository-settings.md, dạng "workflow.yml: job-id" mỗi dòng.
function parseDeclaredJobs(md: string): Set<string> {
  const lines = md.split('\n')
  const declared = new Set<string>()
  let inBlock = false
  for (const line of lines) {
    if (line.trim() === '```') {
      if (!inBlock) {
        inBlock = true
        continue
      } else break
    }
    if (inBlock) {
      const m = /^([a-zA-Z0-9_.-]+\.yml):\s*([A-Za-z0-9_-]+)\s*$/.exec(line)
      if (m) declared.add(`${m[1]}:${m[2]}`)
    }
  }
  return declared
}

describe('required checks — .github/workflows/{ci,pr-policy}.yml ↔ docs/ops/repository-settings.md', () => {
  it('docs/ops/repository-settings.md tồn tại và có khối required checks', () => {
    expect(existsSync(SETTINGS_FILE), 'thiếu docs/ops/repository-settings.md — copy lại khung').toBe(
      true
    )
  })

  const settingsMd = existsSync(SETTINGS_FILE) ? readFileSync(SETTINGS_FILE, 'utf-8') : ''
  const declared = parseDeclaredJobs(settingsMd)

  it('đọc được ít nhất một job khai báo trong khối required checks', () => {
    expect(declared.size).toBeGreaterThan(0)
  })

  for (const wf of WORKFLOW_FILES) {
    const file = join(ROOT, '.github', 'workflows', wf)
    if (!existsSync(file)) continue // dự án đích có thể không dùng pr-policy.yml

    const actualIds = parseJobIds(readFileSync(file, 'utf-8'))

    it(`${wf}: tách được job (tự bảo vệ khỏi test rỗng luôn xanh)`, () => {
      expect(actualIds.length).toBeGreaterThan(0)
    })

    it.each(actualIds)(`${wf}: job \`%s\` phải được khai trong repository-settings.md`, (id) => {
      expect(
        declared.has(`${wf}:${id}`),
        `Job '${wf}:${id}' có thật trong workflow nhưng chưa khai trong docs/ops/repository-settings.md`
      ).toBe(true)
    })

    it(`${wf}: mọi job khai báo cho ${wf} phải còn tồn tại thật`, () => {
      const declaredForThisFile = [...declared]
        .filter((k) => k.startsWith(`${wf}:`))
        .map((k) => k.slice(wf.length + 1))
      const dead = declaredForThisFile.filter((id) => !actualIds.includes(id))
      // Báo thẳng tên job đã chết — branch protection đang canh một tên không còn báo cáo nữa.
      expect(dead, `Job đã khai nhưng không còn tồn tại trong ${wf}`).toEqual([])
    })
  }
})
