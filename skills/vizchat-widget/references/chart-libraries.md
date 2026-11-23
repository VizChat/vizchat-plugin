# Third-party chart and drawing libraries

Besides d3 and three, the platform gives a few common libraries an adapter entry each. The host conventions — theme, readiness, item anchors,
error reporting, motion intent — are wired for you; the widget only turns its snapshot into the library's input. The library itself is imported
by the widget (declared in `dependencies`); the entry never imports it and only relies on its shape.

| Library | Entry | You write | The entry does |
| --- | --- | --- | --- |
| ECharts | `@vizchat/widget-sdk/echarts` | `echarts.init(el, null, { renderer: 'svg' })`, then `setOption` / `setTheme` / `resize` through the binding from `bindEcharts(chart, { gate, onFinished })` | `finished` wired to readiness, anchors from each series' data `id`, the ordering of `setTheme` and the first `setOption`, hard cuts when animation is off |
| Vega-Lite | `useVegaLite(ref, { vega, vegaLite, interpreter }, spec, { keyOf })` from `@vizchat/widget-sdk/vega/react` | the spec (from the snapshot or built by you) | eval-free evaluation (`vega-interpreter`), theme config, anchors via `keyOf`, compile errors and warnings reported to the agent |
| Plotly | `usePlotly(ref, Plotly, { data, layout }, { anchorsOf, animate })` from `@vizchat/widget-sdk/plotly/react` | data / layout (without the theme) | theme layout, a fixed config (no mode bar), `Plotly.validate` reporting unknown keys and invalid values, one redraw at a time, cleanup on unmount |
| p5 | `useP5Canvas(ref, p5, draw)` → `show(scene, size)` from `@vizchat/widget-sdk/p5/react` | `draw(p, scene)` for one frame | instance mode, p5's own loop off, the async setup, readiness after the first frame, a pixel-density cap |
| Document tables | `useDocumentTable(source)` from `@vizchat/widget-sdk/table/react`; queries with `applyQuery(table, transforms)` (`/table`) | filters, aggregates and sorts written as Vega-Lite transforms | reading CSV / TSV from the workspace, header normalization and type inference, pending-resource tracking, the query engine |

## Shared rules

- **Pass themes as objects, never register them by name**: ECharts takes `binding.setTheme(toEchartsTheme(theme))` with `theme` from
  `useChartTheme(rootRef)`; the Vega and Plotly entries merge the theme into the config / layout. Name-keyed registries are shared by every widget
  on the same canvas page and overwrite each other.
- **Anchors**: a library's marks have no DOM to tag, so the entry computes a rectangle per data item and `ItemAnchorLayer`
  (`@vizchat/widget-sdk/react`) draws it as a transparent anchor layer. ECharts reads the `id` in series data, Vega uses `keyOf(datum)`, Plotly
  converts data coordinates to pixels with `plotlyPointAnchor(el, { id, x, y })`.
- **Motion intent**: play the library's animation while the narration advances; land on the end state on page jumps, seeks, thumbnails and
  reduced motion. ECharts reads `useMotionIntent()` when calling `setOption`; Plotly takes `usePlotly(…, { animate: config.display.enableAnimation })`
  and interpolates the coordinates of every scatter / line point frame by frame, recomputing the axes as it goes (a change in point or trace
  count, or a heatmap and the like, lands on the end state directly); memoize the figure on its content with `useMemo`. Vega has no transitions
  between states, so every draw is final.
- **Strict CSP**: MCP hosts do not allow `eval`. Vega expressions are evaluated only through `vega-interpreter` (the entry wires
  it); do not create `new vega.View(...)` yourself and bypass it. The verification page runs without eval and reports this before publishing.
- **Libraries the platform does not supply are bundled with your widget**: with Plotly, use `plotly.js/lib/core` and `Plotly.register([...])` only the
  traces you use (`contour`, `heatmap`, …) — do not import the whole `plotly.js` (several times larger, and the `image` trace depends on Node
  built-ins). `lib/core` has no type declarations; write `declare module 'plotly.js/lib/core'` in the widget, typed as `PlotlyModule` (`/plotly`).
- **Screen-reader alternative**: a library draws into its own container, which is blank to a screen reader. Spread the `imageProps` of `useChartDescription` (`@vizchat/widget-sdk/react`) onto the chart container and put `dataTable` next to it (see "Screen-reader alternative" in the conventions reference).
- **Math is plain text**: ECharts, Vega and Plotly do not render LaTeX; `$…$` shows as written.

## Time and randomness

- **A picture that changes over time** (a physics simulation, a route drawn segment by segment, samples piling up): store the **target time**
  (or target sample count) in the snapshot, never the wall clock. `usePlayhead(target)` gives the time to draw now — it tweens there frame by
  frame while the narration advances, jumps on page jumps, seeks and thumbnails, and is driven by the virtual clock in video export, so every frame
  is reproducible. The picture is a pure function of that time: never read `Date.now()`, `millis()` or `frameCount`. By default it gets there in
  0.6 s; to play at a real pace pass a rate, `usePlayhead(target, { rate })` (units per second: 1 for simulated seconds, some number of samples
  per second), and make the speed a config field the reader can change. Outside React use the core `createPlayheadTween` (it takes `rate` too).
- **A process with its own duration should hold the page**: during auto-play the page turns as soon as the narration ends, cutting off anything
  still playing. Add `holdPage: holdPageField()` to the config (authors can switch it off; having it in the schema declares that the widget holds
  the page, which video export uses for its estimate) and pass its value on: a rate-driven playhead `usePlayhead(target, { rate, holdPage })` holds
  automatically; anything else (a running countdown, your own long animation) uses `usePageHold(active && holdPage, { reason, expectedMs })` —
  `reason` is one sentence for the viewer (through i18n), `expectedMs` the time left at the moment of holding. Nested widgets use
  `ctx.holdPage(options)`, which returns `release()`; Vue uses `usePageHold(() => …, () => ({ … }))`. Release when the process ends, is paused or
  reset. **Anything that never ends (looping or decorative animation) must not hold**; viewers can always skip, and video export caps the wait per page.
- **When the viewer pauses the presentation player, the picture pauses too**: `usePlayhead` follows it already (it stops at the current time and
  finishes the rest of the way on resume). Anything you time yourself (a countdown, your own rAF loop) reads `usePlaybackPaused()`: while paused,
  freeze the frame, then carry on when playback resumes — time spent paused does not count. Keep holding the page through the pause (the player checks holds the moment it resumes); on resume take a new hold for the time left and release the old one (Vue's `usePageHold` takes this as its third argument, `renewOn`). Nested widgets read
  `ctx.paused` (`subscribe` for changes), Vue reads `useWidgetMeta().paused`, and `createPlayheadTween` takes `tween.setPaused(...)`.
- **A picture that keeps moving (looping effects, background animation) reads the board clock**: `useBoardClock()` gives one continuous time `t`
  (ms) shared by every widget on the board — counted from the start of playback, frozen while the viewer pauses, never reset on a page turn; it
  runs while editing, is 0 in thumbnails and follows the virtual clock in video export. Read `clock.now()` in a rAF loop and draw that moment: the
  picture is a pure function of `t`, so pause, page jumps and export stay consistent. `subscribe` fires only on start, stop and seek. A React component that re-renders over time
  takes the current `t` from `useBoardClockTime(active)` instead of writing its own rAF loop: it draws no frames while the clock is stopped, under
  reduced motion or while the widget is outside the canvas viewport, and catches up with one frame on return. Only when drawing imperatively onto a canvas
  do you read `useBoardClock()` and run rAF yourself. Nested widgets read `ctx.clock`; Vue uses `useBoardClock()`.
- **To serve as an ambient layer such as a background**: the platform never tells a widget "you are the background"; to support it, offer a
  switch in the config (like html-embed's `quiet`). When it is on, draw no loading, error, empty-state or notice UI, and clip whatever overflows
  the box; report problems to the author with `useReportLoadIssue()` (a sentence reports it, `null` withdraws it) — they show in the Problems panel.
- **Randomness**: use the deterministic `createRng(seed)` with the seed stored in the snapshot (`seedField()`), so the same snapshot draws the same
  picture on every open and every export. Never use `Math.random()`.

## p5

- `import p5 from 'p5'`. p5 is LGPL and supplied by the platform as a separate file; it is never bundled, inline or nested (nested widgets that use
  it compile only in the cloud).
- Use instance mode only; `draw(p, scene)` draws only what `scene` gives, and you call `show(scene, size)` when the data changes. p5's mouse
  coordinates are wrong under the canvas zoom — when you need the pointer position, remove the zoom yourself from the element's layout size
  (the ratio of `getBoundingClientRect()` to `offsetWidth`).
- Write readouts and labels as a DOM overlay (translatable, readable by screen readers), not into the canvas.

## Maps (Leaflet)

- Import `leaflet/dist/leaflet-src.esm.js` (the ESM build, which does not write a global `window.L`) and take the types from `leaflet`; use the svg
  renderer so paths are DOM and can carry anchors.
- No country or province boundaries are built in; boundary data comes from the author (a GeoJSON file in the workspace, read with `useHostFetch`).
  A tile basemap is optional, with the URL and attribution given by the author; the tile server must allow CORS.
- Give the map container `isolation: isolate`: Leaflet's panes carry z-index 400 and above and would otherwise cover legends and notices.
