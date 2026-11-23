# Widget operations and canvas operations

## Widget operations

When a widget first appears, write `canvas_createWidget`. The `widgetId` + `widgetType` on the operation are the single source; don't repeat them in `args`:

```yaml
- id: bar-chart-sales-create
  widgetId: bar-chart-sales
  widgetType: vizchat/bar-chart
  operation: canvas_createWidget
  args:
    position: { x: 80, y: 200 }
    width: 560 # optional; omitted means the widget's default size
    height: 740
    title: 'Quarterly revenue ($K)' # optional; charts render it as the title — include the unit
    data:
      initialSnapshot:
        content: <the widget's content, written per its operation docs>
```

In `initialSnapshot.config`, write only the fields you change; omitted ones take the widget's defaults. For every other operation,
`args` is keyed by the parameter names in the operation's signature: `setViewport(viewportUpdates, expectedViewport?)` becomes
`args: { viewportUpdates: { center: { x: 2, y: 1 }, dataWidth: 6 } }`; leave out optional parameters you don't use.

For each `canvas_createWidget`, read the narration sentence that triggers it and choose `args.entrance` by what it asks the audience to do:

| That sentence is saying | `entrance` |
| --- | --- |
| The single most important conclusion on the slide (at most one per slide; titles don't count) | `zoom` |
| Explicitly building on the previous conclusion ("next", "building on this") | `rise` |
| Content that unfolds step by step by nature: trends, processes, code | `wipe` |
| Background, decoration, or an element that has been there all along | `none` |

When several rows match, take the higher one. Ordinary content like opening titles and parallel introductions or explanations omits `entrance` and fades in — most widgets on a slide are like this.

A widget's own operations (change data, turn pages, highlight, etc.) are in its operation docs. To "watch it grow" (set up the axes first, then overlay the function, then annotate), create an empty widget first,
then fill it step by step with data operations tied to cues, so each cue has a visible change; when the data is given statically, fill it all at once in `initialSnapshot.content`.

## Canvas operations

Canvas operations go in `operations` just like widget operations, but act on the canvas rather than inside a widget; their names always start with `canvas_` (a widget's own operations never use this prefix).
All widgets support:

| Operation | `args` |
| --- | --- |
| `canvas_highlight` | `{ target: string \| string[], items?: (string \| number \| {})[], style?: "ring" \| "glow" \| "pulse" \| "beam" \| {border, shadow, radius, preset}, others?: "fade", text?: string, angle?: number, distance?: number, frame?: boolean, padding?: number }` |
| `canvas_addEdge` | `{ source: string, target: string }` |
| `canvas_setViewport` | `{ center?: {x, y}, zoom?: number, target?: string \| string[], items?: string[], padding?: number, durationMs?: number }` |
| `canvas_removeEdge` | `{ edgeId: string }` |
| `canvas_createWidget` | `{ position?: {x, y}, width?: number, height?: number, title?: string, data?: any, entrance?: "fade" \| "none" \| "rise" \| "zoom" \| "wipe", frameStyle?: "none" \| {preset, fill, border, shadow, radius, highlight, interaction, accentText, padding} }` |
| `canvas_destroyWidget` | — |
| `canvas_moveWidget` | `{ position: {x, y} }` |
| `canvas_resizeWidget` | `{ width?: number, height?: number }` |
| `canvas_setWidgetTitle` | `{ title: string }` |
| `canvas_reuseWidget` | `{ widgets: {id, position, width, height, entrance}[] }` |

```yaml
# Emphasis: a whole widget or data items inside it, optionally with a caption (see "Emphasis" below)
- id: <operation id>
  operation: canvas_highlight
  args:
    target: <widgetId>
    items: [<itemId>] # optional; omit to emphasize the whole widget
    style: ring # optional ring (default) | glow | pulse | beam
    text: <caption> # optional
    angle: 0 # optional — direction of the caption card from the target in degrees: 0 above (default), 90 right, 180 below, 270 left; any angle in between works
    distance: 40 # optional — gap between the card and the target in canvas pixels, default 40
    others: fade # optional; also dims the other widgets (and the other items in this one)

# Edge
- id: <operation id>
  operation: canvas_addEdge
  args: { source: <widgetId>, target: <widgetId> }

# Viewport: pan and zoom the canvas to focus attention on an area
- id: <operation id>
  operation: canvas_setViewport
  args:
    center: { x: 960, y: 540 }
    zoom: 1.5 # relative to the whole page: 1 = whole page, 2 = twice as close
    durationMs: 600 # optional, 0–5000; omitted means a smooth push-in

# The viewport can also point straight at widgets: write target (same form as canvas_highlight) instead of center and zoom;
# the canvas centers on the target and goes as close as fits it (never farther than the whole page, at most 4× closer)
- id: <operation id>
  operation: canvas_setViewport
  args:
    target: <widgetId> # or a list of several widget ids, framed together; for a pinned widget, write its id too
    items: [<item id>] # optional, point at just these data items in the widget (single target only)
    padding: 40 # optional, space kept around the target (canvas pixels), default 40
```

Pointing at widgets is sturdier than working out center and zoom by hand: if a widget moves or is resized, the camera still
lines up. When you push in on a chart and then `canvas_highlight` its items one by one under the same camera, write the same
`target` in both — the camera and the emphasis each keep their own lifetime.

### Emphasis

"Look here" in a narration is a single operation, `canvas_highlight`, with three independent choices:

- **What to emphasize**: without `items` it is the whole widget; with them it is data items inside it — usually item ids,
  though some widgets take their own shape (code-viewer takes line numbers, pdf-viewer a region on a page, data-explorer a
  filter condition); see the `highlight` entry in that widget's operation docs. When `target` is a list of several widget ids,
  the canvas draws one frame around them together (`items` is not allowed then).
- **Whether to add words**: `text` puts a caption card next to the target; `angle` sets which direction it sits in and `distance` how far away. Whether the card covers the widget's title,
  legend or another widget, check in a screenshot taken at that cue (`cues` of `render_board`); if it does, change the angle or move it further out.
- **How to emphasize**: `style` picks a preset — `ring` marks it (default), `glow` makes it stand out strongly, `pulse`
  draws the eye, `beam` runs a streak of light along the border; `others: fade` pushes everything else back.

Who draws it is decided for you: emphasis on a whole widget is drawn by the canvas; emphasis on data items is handed to the
widget to draw its own way (a tinted row, an outlined bar, a thicker line), and when the widget has no way of its own, the
canvas draws a frame where the items are. Write `frame: true` to get the canvas frame instead of the widget's own drawing. When the target is a pinned widget, the canvas always draws the frame.
Frames the canvas draws leave 8 pixels between the frame and what it surrounds by default; `padding` changes this. A preset
emphasis on a whole widget is drawn on the widget's own border and is not affected.
Emphasis follows its target: while it is active, it is safe to send data operations (add data, change config) to the target
widget — the frame moves and scales with the content.

Several emphases on the same widget at once all show together, and each is removed when its own range ends; none replaces another.

`canvas_highlight` versus a widget's own `highlight` operation: `canvas_highlight` is temporary emphasis while one sentence
is spoken — pair it with a range cue and `transient: true` and it is taken back when the sentence ends. When the emphasis
should **stay and move down slide by slide** (walking through code a block at a time, stepping through questions on an
exam page), send the widget its `highlight` directly — each one replaces the previous spot — and send `clearHighlight` to take it back.

### Labels

In drawing widgets (coordinate plane, solid geometry, circuit, lab apparatus, molecule, membrane, celestial sphere and the like), object labels are hidden by default; write out the ones to show: `showLabel: true` on the object, or the widget's `setLabels` during the narration to say which are shown at this moment. The main form is `{ only: [ids] }` — show exactly these and hide the rest, so each step states its own set and you don't track what earlier steps turned on; there are also `{ show: [ids] }`, `{ hide: [ids] }` and `{ hide: 'all' }`.

```yaml
- id: forces-step2
  widgetId: incline
  operation: setLabels
  args: { only: [mg-perp, friction] }
```

Label only what the current step talks about: with too many labels the reader can't tell which to look at.

### Reusing across slides

To use widgets created on an earlier slide, write a `canvas_reuseWidget` where they first appear on this slide; when the cue fires, they appear with their accumulated state.
Widgets that appear at the same moment go in one operation: list them in `args.widgets` and don't put a `widgetId` on the operation:

```yaml
- id: sales-reuse
  operation: canvas_reuseWidget
  args:
    widgets:
      - { id: bar-chart-sales, position: { x: 980, y: 200 } } # position, size and entrance are all optional and apply only to this appearance on this slide (they don't carry over from creation)
      - { id: sales-note }
```

Other operations on these widgets on this slide come after this one (inside the same cue, placing them later in the `operations` array also works).

If the widget was still on stage at the end of the previous slide and should stay there, put this reuse at the very start of the narration (the marker before the first character). On the page turn the widget stays in place without replaying an entrance,
and slides smoothly over if this slide gives it a different position or size; write `entrance` explicitly to make it enter again. A reuse placed later in the narration makes it disappear on the page turn
and reappear when the narration reaches it (`check_board` flags this). State operations on it (`reveal`, content or data changes) placed after the reuse in that opening cue
run when the narration starts and play their change like operations later in the narration.

### Transient operations (undone once narrated)

Elements added temporarily while explaining — temporary edges, temporary highlights, a temporary zoom-in — get `transient: true` and go in a range cue; they are undone automatically at `{@id:end}`,
so you don't write removal steps yourself:

```yaml
markedText: '{@rel:start}Notice that every jump in revenue follows a user expansion. {@rel:end}So growth is rooted on the user side.'
cues:
  - id: rel
    operations:
      - id: rel-link
        operation: canvas_addEdge
        transient: true
        args: { source: line-users, target: bar-revenue }
```

One passage maps to one range cue: transient operations in the same cue are undone together at its `end`. When temporary elements need to enter and leave at different times, split them into several range cues.
