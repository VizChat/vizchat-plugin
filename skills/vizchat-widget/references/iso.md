# Isometric drawings (iso)

Fixed-angle, clean-lined "textbook illustration" solids — system sketches, lab setups, terrain block diagrams — are projected to SVG with `@vizchat/widget-sdk/iso`; use three (`three.md`) only when the reader must turn the scene freely.
It is pure geometry: you give it solids and pipes and get screen polygons back; drawing, emphasis and animation are up to the widget.

- Projection: `createIsoProjector(view)`, where `view` is `ne` / `nw` / `sw` / `se` (`ISO_VIEWS`); the whole picture turns in 90° steps. x and y lie on the ground, z points up, units are yours to choose.
- Solids: `isoBox(proj, { part, at, size })` (`at` is the corner with the smallest x, y, z) and `isoCylinder(proj, { part, at, radius, height })` (`at` is the centre of the base)
  return the visible faces, each with `part`, `tone` (0 top, 1 left, 2 right) and `depth`; run all faces through `sortFaces` (far ones first) and turn each into an SVG path with `facePath(points)`.
- Pipes: `routePipe(fromBox, toBox, z, via)` runs at right angles from one part to another and ends on the sides of both (bounding boxes from `boxAabb` / `cylinderAabb`).
  For dots travelling along a pipe, take positions with `pointAlong(screenPoints, t)` and take `t` from `useBoardClockTime(hasFlow)` in `/react` — the picture is a pure function of the clock, so pausing, jumping and export all stop on the same frame; it freezes under reduced motion and draws no frames while outside the canvas viewport.
- Composition: `fitViewBox(allPoints, 0.6)` gives a viewBox in which the content fills about six tenths of the picture.
- Self-check: `auditIsoScene(parts, pipes)` reports parts running into each other (`overlap`), pipes passing through a part (`pipe-through`) and pipe ends left hanging (`pipe-dangling`). When coordinates come from an author or an agent,
  draw the result as a notice (`WidgetNoticeBand`) instead of silently drawing a broken picture.

Craft rules (they hold for the three route too):
- No wireframes on solids; the three visible faces take three tones, the top lightest and the right darkest, with the outline one step darker still. Mix the colors from theme tokens (for example `color-mix(in oklab, var(--vz-cat-1) 70%, black)`) so both light and dark follow.
- Line ends must land on a face, and parts must not run into each other — the self-check above looks for exactly these two.
- Content fills 55–65% of the picture; size text labels from a canvas type style (`useTypeStyleSize(ref, 'label-small')`) converted into scene units through the viewBox and the rendered size, so they never shrink out of sight with the drawing.
- Before you finish, screenshot several states (each step of a build-up, each view) and zoom in on the seams.
