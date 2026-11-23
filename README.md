# VizChat plugin

Skills that teach your coding agent to work with [VizChat](https://vizchat.ai): turn ideas, documents and data into
narrated storyboards, dashboards and custom visual widgets.

- **vizchat-basics** — workspaces, documents, boards, widgets and publishing; how to work locally with the `vizchat` CLI.
- **vizchat-board** — create and edit storyboards (`.stb`) and dashboards (`.dsb`).
- **vizchat-widget** — develop custom widgets.

The plugin contains only skills, a slash command (`/vizchat:update`) and hooks. It works through the `vizchat` CLI on
your machine — it does not connect to VizChat by itself.

## Before you start

```sh
npm install -g vizchat   # or install the VizChat desktop app, which includes it
vizchat auth login
```

## Install

| Agent       | How                                                                                                                                                                                                                   |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Claude Code | `/plugin marketplace add VizChat/vizchat-plugin`, then `/plugin install vizchat@vizchat-plugin`                                                                                                                                     |
| Codex       | `codex plugin marketplace add VizChat/vizchat-plugin`, then install **vizchat** from `/plugins` (review and trust its hooks in `/hooks`)                                                                                            |
| Kimi Code   | `/plugins install https://github.com/VizChat/vizchat-plugin`, then `/reload`                                                                                                                                                        |
| Cursor      | Clone this repository into `~/.cursor/plugins/local/vizchat/` and run **Reload Window**                                                                                                                               |
| OpenCode    | Clone this repository and add its `skills` folder to `skills` in `opencode.json` (for example `"skills": ["~/vizchat-plugin/skills"]`); copy `commands/*.md` into `~/.config/opencode/command/` for the slash command |

## Hooks (Claude Code and Codex)

- **SessionStart** — in a VizChat workspace, loads the basics skill; without the `vizchat` CLI, prints a one-line install hint.
- **PreToolUse** — when the `vizchat` CLI is installed and signed in, declines the VizChat cloud connector's tools so
  the agent works on your local copy instead.

## About this repository

This repository is generated from the VizChat source; please don't send pull requests that edit these files directly.
Report problems and suggestions in [issues](https://github.com/VizChat/vizchat-plugin/issues).

Licensed under the Apache License 2.0 (see `LICENSE` and `NOTICE`). The license covers the files in this repository,
not the VizChat service.
