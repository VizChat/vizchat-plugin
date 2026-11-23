# Motion

Decide how the widget should move while you build it. Motion should carry meaning — where a new row came from, where a deleted one went,
what a value changed from and to, which step is being explained. Do not animate just for decoration, and do not loop.

- **Follow the narration**: every snapshot change has an intent — animate while the narration advances, land on the end state when the
  reader jumps between pages, seeks, takes a thumbnail or prefers reduced motion. Read it with `useMotionIntent()` (`/react`, or `/vue` for Vue).
  An instant change must not leave half an animation behind, or thumbnails and video exports capture a middle frame.
- **What to use**:
  - Adding, removing, reordering or re-laying out HTML (lists, tables, cards): `motion/react`, with the content wrapped in `<WidgetMotionConfig>`
    (`@vizchat/widget-sdk/motion`) — it handles the canvas zoom and "land instantly this time". Pass the `transition` from `useMotionTransition(…)`,
    and hand the exit transition through `AnimatePresence`'s `custom`. Springs take `bounce` / `visualDuration`, not `stiffness` / `damping` / `mass`.
  - SVG charts: d3 transitions, registered with `this.track(transition)`; use a zero duration when the intent is `instant`.
  - A single property changing in place (color, opacity, stroke progress): a CSS transition or the Web Animations API, timed with
    `duration-instant` / `duration-lift` / `duration-travel` and eased `ease-out`. On an instant change the host zeroes the duration of CSS transitions inside the widget, so CSS transitions need not read the intent themselves.
  - Items in a list that React draws directly (SVG shapes, annotation boxes) entering and leaving: `usePresence(items, keyOf)` (`/react`) keeps a removed
    item until it has faded out, and marks items that appear after mounting as `entering`. Give them `transition-opacity duration-travel`, add
    `starting:opacity-0` to entering ones and `opacity-0` to exiting ones, and wire `onTransitionEnd` to `onExitEnd(key)`; an exiting element no longer
    carries `data-vizchat-item`. Pass the array from the snapshot as `items`, not a result recomputed on every render.
  - Pictures where every middle frame must hold (coordinate plots, 3D figures): interpolate the inputs, not what is drawn. `useContentTween(content, { enabled, interpolate })` (`/react`)
    hands the interpolated parameters, free point coordinates or camera to the normal evaluation and drawing on every frame, so whatever depends on them
    is derived again each frame and stays consistent. `lerpValue` interpolates numeric leaves linearly and switches every other field to its new value at the start.
    Objects whose structure doesn't line up (a changed expression, a different solid type) are not interpolated: the old one fades out and the new one fades in.
    Call `markLocal()` before a change the widget commits itself (releasing a drag, writing back the view) so that change is not interpolated and follows the hand;
    call `finish()` when the user starts dragging.
  - Third-party libraries (ECharts, Leaflet, p5): the library's own animation, switched by the intent.
  - A process that unfolds over time (motion, a route drawn segment by segment, samples piling up): the playhead `usePlayhead` — the snapshot
    stores the target time, never the wall clock.
- **Readiness**: the platform waits for animations to finish before it treats the picture as final (thumbnails and video export wait for it).
  CSS transitions, motion and d3 transitions are waited for; an animation you drive yourself with `requestAnimationFrame` must keep the settled
  gate closed while it runs (`usePlayhead` does this for you).
