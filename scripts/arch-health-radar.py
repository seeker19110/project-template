#!/usr/bin/env python3
"""
arch-health-radar.py — Autonomous Architectural Health & Tech Debt Radar Engine
Phân tích sức khỏe kiến trúc, nợ kỹ thuật (Tech Debt), độ phức tạp và độ bao phủ đặc tả của dự án.
"""

import sys
import os
import argparse
import json
import re

# Console Windows mặc định dùng cp1252 → in tiếng Việt/emoji ra stdout sẽ chết với
# UnicodeEncodeError. Ép UTF-8 để engine chạy được trên mọi nền (xem TRAPS.md).
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8")

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EXCLUDE_DIRS = {".git", "node_modules", "venv", ".venv", "__pycache__", ".hermes", "dist", "build", "coverage"}

def scan_codebase_health():
    total_files = 0
    total_lines = 0
    file_type_counts = {}
    large_files = []
    comment_lines = 0
    code_lines = 0
    duplicate_patterns = {}

    for dirpath, dirnames, filenames in os.walk(ROOT_DIR):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower() or "(no-ext)"
            full_path = os.path.join(dirpath, f)
            rel_path = os.path.relpath(full_path, ROOT_DIR)
            
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as fp:
                    lines = fp.readlines()
                    line_count = len(lines)
            except Exception:
                continue

            total_files += 1
            total_lines += line_count
            file_type_counts[ext] = file_type_counts.get(ext, 0) + 1

            if line_count > 400:
                large_files.append({"file": rel_path, "lines": line_count})

            for l in lines:
                l_str = l.strip()
                if not l_str:
                    continue
                if l_str.startswith("#") or l_str.startswith("//") or l_str.startswith("<!--"):
                    comment_lines += 1
                else:
                    code_lines += 1

    # Tính toán điểm sức khỏe (Architecture Health Score: 0 - 100)
    penalty = 0
    if len(large_files) > 0:
        penalty += min(len(large_files) * 5, 20)
    
    comment_ratio = comment_lines / (code_lines + 1)
    if comment_ratio < 0.05:
        penalty += 10

    health_score = max(100 - penalty, 0)

    return {
        "health_score": health_score,
        "total_files": total_files,
        "total_lines": total_lines,
        "code_lines": code_lines,
        "comment_lines": comment_lines,
        "comment_ratio_pct": round(comment_ratio * 100, 1),
        "file_types": file_type_counts,
        "large_files": large_files,
        "recommendations": generate_recommendations(health_score, large_files)
    }

def generate_recommendations(health_score, large_files):
    recs = []
    if large_files:
        recs.append(f"Cân nhắc chia nhỏ {len(large_files)} file vượt quá 400 dòng để tăng tính mô-đun.")
    if health_score >= 90:
        recs.append("Kiến trúc hiện tại đạt chuẩn xuất sắc (Score >= 90). Giữ vững kỷ luật refactoring.")
    else:
        recs.append("Chạy `/audit-optimize` để rà soát và đơn giản hóa các vùng mã nguồn phức tạp.")
    return recs

def format_markdown_report(data):
    lines = [
        "## 🛡️ Architectural Health & Tech Debt Radar",
        f"- **Điểm Sức khỏe Kiến trúc (Score):** `{data['health_score']}/100` " + ("🟢 (Rất tốt)" if data['health_score'] >= 90 else "🟡 (Cần chú ý)"),
        f"- **Tổng số File:** `{data['total_files']}`",
        f"- **Tổng số Dòng:** `{data['total_lines']}` ({data['code_lines']} dòng code, {data['comment_lines']} dòng chú thích/tài liệu)",
        f"- **Tỷ lệ Chú thích/Tài liệu:** `{data['comment_ratio_pct']}%`",
        "",
        "### Phân bổ Loại File",
        "| Mở rộng | Số lượng file |",
        "| :--- | :--- |"
    ]
    for ext, count in sorted(data['file_types'].items(), key=lambda x: x[1], reverse=True):
        lines.append(f"| `{ext}` | {count} |")

    if data['large_files']:
        lines.extend([
            "",
            "### File quy mô lớn (> 400 dòng)",
            "| File | Số dòng |",
            "| :--- | :--- |"
        ])
        for lf in data['large_files']:
            lines.append(f"| `{lf['file']}` | {lf['lines']} |")

    lines.extend([
        "",
        "### Đề xuất Nâng cấp",
        "\n".join(f"- {r}" for r in data['recommendations'])
    ])

    return "\n".join(lines)

def main():
    parser = argparse.ArgumentParser(description="Architectural Health & Tech Debt Radar Engine")
    parser.add_argument("--scan", action="store_true", help="Scan codebase and print Markdown report")
    parser.add_argument("--json", action="store_true", help="Output JSON results")

    args = parser.parse_args()
    data = scan_codebase_health()

    if args.json:
        print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(format_markdown_report(data))

if __name__ == "__main__":
    main()
