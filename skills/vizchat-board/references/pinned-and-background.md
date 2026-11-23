# Pinned widgets and canvas backgrounds

Pinned widgets (`pinned.widgets[]`) are declared once and appear on every slide. To choose between a pinned widget and reuse across slides, ask one question: **can this widget's state on slide N
be computed from slide N alone?** Yes → pinned widget (page numbers, titles, watermarks, footers, and also an exam-paper PDF that turns to a different page and highlight region for each question);
no, it depends on what accumulated before → `canvas_reuseWidget`. It follows that:

- Reading slide context through bindings → pinned widget;
- Being selected and dragged by the user → reuse; having the widget draw its own data-item emphasis (a tinted code line, an outlined bar) → reuse. `canvas_highlight`
  and the `target` of `canvas_setViewport` can name a pinned widget's id too (unless this slide hides it), but data-item emphasis on a pinned widget is always a canvas frame;
- Pinned widgets don't remount when the slide changes, so heavy assets suit them too;
- Content that is on every slide and whose state doesn't build up through the narration (the blocks and charts of a poster the camera moves across) → pinned widget, rather than reusing it on every slide.

```yaml
slides:
  - id: cover
    title: 'Cover'
    pinnedOverrides: # optional, overrides for this slide: hidden / position / size / config / title / frameStyle
      page-num: { hidden: true }
pinned:
  widgets:
    - id: page-num # stable id, also the key in pinnedOverrides
      widgetType: vizchat/rich-text
      position: { x: 1620, y: 960 } # footer band; pinned widgets touching the edge is normal
      size: { width: 220, height: 100 }
      snapshot:
        content: '1 / 1' # static default; overridden by bindings, and the fallback when evaluation fails
        config: {}
      bindings:
        content: "slide.number + ' / ' + slides.length" # jexl expression
```

- `pinnedOverrides.<id>.config` is deep-merged into the master: writing only `navigation: { targetPage: 3 }` keeps the master's other fields in that section; to clear a field, write `null` explicitly (e.g. `targetRegion: null`). Arrays are replaced whole. Don't put an optional field in the master that only some pages want — a per-page override cannot remove it. `config.*` bindings may use nested paths (`config.params.hue`).
- Hiding precedence: `pinnedOverrides` > `bindings.hidden` > `hidden` on the widget.
- `title` and `frameStyle` mean the same as on slide widgets (the widget draws its own title; the host draws the frame). A frame comes only from what the pinned widget itself declares: the document-level and per-type frame defaults
  apply only to slide widgets, so decorations such as backgrounds and page numbers are not boxed. Change them per slide with `pinnedOverrides.<id>.title` / `.frameStyle` (`frameStyle: none` removes the frame on that slide).
- A storyboard created in the UI comes with a bottom-right page number with id `default-page-number`; when you create one by writing complete YAML, it is not added automatically — write it yourself if you need page numbers.

Editing pinned widgets by path:

| To do | path | action |
| --- | --- | --- |
| List all | `pinned.widgets` | `get` |
| Add | `pinned.widgets` | `append` |
| Delete | `pinned.widgets[?id='X']` | `delete` |
| Change a binding | `pinned.widgets[?id='X'].bindings.content` | `set` |
| Change position / size / static content | `pinned.widgets[?id='X'].position` (`.size`, `.snapshot.content`) | `set` |
| Hide on a slide / override position / size / config | `slides[?id='S'].pinnedOverrides.X.hidden` (`.position`, `.size`, `.config`) | `set` |

## Canvas background

A background is just an ordinary pinned widget: a `vizchat/html-embed` that **covers the whole canvas and comes first in the pinned list**
(the bottom layer). The platform does not decide what the background is — geometry and stacking come from these two alone. Set
`config.quiet: true` (quiet presentation): nothing is drawn while loading, on error or with no source, overflow is clipped, and problems go to the
Problems panel, so viewers never see technical UI.

A background can only be a pinned widget. Pinned widgets as a whole sit below the slide's own widgets and stack among themselves in `pinned.widgets` order, later ones covering earlier ones — so the background goes first,
with the page number and slide title after it. Slide widgets sit above every pinned widget: a slide widget that fills the canvas covers the page number and title, and dims along with the rest under `others: fade`
(`check_board` reports G5 for it). A background used on only some slides: set `hidden: true` at document level and turn it on for those slides with `pinnedOverrides` (see "Switching backgrounds" below).

Start with html-embed's built-in **presets**: `source: { kind: preset, value: <name> }`. No file to add; all of them follow the document theme and switch to a pale version in light mode. Pick by scene:

| Name | Looks like | Good for |
| --- | --- | --- |
| `paper` | Grid paper | Worked examples, diagrams, science lessons |
| `desk` | A quiet surface with a faint dot grid | Charts, tables, business data |
| `space` | Night sky (a pale dawn in light mode) | Astronomy, 3D, physics |
| `nature` | Soft drifting greens | Biology, geography, the environment |
| `plain` | The theme background | Documents, widgets that fill the page themselves |
| `glow-blobs`, `flowing-gradient`, `neon-grid`, `grain`, `aurora`, `shader-aurora`, `shader-mesh-gradient` | Animated color fields | Covers, section openers |

Parameters: `tint` (any CSS color), `speed`, `intensity`; the animated color fields also take `hue`. Write your own background HTML (`kind: document`, see below) only when no preset fits.

```yaml
pinned:
  widgets:
    - id: bg # first: a background after the page number covers it (geometry check G4 reports an error)
      widgetType: vizchat/html-embed
      position: { x: 0, y: 0 }
      size: { width: 1920, height: 1080 } # match the canvas size (config.canvas)
      snapshot:
        content: { source: { kind: preset, value: aurora } } # or your own HTML: { kind: document, value: <ref> }
        config: { params: { hue: 210 }, quiet: true } # --hue on the page root; quiet presentation
      bindings:
        config.params.hue: "200 + slide.index * 2" # a regular change
    - id: page-num
      # …
slides:
  - id: p37
    pinnedOverrides:
      bg: { config: { params: { hue: 0 } } } # one slide differs; the other params stay
```

- Scripts in the background HTML run (isolated sandbox, no access to the canvas or storage, https resources allowed); scripts can also read
  the params via `window.vizchat.params` / `window.vizchat.onParams(cb)`. Write the animation as a pure function of time: CSS `@keyframes`
  work as is; `requestAnimationFrame` / `performance.now` / `Date` in scripts are taken over by the platform and follow the presentation's
  timeline. Animation that accumulates frame by frame (particles adding velocity each frame) jumps on page jumps in a background that stays
  across slides, and video export has to re-render around it, noticeably slower — don't use it there; a decoration that appears on one slide
  only can use it (see "Animated shader backgrounds" below).
- Switching backgrounds: `source` cannot be overridden per slide, so each background is its own pinned widget, `hidden: true` at document
  level, and each slide opens its own with `pinnedOverrides.<id>.hidden: false`; all of them come before the page number.
- Choosing a preset or an HTML file from the workspace under "+" → "Background" in the Pinned widgets group of the property panel does the same: the panel inserts such a pinned widget at the front; in its page, "Page" can switch to another preset or file.

### Animated shader backgrounds

A background page can `import` the libraries that ship with html-embed by name, without writing a URL; today that is `shaders/core` (WebGPU shader effects), and its version
follows html-embed's version. For animated backgrounds such as auroras, flowing gradients and noise, use it:

```html
<!doctype html>
<style>
  html, body { margin: 0; height: 100%; }
  /* Fallback: without WebGPU (covers rendered on the server, browsers without it) this layer is what shows — same colors as the shader */
  body { background: radial-gradient(120% 80% at 70% 0%, #7c3aed 0%, transparent 60%), #05060a; }
  canvas { position: fixed; inset: 0; width: 100%; height: 100%; opacity: 0; transition: opacity 0.4s; }
  canvas.ready { opacity: 1; }
</style>
<canvas id="c"></canvas>
<script type="module">
  import { createRendererFromJSON } from 'shaders/core';
  const canvas = document.getElementById('c');
  const r = createRendererFromJSON({
    components: [{ type: 'Aurora', props: { colorA: '#7c3aed', colorB: '#22d3ee', speed: 3 } }],
  });
  r.setOnUnavailable(() => canvas.remove()); // can't draw: let the fallback show
  await r.initialize(canvas);
  // Advance by time: record the seconds advanced before the await, so playback, seeking and video export agree
  let advanced = 0;
  const frame = async () => {
    const target = performance.now() / 1000;
    const delta = target - advanced;
    advanced = target;
    requestAnimationFrame(frame);
    await r.renderFrame({ deltaSeconds: delta });
    canvas.classList.add('ready');
  };
  requestAnimationFrame(frame);
</script>
```

- Pick effects by **where they go**:
  - A background that stays across slides (a pinned widget) or a widget reused across slides uses only effects whose picture depends on
    time alone: `Aurora`, `FlowingGradient`, `MeshGradient`, `Plasma`, `Nebula`, `SimplexNoise`, `FractalNoise`, `Godrays`.
  - A local decoration that appears on one slide only (a `vizchat/html-embed` created on that slide, not reused, and not filling the canvas) can also use simulations
    that grow over time: `ReactionDiffusion`, `Smoke`, `Boids`, `ParticleFlow`, `InkFlow` and the like — they start over each time the slide
    is entered, so video export matches sequential playback; in a background that stays across slides they jump on page jumps and make video export
    re-render, slower.
  - Don't use the default media of `ImageTexture` / `VideoTexture` (they point at a third-party site).
- Colors follow the theme: the page root carries every color of the current theme and mode as `--vz-<token>` (`--vz-background`, `--vz-foreground`, `--vz-primary` and so on), the mode is set as `color-scheme` and `data-vz-scheme`, and scripts read them from `window.vizchat.theme` / `onTheme(cb)`; they update on a theme change without a reload. Keep the background's lightness on the same side as `--vz-background`, or the widgets' secondary text becomes hard to read. Your own values such as hue or intensity go in params (`config.params`; keys starting with `vz-` are reserved); the fallback gradient uses the same colors.
- A background that never stops moving makes video export render every frame, noticeably slower — use it only on the boards or slides that need it.

## Binding expressions (jexl)

Available fields: `slide.index` (from 0), `slide.number` (from 1), `slide.title`, `slide.id`; `slides.length` (the total only, no `slides[i]`);
`document.canvas.width`, `document.canvas.height` (canvas size in pixels); `date.now` (`YYYY-MM-DD`), `date.year`, `date.month`, `date.day`, `date.iso`.

Transforms are written as a pipe `x | f` or a function `f(x)`; the two are equivalent:

| Name | Signature | Example |
| --- | --- | --- |
| `upper` | `(s) => string` | `slide.title \| upper` |
| `lower` | `(s) => string` | `lower(slide.id)` |
| `pad` | `(s, len, ch='0') => string` | `slide.number \| pad(3)` → `001` |
| `trunc` | `(s, len, suffix='…') => string` | `slide.title \| trunc(20)` |
| `len` | `(arr\|s) => number` | `len(slide.title)` |
| `format` | `(dateStr, pattern) => string` | `format(date.iso, 'YYYY/MM/DD')` |
| `includes` | `(arr, item) => boolean` | `includes(['cover', 'end'], slide.id)` |
| `if` | `(cond, a, b) => any` | `if(slide.index == 0, '', slide.title)` |

```yaml
content: "slide.number + ' / ' + slides.length"   # N / M
hidden: 'slide.index == 0'                         # hidden on the cover
position.x: 'slide.number % 2 == 0 ? 900 : 100'    # different position on odd and even slides
content: "format(date.iso, 'MM/DD/YYYY')"
```

jexl uses `==`, not `===`, supports `in` (`slide.id in ['cover', 'end']`), and method calls are written as transforms (`upper(s)`, not `s.toUpperCase()`).
When binding `config.*`, the valid paths are set by that widget's config schema; check its operation docs first.

**When evaluation fails, the display silently falls back to `snapshot` with no error**: after writing a binding, read it back to confirm the expression was stored correctly, and ask the user to refresh to see the effect.
