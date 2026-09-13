#!/usr/bin/env python3
"""
subagent-dispatch.py — Universal Subagent Dispatcher Engine
Giao thức điều phối Subagent đa-harness (Claude Code, Hermes Agent, Codex CLI, Cursor, Windsurf, Gemini).

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
        return {
            "harness": "claude",
            "command": f"/subagent {name} {task_text}",
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

def main():
    parser = argparse.ArgumentParser(description="Universal Subagent Dispatcher Engine")
    parser.add_argument("--list", action="store_true", help="List all available subagents")
    parser.add_argument("--agent", type=str, help="Target agent name (e.g. security-reviewer, complex-implementer)")
    parser.add_argument("--task", type=str, default="", help="Task text/description for the agent")
    parser.add_argument("--context-file", type=str, help="File path containing context/diff/spec")
    parser.add_argument("--harness", type=str, choices=["hermes", "claude", "codex", "generic"], default="generic", help="Target AI Harness")
    parser.add_argument("--json", action="store_true", help="Output result as JSON")

    args = parser.parse_args()

    if args.list:
        agents = list_agents()
        if args.json:
            print(json.dumps([{"name": a["name"], "description": a["description"], "model": a["model"]} for a in agents], indent=2, ensure_ascii=False))
        else:
            print(f"Available Subagents ({len(agents)}):")
            for a in agents:
                print(f"  - {a['name']:<20} [{a['model']:<8}] : {a['description'][:80]}...")
        sys.exit(0)

    if not args.agent:
        print("Error: --agent is required when not listing. Use --list to see available agents.", file=sys.stderr)
        sys.exit(1)

    agent_file = os.path.join(AGENTS_DIR, f"{args.agent}.md")
    agent_info = parse_agent_md(agent_file)
    if not agent_info:
        print(f"Error: Agent '{args.agent}' not found at {agent_file}", file=sys.stderr)
        sys.exit(1)

    task_content = args.task
    if args.context_file and os.path.exists(args.context_file):
        with open(args.context_file, "r", encoding="utf-8", errors="ignore") as f:
            task_content += "\n\n" + f.read()

    payload = build_dispatch_payload(agent_info, task_content, args.harness)

    if args.json:
        print(json.dumps(payload, indent=2, ensure_ascii=False))
    else:
        if args.harness == "hermes":
            print(json.dumps(payload["delegate_task_call"], indent=2, ensure_ascii=False))
        elif args.harness == "claude":
            print(payload["command"])
        else:
            print(payload["prompt"])

if __name__ == "__main__":
    main()
