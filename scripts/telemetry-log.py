#!/usr/bin/env python3
"""
telemetry-log.py — Universal AI Telemetry & Observability Engine
Ghi nhận và báo cáo hiệu năng / chi phí / chất lượng thực thi của AI Coding Agents.
"""

import sys
import os
import argparse
import json
import time
from datetime import datetime, timezone

# Console Windows mặc định dùng cp1252 → in tiếng Việt/emoji ra stdout sẽ chết với
# UnicodeEncodeError. Ép UTF-8 để engine chạy được trên mọi nền (xem TRAPS.md).
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8")

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_DIR = os.path.join(ROOT_DIR, ".hermes")
LOG_FILE = os.path.join(LOG_DIR, "telemetry.json")

MODEL_RATES = {
    "opus": {"input": 15.0, "output": 75.0},
    "sonnet": {"input": 3.0, "output": 15.0},
    "haiku": {"input": 0.25, "output": 1.25},
    "gpt-4o": {"input": 2.50, "output": 10.0},
    "gemini-flash": {"input": 0.075, "output": 0.30},
    "default": {"input": 1.0, "output": 3.0}
}

def load_logs():
    if not os.path.exists(LOG_FILE):
        return []
    try:
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return []

def save_logs(logs):
    os.makedirs(LOG_DIR, exist_ok=True)
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(logs, f, indent=2, ensure_ascii=False)

def record_entry(harness, provider, model, agent, task, duration_sec, diff_loc, test_status, input_tokens=0, output_tokens=0):
    logs = load_logs()
    
    rate = MODEL_RATES.get(model.lower(), MODEL_RATES["default"])
    est_cost = ((input_tokens / 1_000_000) * rate["input"]) + ((output_tokens / 1_000_000) * rate["output"])
    
    entry = {
        "id": f"tel-{int(time.time())}-{len(logs)+1}",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "harness": harness,
        "provider": provider,
        "model": model,
        "agent": agent,
        "task": task,
        "duration_sec": round(duration_sec, 2),
        "diff_loc": diff_loc,
        "test_status": test_status,
        "input_tokens": input_tokens,
        "output_tokens": output_tokens,
        "est_cost_usd": round(est_cost, 4)
    }
    
    logs.append(entry)
    save_logs(logs)
    return entry

def generate_markdown_summary(logs):
    if not logs:
        return "### AI Telemetry Summary\n*Chưa có dữ liệu thực thi được ghi nhận.*"

    total_tasks = len(logs)
    passed_tasks = sum(1 for l in logs if l["test_status"].upper() == "PASSED")
    total_cost = sum(l.get("est_cost_usd", 0) for l in logs)
    total_duration = sum(l.get("duration_sec", 0) for l in logs)
    total_loc = sum(l.get("diff_loc", 0) for l in logs)

    lines = [
        "## 📊 AI Execution & Observability Summary",
        f"- **Tổng số tác vụ AI:** `{total_tasks}`",
        f"- **Tỷ lệ thành công (Quality Gate):** `{passed_tasks}/{total_tasks}` ({(passed_tasks/total_tasks)*100:.1f}%)",
        f"- **Tổng thời gian chạy:** `{total_duration:.1f}s`",
        f"- **Tổng mã nguồn thay đổi (LOC):** `{total_loc} dòng`",
        f"- **Ước tính Chi phí API:** `${total_cost:.4f} USD`",
        "",
        "### Nhật ký tác vụ gần nhất",
        "| ID | Harness | Agent | Task | Thời gian | Status | LOC | Est. Cost |",
        "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |"
    ]

    for l in logs[-10:]:
        lines.append(f"| `{l['id']}` | `{l['harness']}` | `{l['agent']}` | {l['task'][:30]} | {l['duration_sec']}s | `{l['test_status']}` | {l['diff_loc']} | ${l['est_cost_usd']:.4f} |")

    return "\n".join(lines)

def generate_html_widget(logs):
    total_tasks = len(logs)
    passed_tasks = sum(1 for l in logs if l["test_status"].upper() == "PASSED")
    total_cost = sum(l.get("est_cost_usd", 0) for l in logs)
    total_duration = sum(l.get("duration_sec", 0) for l in logs)
    pass_rate = round((passed_tasks/total_tasks)*100, 1) if total_tasks > 0 else 0

    widget_html = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body {{
      font-family: system-ui, -apple-system, sans-serif;
      margin: 0;
      padding: 16px;
      color: var(--foreground, #1e293b);
      background: transparent;
    }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 12px;
      margin-bottom: 16px;
    }}
    .card {{
      background: var(--card, #f8fafc);
      border: 1px solid var(--border, #e2e8f0);
      border-radius: 8px;
      padding: 12px;
    }}
    .card .title {{
      font-size: 12px;
      color: var(--muted-foreground, #64748b);
      margin-bottom: 4px;
    }}
    .card .value {{
      font-size: 20px;
      font-weight: 700;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }}
    th, td {{
      padding: 8px 12px;
      text-align: left;
      border-bottom: 1px solid var(--border, #e2e8f0);
    }}
    th {{
      color: var(--muted-foreground, #64748b);
      font-weight: 600;
    }}
    .badge-passed {{ color: #16a34a; font-weight: 600; }}
    .badge-failed {{ color: #dc2626; font-weight: 600; }}
  </style>
</head>
<body>
  <div class="grid">
    <div class="card"><div class="title">TỔNG TÁC VỤ</div><div class="value">{total_tasks}</div></div>
    <div class="card"><div class="title">TỶ LỆ ĐẠT (PASS)</div><div class="value">{pass_rate}%</div></div>
    <div class="card"><div class="title">THỜI GIAN CHẠY</div><div class="value">{total_duration:.1f}s</div></div>
    <div class="card"><div class="title">EST. COST</div><div class="value">${total_cost:.4f}</div></div>
  </div>
  <table>
    <thead>
      <tr><th>Harness</th><th>Agent</th><th>Task</th><th>Duration</th><th>Status</th><th>Est Cost</th></tr>
    </thead>
    <tbody>
"""
    for l in logs[-8:]:
        badge_cls = "badge-passed" if l['test_status'].upper() == "PASSED" else "badge-failed"
        widget_html += f"      <tr><td>{l['harness']}</td><td>{l['agent']}</td><td>{l['task'][:35]}</td><td>{l['duration_sec']}s</td><td class=\"{badge_cls}\">{l['test_status']}</td><td>${l['est_cost_usd']:.4f}</td></tr>\n"

    widget_html += """    </tbody>
  </table>
</body>
</html>"""
    
    widget_path = os.path.join(LOG_DIR, "widget-telemetry.html")
    os.makedirs(LOG_DIR, exist_ok=True)
    with open(widget_path, "w", encoding="utf-8") as f:
        f.write(widget_html)
    return widget_path

def main():
    parser = argparse.ArgumentParser(description="Universal AI Telemetry Logger")
    parser.add_argument("--record", action="store_true", help="Record a new telemetry entry")
    parser.add_argument("--summary", action="store_true", help="Generate Markdown summary")
    parser.add_argument("--widget", action="store_true", help="Generate Hermes HTML Widget")
    parser.add_argument("--harness", type=str, default="hermes")
    parser.add_argument("--provider", type=str, default="antigravity")
    parser.add_argument("--model", type=str, default="sonnet")
    parser.add_argument("--agent", type=str, default="main")
    parser.add_argument("--task", type=str, default="Standard Task Execution")
    parser.add_argument("--duration", type=float, default=1.0)
    parser.add_argument("--diff-loc", type=int, default=0)
    parser.add_argument("--test-status", type=str, default="PASSED")
    parser.add_argument("--input-tokens", type=int, default=1000)
    parser.add_argument("--output-tokens", type=int, default=500)

    args = parser.parse_args()

    if args.record:
        entry = record_entry(
            harness=args.harness,
            provider=args.provider,
            model=args.model,
            agent=args.agent,
            task=args.task,
            duration_sec=args.duration,
            diff_loc=args.diff_loc,
            test_status=args.test_status,
            input_tokens=args.input_tokens,
            output_tokens=args.output_tokens
        )
        print(f"Recorded telemetry entry: {entry['id']}")
        sys.exit(0)

    if args.widget:
        logs = load_logs()
        wpath = generate_html_widget(logs)
        print(f"HTML Widget generated at: {wpath}")
        print(f"::preview{{file=\"{wpath}\"}}")
        sys.exit(0)

    # Default: output summary
    logs = load_logs()
    print(generate_markdown_summary(logs))

if __name__ == "__main__":
    main()
