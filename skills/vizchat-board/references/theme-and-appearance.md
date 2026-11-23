# Theme and appearance

`config` sets the look of the whole document; write it when creating, and the whole document follows it:

```yaml
config:
  canvas: { width: 1920, height: 1080 } # canvas size in pixels; pick it by use (see the canvas and layout reference)
  theme: graphite # color theme, e.g. graphite / notebook / elegant-luxury
  background:
    base: { kind: solid, color: { token: background } } # or kind: gradient
  widgetDefaults: # default config per widget type; fields an instance doesn't set come from here
    vizchat/rich-text:
      config:
        typography: # each level's size is a type style name; use pt only when there is a specific reason
          h1: { fontSize: headline-large, color: { token: foreground } }
          p: { fontSize: body-large }
    vizchat/bar-chart:
      config:
        appearance: { colorScheme: business }
```

- Font sizes: every widget shares one fixed type scale (15 type styles: display / headline / title / body / label × large / medium / small,
  from label-small 12pt to display-large 80pt), and a style is the same size on every board. Font-size fields in widget config take a style name (`body-large`,
  `title-large`); write pt only when there is a specific reason, and no smaller than label-small's 12pt (the review flags anything smaller). Sizes don't vary per document: to make text look bigger on screen or
  fit more content, change the canvas size (see the canvas and layout reference), not the font size.
- Every theme has a light and a dark variant that follows the viewer's setting; the document must be readable in both. Write background colors as theme references `{ token: background }` (also
  `card` / `muted` / `accent` / `primary` / `border`, etc.), which change with the variant; a hard-coded `'#f0f0f0'` stays the same in the dark variant, and light text on it becomes unreadable.
  The same goes for text color: write rich-text's `typography.*.color` as `{ token: foreground }` / `{ token: muted-foreground }` / `{ token: primary }`;
  a hard-coded dark hex sits on the dark background in the dark variant and the whole heading disappears. Geometry and lines are no different: write the colors of function curves, points, segments and axes as `{ token: foreground }` /
  `{ token: muted-foreground }` instead of copying `#333333` or `#111827` from how the light variant looks. Only semantic colors are hex (a peak in red, a color a textbook convention fixes), and they must stay visible in both variants —
  a dark hex disappears in the dark variant and a light one in the light variant. Subtitle `color` / `bgColor` are the exception and take hex only: subtitles sit on their own box and don't change with the variant. When done, switch to the dark variant and look at every page.
- Widget frame `frameStyle`: gives widgets a box — fill, border, shadow, corner radius. `config.frameStyle: { preset: glass }`; the presets are `hairline` / `glass` /
  `spotlight` / `float` / `bento` / `beam` / `neon` / `brutal` / `clay` / `tilt` / `soft-glass`, and any attribute can be overridden (`{ preset: glass, radius: 28 }`).
  Leaving it out means no frame — clean teaching boards leave it out. Each widget declares whether it follows: text meant to float on the background (body text, cover, countdown) takes no frame,
  photos and PDFs take only the frame's corners and shadow, and the code panel keeps a solid panel even without a frame. Override one widget type under `widgetDefaults.<type>.frameStyle`
  and one instance with `args.frameStyle` on its `canvas_createWidget` (`frameStyle` on the node in dashboards); `'none'` means this layer explicitly wants no frame.
  Boards with a colorful background need a frame: small-text widgets such as tables and data explorers are transparent without one and become unreadable on color.
- Light / dark `colorMode`: `auto` (default) follows the viewer's setting; `light` / `dark` locks one variant — lock `dark` for a pitch deck meant to look one way.
  `neon` and `beam` only work in dark, so their boxes are drawn dark even in the light variant.
- Canvas background (storyboards only): just an ordinary pinned widget — a `vizchat/html-embed` that covers the whole canvas and comes first in
  the pinned list (the bottom layer), referencing a background HTML file in the workspace, with `config.quiet: true` (nothing is drawn while
  loading or on error; problems go to the author). Put colors, speed and the like in `config.params` (CSS variables on the page root); vary them per slide
  with `bindings` or `pinnedOverrides` — the background is not rebuilt on a page turn. Write the animation as a pure function of time (CSS
  `@keyframes`, or scripts reading the time the bridge takes over) so playback, seeking and video export agree. It must come before
  other pinned widgets such as the page number, or it covers them. See the reference on pinned widgets and canvas backgrounds (animated shader
  backgrounds such as auroras and flowing gradients use `shaders/core`, which ships with html-embed; it has a template); ready-made backgrounds are html-embed's built-in presets (`source: { kind: preset, value: <name> }`, following the theme); that page also has the list to pick from by scene.
- rich-text shrinks its font size proportionally by default when the text doesn't fit (with no floor), so the size you set is only a ceiling: when text renders smaller than set, enlarge the frame or cut text — raising the size does nothing (with the frame unchanged
  it shrinks even more). The review flags text shrunk below 70% of its size.
- Use `colorScheme` for colors instead of writing `color` on each data item: it is functional, so items the user adds later automatically get harmonious colors. Write `color` only for semantic colors —
  marking one item out (a peak in red `#ef4444`), or a geometric object that needs a fixed color.
- A bar chart without `color` has all bars the same color, and that is right: height already encodes size, so coloring by order double-encodes; to highlight one bar, give that bar its own `color`.
  Each slice of a pie chart is a different category; leave it to `colorScheme`.
- `colorScheme: theme` (the chart default) makes a chart use the document theme's 8 categorical colors, and they change with the theme; in every theme those 8 colors are distinct from one another and readable on both variants' backgrounds,
  so parallel categories in several lines or a pie chart work as is. The other schemes (`default`, `business` and so on) don't depend on the theme; switch to one only to keep the same colors across themes.
- When writing colors, reference the categorical colors `{ token: chart-1 }`–`chart-8` for parallel categories; for ordered or ranked values (heat, density, levels) reference the sequential ramp `chart-seq-1`–`chart-seq-7`,
  where 1 is closest to the background and 7 the most prominent — larger values take later steps.
- Put the chart's unit in the title (`'Quarterly revenue ($K)'`); when it doesn't fit in the title, use the axis title in the widget config.
