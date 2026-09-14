#!/usr/bin/env python3
"""
subagent-dispatch.py — Universal Subagent Dispatcher Engine
Giao thức điều phối Subagent đa-harness.

Harness ĐƯỢC HỖ TRỢ THẬT (mỗi cái có một nhánh xử lý riêng): claude, hermes, codex, generic.
KHÔNG kê tên harness chưa có nhánh xử lý — bản đầu ghi cả Cursor/Windsurf/Gemini trong
docstring dù `--harness` chỉ nhận 4 giá trị, khiến người đọc tưởng đã hỗ trợ (A-03).
Harness chưa có nhánh riêng dùng `generic`: trả về system prompt thô để tự dán.

Cho phép MỌI AI Coding Harness nạp và điều phối các subagent trong `.claude/agents/*.md`
theo đúng quy ước 3-Tier Architecture (docs/framework/orchestration-3-tier.md).
"""

import sys
import os
import argparse
import json
import re

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AGENTS_DIR = os.path.join(ROOT_DIR, ".claude", "agents")

def parse_agent_md(file_path):
    if not os.path.exists(file_path):
        return None
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    frontmatter = {}
    body = content
    
    if content.startswith("---"):
        parts = content.split("---", 2)
        if len(parts) >= 3:
            yaml_text = parts[1]
            body = parts[2].strip()
            for line in yaml_text.splitlines():
                line = line.strip()
                if ":" in line and not line.startswith("#"):
                    key, val = line.split(":", 1)
                    key = key.strip()
                    val = val.strip().strip(">-\n ").strip()
                    frontmatter[key] = val

    name = frontmatter.get("name", os.path.splitext(os.path.basename(file_path))[0])
    return {
        "name": name,
        "description": frontmatter.get("description", ""),
        "tools": frontmatter.get("tools", ""),
        "model": frontmatter.get("model", "sonnet"),
        "path": file_path,
        "system_prompt": body
    }

def list_agents():
    agents = []
    if not os.path.exists(AGENTS_DIR):
        return agents
    for f in sorted(os.listdir(AGENTS_DIR)):
        if f.endswith(".md"):
            info = parse_agent_md(os.path.join(AGENTS_DIR, f))
            if info:
                agents.append(info)
    return agents

def build_dispatch_payload(agent_info, task_text, harness_type):
    name = agent_info["name"]
    model = agent_info["model"]
    sys_prompt = agent_info["system_prompt"]
    
    full_prompt = f"=== SUBAGENT ROLE: {name.upper()} ({model}) ===\n" \
                  f"{sys_prompt}\n\n" \
                  f"=== TASK CONTEXT ===\n" \
                  f"{task_text}\n"

    if harness_type == "hermes":
        return {
            "harness": "hermes",
            "delegate_task_call": {
                "tasks": [
                    {
                        "goal": f"[{name}] {task_text[:200]}...",
                        "context": full_prompt
                    }
                ]
            },
            "agent": agent_info
        }
    elif harness_type == "claude":
        # Claude Code KHÔNG có lệnh `/subagent` (audit 2026-09-13, A-03: bản cũ sinh ra chuỗi
        # đó, dán vào Claude Code sẽ không chạy). Cơ chế THẬT là tool Task/Agent với
        # subagent_type = tên file trong .claude/agents/. Trả về đúng hình dạng lời gọi đó.
        return {
            "harness": "claude",
            "tool_call": {
                "tool": "Task",
                "subagent_type": name,
                "description": task_text[:60],
                "prompt": full_prompt,
            },
            "agent": agent_info
        }
    elif harness_type == "codex":
        return {
            "harness": "codex",
            "prompt": full_prompt,
            "agent": agent_info
        }
    else:
        return {
            "harness": "generic",
            "prompt": full_prompt,
            "agent": agent_info
        }

def _build_parser():
    parser = argparse.ArgumentParser(description="Universal Subagent Dispatcher Engine")
    parser.add_argument("--list", action="store_true", help="List all available subagents")
    parser.add_argument("--agent", type=str, help="Target agent name (e.g. security-reviewer, complex-implementer)")
    parser.add_argument("--task", type=str, default="", help="Task text/description for the agent")
    parser.add_argument("--context-file", type=str, help="File path containing context/diff/spec")
    parser.add_argument("--harness", type=str, choices=["hermes", "claude", "codex", "generic"], default="generic", help="Target AI Harness")
    parser.add_argument("--json", action="store_true", help="Output result as JSON")
    return parser


def _print_agent_list(as_json):
    agents = list_agents()
    if as_json:
        print(json.dumps([{"name": a["name"], "description": a["description"], "model": a["model"]} for a in agents], indent=2, ensure_ascii=False))
        return
    print(f"Available Subagents ({len(agents)}):")
    for a in agents:
        print(f"  - {a['name']:<20} [{a['model']:<8}] : {a['description'][:80]}...")


def _load_task_text(task, context_file):
    if context_file and os.path.exists(context_file):
        with open(context_file, "r", encoding="utf-8", errors="ignore") as f:
            return task + "\n\n" + f.read()
    return task


def _print_payload(payload, harness, as_json):
    if as_json:
        print(json.dumps(payload, indent=2, ensure_ascii=False))
    elif harness == "hermes":
        print(json.dumps(payload["delegate_task_call"], indent=2, ensure_ascii=False))
    elif harness == "claude":
        # In chỉ dẫn NGƯỜI/AI đọc được mô tả đúng cơ chế thật của Claude Code
        # (tool Task với subagent_type), thay vì một slash command không tồn tại.
        tc = payload["tool_call"]
        print(f"Claude Code — gọi tool {tc['tool']} với subagent_type=\"{tc['subagent_type']}\":")
        print()
        print(tc["prompt"])
    else:
        print(payload["prompt"])


def main():
    args = _build_parser().parse_args()

    if args.list:
        _print_agent_list(args.json)
        sys.exit(0)

    if not args.agent:
        print("Error: --agent is required when not listing. Use --list to see available agents.", file=sys.stderr)
        sys.exit(1)

    agent_file = os.path.join(AGENTS_DIR, f"{args.agent}.md")
    agent_info = parse_agent_md(agent_file)
    if not agent_info:
        print(f"Error: Agent '{args.agent}' not found at {agent_file}", file=sys.stderr)
        sys.exit(1)

    payload = build_dispatch_payload(agent_info, _load_task_text(args.task, args.context_file), args.harness)
    _print_payload(payload, args.harness, args.json)

if __name__ == "__main__":
    main()
