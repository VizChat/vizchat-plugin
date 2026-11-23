---
name: vizchat-board
description: Create and edit VizChat boards — storyboards (.stb, narrated presentations played step by step) and dashboards (.dsb, static layouts shown on one screen) — covering which type to pick, which file to write to, which widgets to use, canvas coordinates and layout, visual configuration, YAML rules, referencing workspace files and sources, the production flow and self-check, and reviewing a board. Use when the user wants to turn a report, data or a concept into a presentation or dashboard, wants to change an .stb / .dsb file, or asks you to check whether a board is good. Also applies to requests in Chinese mentioning 故事板, 仪表盘, 幻灯片, 演示.
license: Apache-2.0
compatibility: Requires a VizChat account. In the cloud environment it uses the document and board tools of the VizChat connector. In a local environment boards are plain YAML files on disk; checking, rendering, showing and syncing them needs a shell, Node.js and the vizchat CLI (npm install -g vizchat).
---

# Making boards

A board is a YAML document: a storyboard (`.stb`) tells one story, has narration and plays step by step; a dashboard (`.dsb`) lays
everything out on one screen, with no narration and no steps. Both share the canvas coordinate system, columns, widgets and editing
method; a dashboard has no title band and no footer band, and otherwise only the document structures differ.

VizChat renders the widgets on the canvas from the document; your job is to write the document correctly.

## References index

Read each one only when you need it; they are independent of each other:

| File | When to read it |
| --- | --- |
| `references/choosing-widgets.md` | Before deciding which widget to use; widget versions, updating widgets, using unpublished widgets |
| `references/layout.md` | Before placing widgets: canvas coordinates, the grid, common layouts, widget size and type size |
| `references/theme-and-appearance.md` | Creating a board, or changing the theme, background, frames, light / dark, colors or widget default styles |
| `references/widget-data.md` | Writing widget data: referencing workspace files, exact values, whether to show the source; line breaks and quotes in YAML |
| `references/storyboard-structure.md` | Storyboards: top-level structure, fields and naming of slides / cues / operations, size limits |
| `references/transitions.md` | Storyboards: page transitions |
| `references/narration.md` | Storyboards: writing narration, formulas, narration languages and voice, markers matching cues, waiting for content before narrating on |
| `references/operations.md` | Storyboards: creating widgets and entrances, canvas operations (emphasis, edges, viewport), reuse across slides, transient operations |
| `references/pinned-and-background.md` | Storyboards: pinned widgets (page numbers, titles, watermarks, exam sheets), canvas backgrounds and animated shaders, binding expressions |
| `references/storyboard-example.md` | Storyboards: a complete example, how to make common edits, quality bars for length and pacing |
| `references/dashboard.md` | The structure of a dashboard |
| `references/review.md` | Reviewing a board, including the self-check at the end of the workflow |

## Storyboard or dashboard

| What the user wants | Use |
| --- | --- |
| Tell one story, in order, unfolding step by step, to be presented to others | Storyboard (default) |
| See everything on one screen, compare side by side, glance at any time | Dashboard |

## Which file

| Situation | What to do |
| --- | --- |
| The user has a board of the right type open (the host told you the current file) | Edit it |
| Nothing open, but the workspace has a related board | List the files first; if one matches, edit it |
| New topic, or the user says "make a new one" | Create one, in a meaningful folder, e.g. `presentations/product-sales-comparison.stb` |
| The user wants to start from a published board ("find a template", "like that one") | `search_boards` finds them (`list_boards` for the user's own and favorites), `apply_board` forks it into the workspace; then edit the fork |

## Production flow

1. **Prepare material**: if you cite documents, read out the key information first; if you need exact numbers, compute them; if analysis or reasoning is needed, think it through first and write the conclusions as text for a rich-text widget.
   Skip this when the material comes straight from user input.
2. **Plan widgets**: search or fetch operation docs and list the widgets you will use.
3. **Write the YAML**:
   - New: write the complete YAML in one go (`create_document`, or write the file directly when local), with `meta` at the top level (see the next section).
   - Edit: first `read_yaml_path` to read the current content, then `edit_yaml_path` to change by path — `append` to add, `set` to replace, `delete` to remove;
     one `edits` list can carry several items, and `set` and `append` create missing paths automatically. If the user changed the document after you read it, the write returns `conflict`:
     read again and redo the change on the new content. When local, edit the file directly.
4. **Validate**: `check_board` (locally `vizchat board check <file>`) checks required fields, unique ids, the match between narration markers and cues, that widgets are created before they are operated on,
   whether operation arguments fit the widget's schema, and **unrecognized fields** (old syntax, typos, fields in the wrong place — ignored when read, rejected when publishing). Locate errors by `errors[].path`, read that part, fix it and validate again. If repeated fixes keep failing, explain the problem to the user in words
   and finish the other parts you can.
5. **Self-check**: `render_board` (locally `vizchat board render <file>`) renders page by page; look at the screenshots and measurements and handle findings per `references/review.md`.
6. **Show**: `show_board` (locally `vizchat board show <file>`), and in your reply say what you made and which trade-offs you made.

## A board's title, description and tags

The top-level `meta` in the document is the single source of a board's title, description and tags: publishing reads them from here, and the marketplace cards, search and related recommendations all use them.
Write it while you make the board — you know the content best, so it comes out more accurate than filling it in at publish time.

```yaml
meta:
  title: "Reading a research note: the 2023 collapse of Silicon Valley Bank"
  description: One causal chain explains a bank crisis: rising rates, unrealized losses on long-term bonds, concentrated and mostly uninsured deposits, and finally a $40B run in a single day.
  tags: [finance, banking crisis, Silicon Valley Bank, research note]
```

- **Title**: say what this is, specific to the topic; don't use format words like “presentation”, “storyboard” or “dashboard”. Required — publishing is blocked without a title.
- **Description**: what it covers, who it is for and what they take away; describe the content, not which widgets you used. **The first sentence alone must say what this is** — marketplace cards show only the first two lines.
  The limit is display width 160: Chinese, Japanese and Korean characters count as 2, everything else as 1 (about 80 Chinese characters or 160 English characters).
- **Tags**: 2–6, in the same language as the narration; write topic words readers would search for (field, specific topic, purpose), not format words; keep proper nouns as they are.
- **Cover** (storyboards only): `cover: <page number>`, counted from 1 — marketplace cards and share previews use this page; omit it for the first page. When the first page is a title page that doesn't show what the board is about, pick the page that best represents it.

When the user changes the title or tags, change `meta`, then “Update publication” for it to take effect (the publish settings — unlisted, allow embedding — are not in the document and can be changed any time).

## Recent format changes and old syntax

The board format has no version number. When the format changes, the old syntax becomes an "unrecognized field": it is ignored when read (the board plays, but what you wrote has no effect), and `check_board` and publishing report
`unrecognized field`. When you see one, rewrite it in the current syntax per the table below; anything not in the table is most likely a typo or a field in the wrong place — correct it against this skill and `references/`,
and delete what is not needed. Each row says "old syntax → new syntax, and why".

The "unknown field" problems a user hands you from the "Needs fixing" group of the workbench's Problems panel are exactly these (they block publishing); from the "Can upgrade" group comes "source language not declared" — read the narration and set `config.sourceLocale` to the language it is actually written in.

| Old syntax | New syntax | Why |
| --- | --- | --- |
| `config.title: <title>` | `meta.title: <title>` | A board's title, description and tags moved into the top-level `meta`; publishing reads them from there |
| `config.author: <author>` | Delete it | The author is the publishing account; it is not written into the document |
