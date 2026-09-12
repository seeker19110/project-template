// lib/order-summary.golden.test.ts — golden test VÍ DỤ chạy được (quality-supplements.md
// Nhóm 2 mục 6). Đầu ra vào __golden__/order-summary.golden.test.ts.snap (resolveSnapshotPath
// trong vitest.config.mts). Đổi golden test này → làm theo
// docs/framework/templates/GOLDEN-TEST.template.md, KHÔNG `-u` phản xạ.

import { describe, it, expect } from 'vitest';
import { buildOrderSummary } from './order-summary';

describe('buildOrderSummary (golden)', () => {
  it('sắp theo tên, tổng đúng, đầu ra tất định', () => {
    const summary = buildOrderSummary([
      { name: 'Bánh mì', qty: 2, unitCents: 15000 },
      { name: 'Cà phê', qty: 1, unitCents: 25000 },
      { name: 'Áo thun', qty: 3, unitCents: 12000 },
    ]);
    expect(summary).toMatchSnapshot();
  });

  it('mảng rỗng → chỉ có dòng tổng 0.00 (ca biên)', () => {
    expect(buildOrderSummary([])).toMatchSnapshot();
  });
});
