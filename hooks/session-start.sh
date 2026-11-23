#!/bin/sh
# 会话开始时（只读文件，不联网、不写盘）：
# - 没有 vizchat 命令：输出一行安装提示（plugin 只带 skill，操作工作区靠 CLI；装了 VizChat 桌面端则自带）；
# - 当前目录（或它的上层）是 VizChat 工作区：把 vizchat-basics 的正文注入上下文；否则 skill 按描述触发。
if ! command -v vizchat >/dev/null 2>&1; then
  printf 'VizChat: the vizchat CLI is not installed. Install it with `npm install -g vizchat` (the VizChat desktop app includes it), then sign in with `vizchat auth login`.\n'
fi
dir=$(pwd)
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  if [ -f "$dir/.vizchat/manifest.json" ]; then
    skill="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/skills/vizchat-basics/SKILL.md"
    [ -f "$skill" ] || exit 0
    printf 'This directory is a VizChat workspace (%s). The vizchat-basics skill follows.\n\n' "$dir"
    # 去掉 frontmatter（首个 --- 到第二个 --- 之间）
    awk 'BEGIN{n=0} /^---$/ && n<2 {n++; next} n>=2 {print}' "$skill"
    exit 0
  fi
  dir=$(dirname "$dir")
done
exit 0
