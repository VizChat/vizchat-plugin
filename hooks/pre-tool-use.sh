#!/bin/sh
# 调用 VizChat 云端工具（连接器的 MCP 工具，由 hooks.json 的 matcher 筛出）之前：本机有可用的 vizchat CLI（已登录）就拒绝，
# 让 agent 改用 vizchat 命令——本地环境只走 CLI，两边各改一份同一个工作区会进合并（vizchat-basics「判断你在哪个环境」）。
# CLI 不在或没登录时放行（没有 shell 能用的环境只能靠云端工具）。输出是 Claude Code 与 Codex 同形的 PreToolUse 结论。
cat >/dev/null
command -v vizchat >/dev/null 2>&1 || exit 0
vizchat auth whoami >/dev/null 2>&1 || exit 0
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"The vizchat CLI is installed and signed in on this machine, so work on VizChat locally with vizchat commands (clone the workspace with `vizchat workspace clone` if it is not here yet) instead of the VizChat cloud tools."}}'
exit 0
