# Conventions: UI strings, naming, item anchors, dependencies, default snapshots

## Strings

Every user-visible string (including the property-panel labels of config fields) goes through `src/i18n/<language>.json`, never hard-coded: one file for each of the seven interface languages (en, zh, es, fr, de, ja, ru), with exactly the same keys. The compile gates catch a missing language and a missing translation alike.

## Naming

- slug: starts with a lowercase letter; lowercase letters and digits; single hyphens between words; 3–30 characters (`bar-chart`).
- Type name: `<author>/<slug>`; pinned to a version: `<author>/<slug>@<version>`.

## Data item anchors: `data-vizchat-item`

When rendering each data item that narration can refer to (bars, slices, data points, sections…), put `data-vizchat-item="<itemId>"` on its DOM element. The canvas uses it to draw
emphasis frames and anchor caption cards next to the item, and `item.scrollTo` uses it to scroll into place — no code needed (to draw the emphasis yourself, see `highlightOps` in the reference on the data contract). `itemId` is the item's stable id in the snapshot, not the array index; the attribute name must be
`data-vizchat-item` (`data-id` is taken by the canvas itself).

## Screen-reader alternative: `useChartDescription`

A picture drawn with svg / canvas / WebGL is blank to a screen reader. Every widget with a picture provides a text alternative: a one-sentence summary `label` (what is drawn and the conclusion most worth reading out,
such as "5 items, highest is March at 120"), plus a `dataTable` when the data fits a table (`columns` for headers, `rows` one row per item, the first column being the row header). Put the summary sentence and the headers in
the `viewState` translations; the platform prepends the instance title to the summary, so do not add it yourself.

- d3 charts: `describe: (snapshot, t, locale) => ({ label, dataTable })` on `d3View` (required; see the d3 reference).
- Everything else (canvas, WebGL, ECharts / Plotly / Vega containers): `const { imageProps, dataTable } = useChartDescription({ label, dataTable })`
  (`@vizchat/widget-sdk/react`). Spread `imageProps` (`role="img"` + `aria-label`) onto the drawing surface element and put `{dataTable}` (a visually hidden `<table>`)
  as a **sibling** of the drawing surface — inside `role="img"` a screen reader cannot reach it; it takes no layout space and stays out of screenshots. Compute the arguments with `useMemo` from the snapshot.
- Pure illustrations and simulations have no data to tabulate: give only `label`. With thousands of data points, also give only the summary rather than a table thousands of rows long.
- When joining items into a summary or a cell, join them per language instead of hard-coding `、` `；` `（）`: use `formatList(items, locale)` for lists and `joinClauses(parts, locale)` for clauses, plus `formatLabeled` / `formatParenthetical` (all exported from `@vizchat/widget-sdk`; in nested widgets pass `ctx.locale`; in React components `useTextJoin()` from `/react` returns versions bound to the current language).

## Dependencies

Declare everything you import under `dependencies` in `package.json` (React, zod, chart libraries included), with `^` ranges, not pinned exact versions. Only npm registry packages are accepted
(semver ranges, dist-tags, `npm:<name>@<range>` aliases); `file:` / `workspace:` / git / tarball addresses fail compilation. Installing dependencies doesn't run `postinstall`,
so packages that rely on it to download binaries end up incomplete. Dependencies are bundled with your widget, and each widget uses the versions it declares; only react, react-dom and zod are shared with the host, and your declared ranges must cover the host's versions. Details and license rules: the reference on dependencies.

## Default snapshot

- The default snapshot is a minimal, neutral, obviously placeholder sample: three to five data points for charts, one or two objects for geometry, one placeholder paragraph for text; use skeleton values like `A / B / C`, `10 / 20 / 30`,
  never data that looks like a real business — the default snapshot is written verbatim into the user's document. The full, polished example goes only in `demo.stb`.
- Defaults must also hold for "a read-only presentation where the reader doesn't interact": anything that appears only on hover or selection does not exist in a presentation.
- In drawing widgets, the labels of objects in the picture (point names, force names, part names) are **hidden by default, and the board writes out the ones to show**: every labellable object has `label` (the text)
  and `showLabel` (`showLabelField()` from `@vizchat/widget-sdk`; omitted means hidden), and rendering draws the label only when `showLabel` is true; spread
  `labelOps({ collections: [...] })` into `ops` to get `setLabels`, same name and arguments in every widget (`only` / `show` / `hide`, where `hide` can be `'all'`). Don't add a widget-wide
  show switch or a hover-only mode. Not covered: chart axes, legends, series names, value labels, and structural text the picture can't be read without (pedigree numbers,
  gel lane names, the text of a sketch node itself) — they are drawn as usual. In the default snapshot, write `showLabel: true` on the labels it means to show.
- The default snapshot must not render as a blank box; where only the author can write the content, draw an unmistakable placeholder in every context (the review reference has the criteria).

## What the description promises, the picture delivers

1. Every style field written into the snapshot must be used when rendering: `(d) => d.strokeWidth ?? defaults.strokeWidth`, not `() => defaults.strokeWidth` — otherwise the op reports success,
   the snapshot changes, and the picture doesn't move. Fields nobody reads in the schema are either wired up or deleted.
2. Present like things by the same rules: display numbers with `formatChartValue` (`@vizchat/widget-sdk/d3`), not your own `toFixed`.
3. When an op doesn't succeed, it must be visible in the picture: prefer designing ops without failure states (clamp when out of range, create when not found); where that can't be designed away, give the graphic element a visible error marker if it can be located,
   or else write a one-line notice on the chart (d3 widgets use `renderChartNotice`, React widgets use `WidgetNoticeBand`). Nothing ever reads `return { status: 'error' }`.
