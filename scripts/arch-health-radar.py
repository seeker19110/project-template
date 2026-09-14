#!/usr/bin/env python3
"""
arch-health-radar.py — Repo Health & Tech Debt Radar

Đo KỶ LUẬT KỸ THUẬT ĐO ĐƯỢC của repo: độ phủ cổng CI trên từng script, chất lượng spec,
kỷ luật kích thước file mã, mật độ chú thích trong file MÃ, và nợ TODO/FIXME.

KHÔNG đo coupling / cyclomatic complexity — repo này là tài liệu + script, không có đồ thị
import để phân tích. Báo cáo IN RA công thức chấm điểm để con số không bị đọc nhầm thành
"điểm kiến trúc" tổng quát (audit 2026-09-13, A-02).
"""

import sys
import os
import argparse
import json
import re

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EXCLUDE_DIRS = {".git", "node_modules", "venv", ".venv", "__pycache__", ".ai-telemetry", ".hermes", "dist", "build", "coverage"}

CODE_EXT = {".sh", ".py", ".ts", ".js", ".ps1", ".mjs"}
DOC_EXT = {".md", ".mdc"}
LARGE_CODE_LINES = 400   # ngưỡng cho FILE MÃ
LARGE_DOC_LINES = 900    # tài liệu dài là bình thường, ngưỡng riêng và rộng hơn


def _count_code_files(file_type_counts):
    return sum(n for e, n in file_type_counts.items() if e in CODE_EXT)


def _scripts_inventory():
    """Kiểm kê script + xem cái nào được một test CHẠY TRONG CI gọi tới.

    Đây là tín hiệu sức khoẻ THẬT của repo này: repo khung không có đồ thị import để đo
    coupling, nhưng "script nào có cổng bảo vệ" thì đo được chính xác và hành động được.
    """
    scripts_dir = os.path.join(ROOT_DIR, "scripts")
    if not os.path.isdir(scripts_dir):
        return [], set(), set()
    all_scripts = sorted(f for f in os.listdir(scripts_dir)
                         if os.path.splitext(f)[1] in (".sh", ".py"))
    test_scripts = [f for f in all_scripts if f.startswith("test-")]

    # Test nào thật sự được ci.yml chạy — test không nằm trong CI thì không tính là cổng.
    ci_path = os.path.join(ROOT_DIR, ".github", "workflows", "ci.yml")
    ci_text = ""
    if os.path.exists(ci_path):
        with open(ci_path, encoding="utf-8", errors="ignore") as fp:
            ci_text = fp.read()
    ci_tests = [t for t in test_scripts if t in ci_text]

    covered = set()
    for t in ci_tests:
        covered.add(t)
        try:
            with open(os.path.join(scripts_dir, t), encoding="utf-8", errors="ignore") as fp:
                body = fp.read()
        except OSError:
            continue
        for cand in all_scripts:
            if cand in body:
                covered.add(cand)
                # wrapper .sh gọi .py cùng tên -> .py cũng được phủ
                stem, ext = os.path.splitext(cand)
                if ext == ".sh" and stem + ".py" in all_scripts:
                    covered.add(stem + ".py")
    return all_scripts, covered, set(ci_tests)


def _spec_quality():
    """Spec có khai mã yêu cầu và mục touchpoints không — gốc rễ của engine vỏ rỗng
    (audit 2026-09-13: 2 spec dừng ở mục 5 nên không gì ràng buộc phần triển khai)."""
    specs_dir = os.path.join(ROOT_DIR, "docs", "specs")
    total, good, weak = 0, 0, []
    if not os.path.isdir(specs_dir):
        return 0, 0, []
    for f in sorted(os.listdir(specs_dir)):
        if not f.endswith(".md") or f == "README.md":
            continue
        total += 1
        with open(os.path.join(specs_dir, f), encoding="utf-8", errors="ignore") as fp:
            body = fp.read()
        has_ids = bool(re.search(r"\b(?:FR|AC|NFR|W)-\d+\b", body))
        has_touch = "Architecture và code touchpoints" in body
        if has_ids and has_touch:
            good += 1
        else:
            missing = []
            if not has_ids:
                missing.append("không có mã FR-/AC-")
            if not has_touch:
                missing.append("thiếu mục 11 touchpoints")
            weak.append({"file": f"docs/specs/{f}", "missing": ", ".join(missing)})
    return total, good, weak


def scan_codebase_health():
    """Đo các tín hiệu CÓ THẬT, mỗi tín hiệu nói rõ nó đo gì.

    VÌ SAO VIẾT LẠI (audit 2026-09-13, A-02): bản cũ chấm điểm bằng đúng hai thứ —
    số file > 400 dòng và tỷ lệ dòng mở đầu bằng '#'. Nó KHÔNG đo kiến trúc, và tệ hơn,
    nó đếm văn xuôi Markdown là "code" nên báo repo 67% là .md thành "84% code".
    Bản này đo thứ hành động được, và IN RA CÔNG THỨC để không ai hiểu nhầm con số.
    """
    total_files = 0
    total_lines = 0
    file_type_counts = {}
    large_code_files = []
    large_doc_files = []
    code_lines = 0
    code_comment_lines = 0
    doc_lines = 0
    todo_markers = []

    for dirpath, dirnames, filenames in os.walk(ROOT_DIR):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower() or "(no-ext)"
            full_path = os.path.join(dirpath, f)
            rel_path = os.path.relpath(full_path, ROOT_DIR).replace(os.sep, "/")
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as fp:
                    lines = fp.readlines()
            except OSError:
                continue

            total_files += 1
            total_lines += len(lines)
            file_type_counts[ext] = file_type_counts.get(ext, 0) + 1

            if ext in DOC_EXT:
                doc_lines += len(lines)
                if len(lines) > LARGE_DOC_LINES:
                    large_doc_files.append({"file": rel_path, "lines": len(lines)})
                continue

            if ext in CODE_EXT:
                if len(lines) > LARGE_CODE_LINES:
                    large_code_files.append({"file": rel_path, "lines": len(lines)})
                for idx, l in enumerate(lines, 1):
                    l_str = l.strip()
                    if not l_str:
                        continue
                    if l_str.startswith("#") or l_str.startswith("//"):
                        code_comment_lines += 1
                    else:
                        code_lines += 1
                    # Marker phải nằm NGAY SAU dấu chú thích. Khớp trần "\bTODO\b" sẽ bắt nhầm
                    # chính regex này, docstring và dòng in báo cáo của file này (đã đo thật:
                    # 3 dương tính giả, làm điểm tụt 30 mà không có việc gì để sửa).
                    if re.search(r"(?:^|\s)(?:#|//)\s*(?:TODO|FIXME|XXX|HACK)\b", l_str):
                        todo_markers.append({"file": rel_path, "line": idx})

    all_scripts, covered, ci_tests = _scripts_inventory()
    uncovered = sorted(set(all_scripts) - covered)
    spec_total, spec_good, spec_weak = _spec_quality()

    # --- Điểm: 5 tín hiệu, mỗi tín hiệu 0-100, cộng theo trọng số. Công thức IN RA báo cáo. ---
    def pct(part, whole):
        return 100.0 if whole == 0 else round(100.0 * part / whole, 1)

    s_gate = pct(len(covered & set(all_scripts)), len(all_scripts))
    s_spec = pct(spec_good, spec_total)
    code_file_total = _count_code_files(file_type_counts)
    s_size = pct(max(0, code_file_total - len(large_code_files)), code_file_total)
    s_comment = 100.0 if code_lines == 0 else min(
        100.0, round(100.0 * (code_comment_lines / code_lines) / 0.15, 1))
    s_todo = 100.0 if not todo_markers else max(0.0, 100.0 - 10.0 * len(todo_markers))

    weights = {"gate": 40, "spec": 20, "size": 15, "comment": 15, "todo": 10}
    health_score = round(
        (s_gate * weights["gate"] + s_spec * weights["spec"] + s_size * weights["size"]
         + s_comment * weights["comment"] + s_todo * weights["todo"]) / 100.0)

    return {
        "health_score": health_score,
        "weights": weights,
        "signals": {
            "gate_coverage": s_gate, "spec_quality": s_spec, "size_discipline": s_size,
            "comment_density": s_comment, "todo_debt": s_todo,
        },
        "total_files": total_files,
        "total_lines": total_lines,
        "code_lines": code_lines,
        "code_comment_lines": code_comment_lines,
        "doc_lines": doc_lines,
        "doc_ratio_pct": pct(doc_lines, total_lines),
        "file_type_counts": dict(sorted(file_type_counts.items(), key=lambda kv: -kv[1])),
        "scripts_total": len(all_scripts),
        "scripts_covered": len(covered & set(all_scripts)),
        "scripts_uncovered": uncovered,
        "ci_tests": sorted(ci_tests),
        "spec_total": spec_total,
        "spec_good": spec_good,
        "spec_weak": spec_weak,
        "large_code_files": large_code_files,
        "large_doc_files": large_doc_files,
        "todo_markers": todo_markers,
        "recommendations": [],
    }


def generate_recommendations(data):
    """Đề xuất phải TRỎ VÀO VIỆC CỤ THỂ. Câu chung chung kiểu 'giữ vững kỷ luật refactoring'
    không hành động được nên không in ra."""
    recs = []
    if data["scripts_uncovered"]:
        recs.append("Thêm test (và nối vào `ci.yml`) cho: "
                    + ", ".join(f"`scripts/{x}`" for x in data["scripts_uncovered"]))
    for w in data["spec_weak"]:
        recs.append(f"Bổ sung cho `{w['file']}`: {w['missing']}")
    for lf in data["large_code_files"]:
        recs.append(f"File mã `{lf['file']}` dài {lf['lines']} dòng (> {LARGE_CODE_LINES}) — cân nhắc tách")
    for t in data["todo_markers"]:
        recs.append(f"Giải quyết hoặc chuyển thành issue: `{t['file']}:{t['line']}`")
    if not recs:
        recs.append("Không còn tín hiệu nợ kỹ thuật nào ĐO ĐƯỢC BẰNG CÁC THƯỚC Ở TRÊN.")
    return recs


def format_markdown_report(data):
    sig = data["signals"]
    w = data["weights"]
    score = data["health_score"]
    lines = [
        "## 🛡️ Repo Health & Tech Debt Radar",
        "",
        f"- **Điểm sức khoẻ:** `{score}/100` " + ("🟢" if score >= 90 else "🟡" if score >= 70 else "🔴"),
        "",
        "### Điểm được tính ra sao (in công thức để không ai hiểu nhầm con số)",
        "",
        "| Tín hiệu | Đo cái gì | Điểm | Trọng số |",
        "| :--- | :--- | ---: | ---: |",
        f"| Độ phủ cổng | % script trong `scripts/` được một test CHẠY TRONG CI phủ | {sig['gate_coverage']} | {w['gate']}% |",
        f"| Chất lượng spec | % spec có mã `FR-`/`AC-` **và** mục 11 touchpoints | {sig['spec_quality']} | {w['spec']}% |",
        f"| Kỷ luật kích thước | % file MÃ ≤ {LARGE_CODE_LINES} dòng (tài liệu tính riêng) | {sig['size_discipline']} | {w['size']}% |",
        f"| Mật độ chú thích | tỷ lệ chú thích trong file MÃ, chuẩn hoá theo mốc 15% | {sig['comment_density']} | {w['comment']}% |",
        f"| Nợ TODO/FIXME | trừ 10 điểm mỗi dấu TODO/FIXME/XXX/HACK còn sót | {sig['todo_debt']} | {w['todo']}% |",
        "",
        "> **Giới hạn trung thực:** repo này chủ yếu là tài liệu + script, không có đồ thị import",
        "> nên thước này **không** đo coupling hay cyclomatic complexity như công cụ kiến trúc thật.",
        "> Nó đo kỷ luật kỹ thuật *đo được* của chính repo. Đừng đọc nó như điểm kiến trúc tổng quát.",
        "",
        "### Quy mô",
        "",
        f"- Tổng: `{data['total_files']}` file / `{data['total_lines']}` dòng",
        f"- Mã: `{data['code_lines']}` dòng (+ `{data['code_comment_lines']}` dòng chú thích)",
        f"- Tài liệu: `{data['doc_lines']}` dòng — **{data['doc_ratio_pct']}%** tổng số dòng",
        f"- Script: `{data['scripts_covered']}`/`{data['scripts_total']}` có cổng bảo vệ trong CI",
        f"- Spec: `{data['spec_good']}`/`{data['spec_total']}` đạt chuẩn (có FR/AC + touchpoints)",
        "",
        "### Phân bổ loại file",
        "",
        "| Mở rộng | Số file |",
        "| :--- | ---: |",
    ]
    for ext, count in data["file_type_counts"].items():
        lines.append(f"| `{ext}` | {count} |")

    if data["scripts_uncovered"]:
        lines += ["", f"### ⚠️ Script KHÔNG có cổng bảo vệ ({len(data['scripts_uncovered'])})", ""]
        lines += [f"- `scripts/{x}`" for x in data["scripts_uncovered"]]

    if data["spec_weak"]:
        lines += ["", f"### ⚠️ Spec chưa đạt chuẩn ({len(data['spec_weak'])})", ""]
        lines += [f"- `{x['file']}` — {x['missing']}" for x in data["spec_weak"]]

    if data["large_code_files"]:
        lines += ["", f"### File mã dài (> {LARGE_CODE_LINES} dòng)", "", "| File | Dòng |", "| :--- | ---: |"]
        lines += [f"| `{lf['file']}` | {lf['lines']} |" for lf in data["large_code_files"]]

    if data["large_doc_files"]:
        lines += ["", f"### File tài liệu dài (> {LARGE_DOC_LINES} dòng — thông tin, KHÔNG trừ điểm)",
                  "", "| File | Dòng |", "| :--- | ---: |"]
        lines += [f"| `{lf['file']}` | {lf['lines']} |" for lf in data["large_doc_files"]]

    lines += ["", "### Việc cần làm", ""]
    lines += [f"- {r}" for r in data["recommendations"]]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Architectural Health & Tech Debt Radar Engine")
    parser.add_argument("--scan", action="store_true", help="Scan codebase and print Markdown report")
    parser.add_argument("--json", action="store_true", help="Output JSON results")

    args = parser.parse_args()
    data = scan_codebase_health()
    data["recommendations"] = generate_recommendations(data)

    if args.json:
        print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(format_markdown_report(data))

if __name__ == "__main__":
    main()
