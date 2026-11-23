# Theme and styles: look up when needed

## Text without a fill, and light-background notices

- `destructive` / `warning` / `success` / `info` / `cat-1`…`cat-6` also have `text-<role>-ink` — plain text with no fill (the base color on a light background lacks the contrast body text needs,
  hence this level). `secondary` / `accent` have no `-ink`; writing it fails compilation. `text-primary-ink` is generated but uses the platform brand color and doesn't change with the theme.
- Surface colors and `primary` / `secondary` / `accent` / `destructive` come from the document's theme; `warning` / `success` / `info` / `cat-*` and the `-ink` levels are provided by the platform
  and don't change with the theme.
- For light-background notices use opacity steps rather than inventing tokens:


```tsx
<div className="border-warning/30 bg-warning/10 text-warning-ink rounded-md border px-2 py-1">{message}</div>
```

## Colors must work in both light and dark

A widget can land in any variant of any theme. The token table in the main file's "Both light and dark must work" covers UI colors; this section covers every other color.

**Every color field an author can pick uses `themeableColor()`** — text colors, line colors, colors of data items and geometric objects alike. The value is a hex, or a theme reference
`{ token: foreground }` (names you can reference: `background` / `foreground` / `card` / `popover` / `primary` / `secondary` / `muted` / `accent` /
`destructive` with their `-foreground`, plus `border` / `input` / `ring`, the categorical colors `chart-1`–`chart-8` with their `-foreground`, and the sequential ramp `chart-seq-1`–`chart-seq-7`); a reference follows the theme and the variant, a hex is the same in both. Say in `.describe()` that a reference is recommended.
A bare `z.string()` or a string with a hand-written hex regex is not recognized as a color in the property panel and gets no color picker. `themeableColor()` and `themeColorCss` are imported from `@vizchat/widget-sdk`.

```ts
color: themeableColor().default({ token: 'foreground' }).describe(
  'Line color. Prefer a theme reference ({ token: foreground }) so it follows light/dark; a hex stays the same in both.',
),
```

**DOM / SVG: write it out through `themeColorCss(color)`** — a reference becomes `var(--vz-foreground)`, resolved by the CSS cascade, so switching variants needs no re-render. Text that sits on this color uses
`getContrastColor(color)`: for a hex it picks black or white by luminance, for a reference it takes the paired foreground (`{ token: primary }` → `var(--vz-primary-foreground)`).

```tsx
<path stroke={themeColorCss(item.color)} />
<text fill={getContrastColor(item.color)}>{item.label}</text>
```

**Series colors work the same way**: in the array `getColorScheme(scheme)` returns, the `theme` scheme (the document theme's 8 derived categorical colors, distinct from one another in any theme) gives `{ token: 'chart-N' }` references and the other schemes give hex.
As with color fields, write them out with `themeColorCss` and take the text color on top with `getContrastColor`; don't put them into `fill` directly. In the `readChartTheme` / `useChartTheme`
snapshot for third-party chart libraries, `palette` is already resolved to hex.

**Sequential ramps follow the theme**: to map values to colors (heatmaps, choropleth maps, filled contours) use `getSequentialScheme()` — the document theme's 7-step ramp `{ token: 'chart-seq-N' }`,
where 1 is closest to the background and 7 the most prominent, lightness is monotonic across steps, and it holds on both variants. For bins, sample steps evenly (always keep both ends); for a continuous scale, interpolate between neighboring steps. Canvas and
third-party libraries use `colors[ref.token]` (`useThemeColors`) or the snapshot's `sequential` (already resolved to hex). Don't mix your own from the background toward the primary color: the light end of such a mix sits right on the background in some themes and can't be seen.

**canvas 2D / WebGL (three) don't understand CSS variables**: resolve the reference into an actual color before drawing, and re-read and redraw **whenever the theme changes** (a different preset or a different variant). The SDK's values and signals are the recommended way:

- inline: `useThemeColors(rootRef)` (`@vizchat/widget-sdk/react`) returns the whole theme palette (`#rrggbb`; `null` until first read) and updates when the host switches preset or variant;
  draw in an effect that depends on it, and resolve references with `colors[ref.token]`.
- nested: `observeThemeColors(ctx.root, ctx.theme, (colors) => …)` (`@vizchat/widget-sdk`) reads once right away, calls back when the theme changes, and returns a stop function.
- Listening only to light/dark (`useHostColorScheme(rootRef)` / `data-theme`) misses "preset changed, variant didn't" — presets are written on the canvas container, and the variant often stays the same.
- To control when to read yourself: `readThemeColors(el)` reads the whole palette, `normalizeCssColor(value)` normalizes any CSS color (including `oklch()`) to hex, and the `theme` signal
  (`ctx.theme`, or `theme` on the mount context) tells you when to re-read.

**Defaults are promises too**: the colors in the default snapshot and the schema defaults must be readable in the dark variant. Dark colors such as `#000000`, `#111827`, `#333`, `#374151` reach only
1–2:1 on a dark background; make them `{ token: foreground }`. Use `border` for grids, `muted-foreground` for axes and helper lines, `background` for the halo stroke around points.

**Only two kinds of color may be hard-coded hex**: semantic colors (a peak in red, red/green for down/up, a color a textbook convention fixes) and mid-saturation categorical colors (the `#3B82F6`, `#DC2626`, `#059669` range).
Before writing one, check its contrast against the background of both variants: ≥ 3:1 for graphics, ≥ 4.5:1 for text. Dark ones (`#1E40AF`) fail in the dark variant and light ones (`#FDE68A`) fail in the light variant, so neither can be a line or text color.

**Self-check**: `check_widget` (locally `vizchat widget check`) renders the dark variant — compare the light and dark screenshots page by page, looking for lines, text or points that disappear; then look again under another theme.

## Handing light/dark to third-party libraries

Libraries such as code highlighters and infographics come with light / dark theme parameters and don't read CSS variables; get the current variant in JS and pass it in:

- **inline widget**: `useHostColorScheme(rootRef)` (`@vizchat/widget-sdk/react`) returns `'light' | 'dark'`, and the component re-renders when it changes.
  **Pass the widget's own root element**: a board can lock light/dark (`colorMode: dark`); the variant is then set on the canvas container while `<html>` keeps the reader's;
  without the ref you only get the latter, and in a board locked to dark the library draws in light. Factor it into the theme parameter passed to the library, and into the dependencies for rebuilding the instance — reading it only on first render freezes light/dark at that moment.

```tsx
const scheme = useHostColorScheme(rootRef);
const libTheme = config.theme === 'auto' ? scheme : config.theme;
```

- **nested widget**: `readHostColorScheme()` reads the current variant and `observeColorScheme(cb)` calls back when light/dark switches (both in `@vizchat/widget-sdk`). A theme change doesn't call
  `render` again; subscribe to follow it:

```ts
applyLibTheme(readHostColorScheme());
observeColorScheme((scheme) => applyLibTheme(scheme));
```

## Turning off a third-party library's background and sizing

A widget draws only its content and its root paints no background: the panel and frame belong to the board's `frameStyle` and are drawn by the host (see "The host draws the panel and frame" in the main file).

- Third-party renderers usually paint white by default; turn it off explicitly: three's `WebGPURenderer` with `alpha: true` and no clearColor / `scene.background`; for SVG / canvas libraries find their
  background option (e.g. `@antv/infographic`'s `svg: { background: false }`).
- SVG libraries that set only a `viewBox` from the content's bounding box and no width/height render "full width, height by aspect ratio", so tall content overflows and is clipped; size the SVG yourself. When the library hard-codes its font sizes,
  don't stretch it to the frame (the text would then grow and shrink with the frame): give it a width and height at a fixed scale that puts the library's body text on `body-medium` (`viewBox` size × scale), plus
  `max-width: 100%; max-height: 100%`. A larger frame leaves space around it; a smaller one shrinks it through the `viewBox`, and the smaller text is reported by the review (`@vizchat/infographic` does this).

## Keys not every theme has

Theme keys other than color — radius, fonts (`font-sans` / `font-serif` / `font-mono`), shadows — aren't provided by every theme.
You can use them, but must accept their absence:

- Use `rounded-*` and `shadow-sm` / `shadow-md` / `shadow-lg` as usual: when the theme gives no value, the platform default applies.
- Don't set a font for body text: when there is a theme, its font reaches the widget by inheritance. `font-sans` / `font-serif` / `font-mono` are the platform's font stacks and override the theme font;
  write them only when you truly need a kind of font (such as monospace for code).
- When hand-written CSS references these variables directly (`var(--vz-font-serif)`, `var(--vz-font-mono)`) and the theme lacks the key, the variable doesn't exist — the whole declaration is dropped, not reverted to a default.
  Always give a fallback: `var(--vz-font-serif, serif)`. Theme variables on the canvas all carry the `--vz-` prefix; color variables have a value under every theme (with no theme chosen, the app default theme).

## Hand-drawn (line style)

Themes have a `stroke-style` dimension (`clean` | `sketch`): sketchbook, whiteboard and notebook are hand-drawn. Whether a widget supports it is
declared by `appearance.strokeStyle: strokeStyleField()` in its config schema (`auto` follows the theme, `clean` / `sketch` force) — **having the field is the
declaration**; widgets without it keep clean lines under a sketch theme. Add it only when you control how primitives are drawn; don't add it for libraries that draw
primitives internally (ECharts, Vega, Plotly).

- d3 charts (`d3View` + `D3BaseRenderer` / `D3ChartRenderer`): adding the field is all it takes. After each frame the renderer gives `rect` / `line` / `circle` /
  `path` … a hand-drawn layer, and transitions registered with `this.track(...)` redraw it frame by frame; keep drawing clean primitives. Mark primitives that
  should stay clean with `data-vizchat-no-sketch`.
  The hand-drawn layer is only fitted during `render`: when you change primitives outside it (hover changing opacity, redrawing on your own
  zoom/pan listener), keep it in step — call `this.resketch(element)` after an immediate change, `this.refreshSketch()` after a full redraw, and wrap
  pointer-driven transitions that must not delay readiness in `this.followSketch(transition)`. Miss it and such changes are invisible under
  sketch, or the clean primitive shows up next to a hand-drawn layer stuck at the old position.
- Hand-written SVG (React): `const style = useStrokeStyle(rootRef, config)`; when sketch, `createPen({ style })` (`@vizchat/widget-sdk/pen`) and
  `pen.sketchPaths(shape, { stroke, fill, strokeWidth }, { seed })` give the paths; keep the original primitive as a transparent hit target and anchor.
- canvas: `pen.drawCanvas(ctx, shape, paint, { seed })` — one call for both clean and sketch; resolve colors to values first (canvas doesn't read `var()`).
- nested: read `ctx.strokeStyle(config)` inside `render` and subscribe to `ctx.theme` to redraw when the theme changes.
- Determinism: seed each primitive with `seedFromId(item id)` and reuse it every frame — thumbnails, video export and slide jumps then draw the same thing.

## CSS imports

Your own `.css` files: `import './my.css'`; CSS shipped by an npm package: `import 'some-pkg/theme.css'`. Hand-written CSS classes (`.my-thing`) and pure marker classes used only for `querySelector`
are not subject to the compile-time class lookup — that only covers Tailwind utility classes.
