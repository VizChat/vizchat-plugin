# Styling: light and dark, the canvas type scale, fill and frame

The compiler generates the Tailwind classes for each widget separately: whatever is in your source exists.

## Both light and dark must work

A widget can be placed into any variant of any theme: the document picks a theme, and every theme has a light and a dark variant that follows the reader's setting. Hard-coded UI colors (text, borders, backgrounds, hints)
will mismatch in one of the variants, so always use the tokens in the table below for these colors, and write no `dark:` variants for dark — tokens switch with the variant themselves. Same for d3 / SVG:
`.style('fill', 'var(--vz-muted-foreground)')`, not `'#666'`. Theme variables on the canvas all carry the `--vz-` prefix (`--vz-primary`, `--vz-border`);
write Tailwind class names as usual (`bg-primary`) — the compiler points them at the canvas variables.

| Category | Available |
| --- | --- |
| Layout / sizing / typography / flex / grid / arbitrary values (`max-w-[60%]`) | Fully open |
| Surface colors (UI backgrounds, text, lines) | `bg-background` + `text-foreground`; `card` / `popover` / `muted` / `accent` / `secondary` with their `-foreground` (e.g. `bg-muted` + `text-muted-foreground`); `border-border`, `border-input`, `ring-ring` |
| Role colors | `bg-primary`, `bg-destructive`, `bg-warning`, `bg-success`, `bg-info`, `bg-cat-1`…`bg-cat-6`, each with `text-<role>-foreground` (text on that fill) |
| Tailwind's default palette (`text-emerald-700`, `bg-slate-100` …) | Not generated; using it fails compilation and names the class |

There are also `transparent` / `current` / `inherit`; `white` / `black` are generated but don't change with the variant, so don't use them for UI colors.

- Follow the theme fully or not at all: if following, take background and foreground in pairs (`bg-card` with `text-card-foreground`); half following and half hard-coded hex guarantees readability problems in the dark variant.
- Author-pickable color fields use `themeableColor()`, with defaults readable in dark; drawing them and when hex is fine: see the reference on colors and theming.

## Canvas font sizes

On the canvas 1pt = 2px and the default canvas 1920×1080px = 960×540pt, the same shape as a 16:9 PowerPoint slide. Choose font sizes by **use**, not by size: canvas typography has 15 styles
(display / headline / title / body / label × large / medium / small; the names, line heights, weights and tracking follow Material 3), and each style has one **fixed size**
— axis ticks are the same size in every widget on every board. Sizes don't change per document: an author who wants more or less information on the page changes the board's canvas size (the canvas scales to the screen as a whole),
and a widget is tuned and tested against this one set of sizes only.

| Use | Class | Size |
| --- | --- | --- |
| Secondary text (toolbars, line numbers, badges, notes) | `text-label-small` | 12pt |
| Axis ticks, legends, value labels, table cells | `text-label-medium` | 14pt |
| Dense body text | `text-body-small` | 14pt |
| Axis titles, button text, small headings | `text-label-large` / `text-title-small` | 16pt |
| Body text, code, empty states | `text-body-medium` / `text-body-large` | 17 / 20pt |
| Card subheadings | `text-title-medium` | 20pt |
| Card and chart titles | `text-title-large` | 24pt |
| Page titles | `text-headline-small` … `text-headline-large` | 28 / 32 / 40pt |
| Cover text, big headline numbers | `text-display-small` … `text-display-large` | 48 / 60 / 80pt |

Each class carries four properties: size, line height, weight and tracking. Inline styles and config fields use the same set from the SDK: `typeStyleProps('label-medium')` (all four),
`typeStyleCss('label-medium')` (size only); when d3 / canvas needs a number, use `typeStyleSizePx('label-medium', el)` or
`chartTypography(el)` (px computed from the canvas variables at the element). React drawing that lays out by text width (ranking labels, leaving room for a word column, deciding whether a label goes left or right) uses
the react entry's `useTypeStyleSize(ref, 'label-small')` to get the size at the element, then `estimateTextWidth`. In a stylesheet, write `font-size: var(--vz-type-<style>-size)`.

**Font sizes must reference a type style**: app font-size steps such as `text-xs` / `text-xl`, arbitrary `text-[..]`, inline `fontSize: 20` / `'20px'`,
`ctx.font = '12px …'`, `font-size` literals in d3, and `font-size: 20px` in a stylesheet all fail to compile (`[typography]`), and the error names the closest style.
Where a number is deliberate — a popover rendered outside the canvas, or text that is itself part of the geometry, such as atom symbols that scale with the bond length — write
`typography-ignore: <reason>` on that line or the line above; the reason is required. When the number lives in one constant, putting it on the constant's declaration is enough. em / rem are relative sizes and are not checked.

**Drawing in a fixed viewBox** (the whole SVG scales with its frame): the geometry scales with the frame, but text keeps its style's fixed size — a font size written in viewBox coordinates would fall below the smallest style in a narrow frame
and grow larger than the slide title in a big one. Use `useViewBoxTextSizes(ref, { width, height }, { label: 'label-medium' })` from the react entry
to get the value to write for each style in viewBox coordinates (`ref` points at the container the same size as the SVG), and base text, label offsets and collision avoidance on it; outside React use `viewBoxScale` and
`viewBoxTextSize`. The scale only looks at the widget's own frame (its layout size): canvas zoom and the camera are not counted.

There is no font-size floor: the levers for a compact layout are padding and canvas size, not smaller text.

Padding and gaps use the density classes `p-pad-xs` / `sm` / `md` / `lg` (likewise `px-pad-md`, `gap-pad-sm`; 5 / 10 / 15 / 20px), on the same scale as the font sizes;
small corner radii in SVG (bar tops, swatches) use `shapeCss('mark')`, and line widths use `strokeCss(...)`.

A widget whose amount of text depends on its content (documents, code): give it a font-size config `typeStyle()` (a style name or pt; default to a style name), plus the shared auto-shrink switch `textAutoFitField()`
(`@vizchat/widget-sdk`, on by default). When rendering, use the react entry's `useTextAutoFit({ enabled, recalcKey })`: attach `containerRef` to the container and
`contentRef` to the content, and write the font size as a product like `calc(var(--my-font-size) * var(--text-scale, 1))`. When the text doesn't fit it shrinks proportionally (only down, never up, with no floor),
instead of relying on scrollbars or clipping — nobody scrolls in a presentation or an export; when it shrinks below 70%, the review tells the author to enlarge the box or cut the content. While it's on, the font size is a ceiling; an author who wants the font size to rule turns it off.
A widget that shrinks single-line text by width itself (titles, table headers) records the ratio on the element with `markTextScale(el, fitted size, nominal size)` so the review can see it. If the content has blocks that don't wrap (display formulas, long code lines),
also pass `adjust`: called after each new scale is written and before height is measured, it shrinks one by one the blocks still wider than the column, rather than shrinking all the text for them.

## The host draws the panel and frame

A widget draws only its content: its root paints no background, border or shadow, and empty areas show the frame's fill or the slide.
`bg-background` / `bg-card` on the root, or a library's default white background, cuts an off-color box out of the slide. The panel, border, shadow and corner radius
are declared by the board (`frameStyle`) and drawn on the box by the host; in `defineWidget` the widget **must** declare, item by item, whether to follow (all three keys are required; there is no default, and leaving one out fails the compile):

```ts
import { z } from 'zod';
import { defineWidget } from '@vizchat/widget-sdk';

export default defineWidget({
  // A photo: the content fills the box, so no panel and no padding; the frame's corners and shadow still apply
  frameStyle: { fill: 'none', padding: 'none', edge: 'follow' },
  snapshotSchema: z.object({
    content: z.object({ title: z.string().default(''), src: z.string().default('') }),
    config: z.object({}),
  }),
  defaultSnapshot: { content: { title: '', src: '' }, config: {} },
});
```

To decide, ask "if the box were removed and the widget sat on any background, what happens?":

1. The content paints every pixel of the box (photos, PDF pages, maps with a base map, 3D scenes with a background color) → `fill: 'none'`, `padding: 'none'`, `edge: 'follow'`.
2. Unreadable on a colorful background without a panel (dense small text, fine grids: code, tables, forms) → `fill: 'solid'`: a solid panel even when the board has no frame.
3. Large text designed to float on the background (titles, body text, countdown digits) → all three `'none'`.
4. Everything else (graphics and annotations) → all three `'follow'` (what the scaffold generates).

Spacing belongs to the frame: the root adds no padding of its own (no `p-6` and the like). With `padding: 'follow'` the host insets the content by the frame preset; when the board has no frame the content sits flush with the box edge — the box itself is invisible and the board's layout decides where it goes. For a distinctive shape, follow none of the three and draw it in the content.
Mark accent text such as headline numbers with `data-accent-text-target`; the frame preset decides whether it is drawn as gradient or glowing text.
