// lib/order-summary.ts — ví dụ hàm THUẦN cho golden test (quality-supplements.md Nhóm 2 mục 6).
// Sinh một bản tóm tắt đơn hàng dạng văn bản, đầu ra TẤT ĐỊNH: sắp theo tên, tiền dùng số nguyên
// cents (không float — CLAUDE.md §3 mục "Số & tiền"), không timestamp/id ngẫu nhiên.

export interface OrderLine {
  name: string;
  qty: number;
  unitCents: number;
}

export function buildOrderSummary(lines: OrderLine[]): string {
  const sorted = [...lines].sort((a, b) => a.name.localeCompare(b.name));
  const rows = sorted.map((l) => {
    const totalCents = l.qty * l.unitCents;
    return `${l.name.padEnd(20)} x${l.qty}  ${(totalCents / 100).toFixed(2)}`;
  });
  const grandTotalCents = sorted.reduce((sum, l) => sum + l.qty * l.unitCents, 0);
  return [...rows, '-'.repeat(30), `TỔNG${' '.repeat(21)}${(grandTotalCents / 100).toFixed(2)}`].join(
    '\n',
  );
}
