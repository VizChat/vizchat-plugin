---
name: vizchat-widget
description: Develop VizChat widgets — custom visual units on the canvas. The data contract lives in src/definition.ts (defineWidget — snapshot schema, default snapshot, ops); the view is one of two kinds — inline is a React component, nested is DOM callbacks inside an iframe. Covers package layout, i18n, styling and theming, conventions, compiling and checking, previewing, publishing, merging local and cloud changes, restoring history, and reviewing a widget. Use when the user wants to create or change a widget, needs a chart or interaction that no existing widget can do, or asks you to check a widget. Also applies to requests in Chinese mentioning 组件, 新建组件, 自定义组件, 自定义可视化, 做一个图表.
license: Apache-2.0
compatibility: Requires a VizChat account. In the cloud environment it uses the widget tools of the VizChat connector, and compiling and rendering run on VizChat's servers. In a local environment it needs a shell, Node.js and the vizchat CLI (npm install -g vizchat, signed in with vizchat auth login) to create, build, test, render and sync widgets.
---

# Developing widgets

A widget = a **data contract** (`src/definition.ts`) + **one way to draw** (inline is a React component; nested is DOM callbacks inside an iframe).
Both kinds share the same data contract, ops, and i18n; only "how to draw" differs.

## Workflow

How you work depends on the environment — in the cloud through tool calls (`references/cloud.md`), locally by editing files on disk and running `vizchat widget` commands
(`references/local.md`); read yours before you start. The rhythm is the same in both:

- **Development loop**: create the skeleton → read the skeleton → change it → compile → check the rendered result; on errors, fix and compile again. Most requests (create, restyle, fix a bug,
  add a feature) end once compile and check both pass: report what you did and leave the widget as an editable, previewable draft.
- **Publish** only when the user explicitly says "publish" or "list it". The test is the user's words, not your judgment: "fix the preview error", "add a button", "make it blue" do not include publishing.
  Publishing cannot be undone — once published, everyone can see and install it, and there is no "unpublish"; the draft stays, you keep editing it and publish the next version, so not publishing never blocks the user.
- If you break something, you can restore: the draft is snapshotted automatically before each round of changes, before the user edits by hand, and at every publish.
- Finish with a self-review following `references/review.md`.

## References index

Read each one only when you need it; they are independent of each other:

| File | When to read it |
| --- | --- |
| `references/cloud.md` | Cloud: the tool per loop step; creating from the conversation; restoring history; merging (`merge_pending`); the fields each operation returns on success |
| `references/local.md` | Local: the command per loop step; tests; merging; restoring history |
| `references/styling.md` | Before writing any styles: which color tokens hold in light and dark, the canvas type scale, the root draws no fill or frame (how to declare `frameStyle`) |
| `references/conventions.md` | UI strings through i18n, naming, the `data-vizchat-item` item anchor, declaring dependencies, what the default snapshot holds, keeping the description and the picture in step |
| `references/scaffold.md` | The skeleton files `create_widget` writes (inline / nested), verbatim |
| `references/compile-gates.md` | Compile errors starting with `[gate-name]`, or keys the schema doesn't know |
| `references/contract.md` | Before writing or changing `src/definition.ts` (schema, default snapshot, ops); when the operations document grows long |
| `references/inline.md` | The mount is inline — before writing the view |
| `references/i18n.md` | Before writing UI strings or adding config fields |
| `references/nested.md` | The mount is nested — before writing the view |
| `references/ui-components.md` | Inputs, buttons, dialogs; the content "Data" editor; config unions in the property panel (literal + number, string + empty, color) |
| `references/theming.md` | Color fields (incl. canvas / three); `-ink` text colors and light-background notices; third-party renderers (light/dark, white background, SVG sizing); hand-written CSS; radius, fonts, shadows, letter spacing |
| `references/assets.md` | Content from a file (image, PDF, HTML) or other remote data to wait for; demo package files; importing images, workers, wasm |
| `references/d3.md` | Charts with d3 |
| `references/three.md` | 3D with three |
| `references/iso.md` | Fixed-angle isometric drawings (system sketches, lab setups, block diagrams); craft rules and self-checks for solid figures |
| `references/chart-libraries.md` | ECharts, Vega-Lite, Plotly, p5, Leaflet; querying workspace tables; pictures that change over time, randomness |
| `references/vue.md` | Writing the view in Vue |
| `references/motion.md` | Deciding how the widget moves |
| `references/preinstalled-libraries.md` | Before choosing a library or a version range |
| `references/demo.md` | Writing or changing `src/demo.stb`: topic and structure, narration, formulas, layout, background and highlighting |
| `references/publish.md` | The user explicitly asks to publish, declare the source open, or synthesize demo voice-over |
| `references/review.md` | The final self-review, or the user asks you to check a widget |

## Package layout

```
my-widget/
├── package.json        # vizchat: { mount, displayName, sizeConfig } — identity only
└── src/
    ├── definition.ts   # data contract: export default defineWidget({...})
    ├── index.tsx       # inline entry: export default inlineWidget(definition, { component })
    ├── View.tsx        # inline React component (imported by index.tsx)
    ├── i18n/<language>.json # strings: one file each for en, zh, es, fr, de, ja, ru, identical keys
    ├── demo.stb        # demo script
    ├── docs.mdx        # user-facing docs
    └── __tests__/      # tests
```

nested has no `index.tsx` / `View.tsx`; its entry is `src/index.ts` (`export default nestedWidget(definition, { mount, render })`).

Locations are a convention: the compiler looks for files at the paths above. The `vizchat` block in `package.json` accepts only three keys — `mount` / `displayName` / `sizeConfig`; anything else
(such as `entry`) is an error.

## Choosing mount

Default to inline: anything that can be one React component is inline (canvas / WebGL drawing counts too: a `<canvas>` owned by the component). Choose nested only when one of these holds:

1. A complete self-managed HTML/JS app (its own routing, global styles, document-level events);
2. Dependencies that conflict with the host (another React version, rewriting globals, registering window-level singletons);
3. A library that takes over the whole document (spawns its own workers, rewrites `document.head` / `body`, hijacks global keyboard or scrolling — pdf.js's viewer, Monaco).
4. A UI framework other than React for the view (Vue).

Each of these can be read from the request ("a PDF reader" → 3 → nested; "a bar chart", "3D solid geometry" → inline); no need to build first and decide later. Size and performance are not reasons:
nested runs on the same main thread as the canvas and gives no performance isolation.
