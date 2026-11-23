# nested: DOM inside an iframe

A nested widget's data contract, ops, and i18n are exactly the same as inline; only the view becomes two DOM callbacks inside an iframe. The entry is `src/index.ts`; there is no `index.tsx` / `View.tsx`.

```ts
// src/index.ts
import { nestedWidget } from '@vizchat/widget-sdk/nested';
import definition from './definition';

export default nestedWidget(definition, {
  // Called once after the handshake: build only the DOM skeleton; data is drawn in render
  mount(ctx) {
    ctx.root.className = 'flex h-full w-full flex-col gap-3 overflow-hidden';
  },

  // Called for the first frame and after every snapshot change. This redraws everything; to update parts, compare snapshot with prev
  render(snapshot, _prev, ctx) {
    ctx.root.replaceChildren();
    const title = document.createElement('h2');
    title.className = 'text-title-large';
    title.textContent = snapshot.content.title || ctx.t('viewState')('untitled'); // always textContent for text
    ctx.root.append(title);
    // …build the remaining elements from snapshot
  },
});
```

| `ctx` member | Purpose |
| --- | --- |
| `root` | Root element filling the iframe |
| `t('<section>')` | Get strings; returns `t(key, vars?)` |
| `applyOp({ type, payload })` | The widget's own interactions change state (same path as agent dispatch) |
| `getSnapshot()` | Current snapshot |
| `displayMode` | Only in `render`: `'canvas'` or `'expanded'` (the expanded view can draw a fuller editing UI) |
| `signalReady()` / `reportError(msg)` / `trackPending` | See "Render readiness" below |
| `hostFetch(req)` | Read controlled resources through the host (such as workspace files) |
| `openLink(url)` | Ask the host to open an external link (see "External links" in the `assets` reference) |
| `holdPage({ reason?, expectedMs? })` | Hold the page: auto-play waits for `release()` before turning the page (see "Time and randomness" in the `chart-libraries` reference) |
| `paused` | The viewer has paused the presentation right now (`get()` / `subscribe`; the narration simply finishing, or stopping on a page, does not count): anything you time yourself freezes (keep any page hold) and carries on when playback resumes |
| `clock` | The board clock: `now()` is the continuous time (ms) shared by the whole board; looping effects read it in a rAF loop to draw that moment (see "Time and randomness" in the `chart-libraries` reference) |
| `role` | `'content'` or `'background'` (`get()` / `subscribe`): as a canvas background, draw no loading, error or empty-state UI and report problems to the author with `reportError` |

- When `render` redraws everything, changes expressed through CSS transitions are lost (new elements enter the tree already in their final state). Make such ops flip attributes of existing elements instead.
- Write data with `createElement` + `textContent`, never into `innerHTML` (compiling reports `[inner-html]`; static literals, or the result of `DOMPurify.sanitize(...)` in the same expression,
  are exempt).
- Third-party libraries and the SDK are bundled into the nested widget's own bundle, not shared with the platform.
- There is no unmount callback: when the widget is removed, the whole iframe document is destroyed, releasing timers, subscriptions, and workers with it.

## Render readiness

The platform uses it to decide when to take the widget's thumbnail and export video. The default check (fonts, images, DOM, and animations all settle) covers most cases; when the picture depends on
async data or looping animation, pass `readiness: 'manual'` and call `ctx.signalReady()` after each redraw reaches its final state. Failing to get data is also a final state: draw the failure state, call
`ctx.reportError(message)`, then `signalReady()` as usual. Every step of an async chain needs a timeout.
Register external resources such as remote images, tiles, and fetched data with `ctx.trackPending`: `ctx.trackPending.track(promise)`, or for event-style resources `const end = ctx.trackPending.begin()`
and `end()` on load / error. You can register several; both the default check and `signalReady()` wait for all of them to finish. Each item has a timeout (15 seconds); when it expires the item counts as finished and a warning is logged. Failure is also a final state.

## Styles inside the iframe

- The theme (color variables, fonts, light/dark) and the typography variables are injected by the platform, and semantic color classes work as usual; without Tailwind, write font sizes as `var(--vz-type-<style>-size)`, or use the SDK's `typeStyleCss('<style>')`.
- The iframe document inherits none of the host's style sheets. The compiler bundles the design system's variable values into your bundle; but a `var(--some-variable)` in hand-written CSS
  that is not a design-system token doesn't exist inside the iframe, and the whole declaration is dropped (it does not fall back to a default).
- The background is transparent by default here too: don't set a background color on `html` / `body`.
