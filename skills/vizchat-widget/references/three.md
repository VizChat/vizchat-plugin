# 3D (three)

Use three only when the shape must rotate freely; for fixed-viewpoint solids with clean, textbook-illustration lines use isometric (`iso.md`). Once you pick three, decide where the geometry comes from: irregular ready-made shapes are **assets** (named nodes in a `.glb`, as in `model-viewer`); structural shapes that change during the explanation are **generated at runtime** from snapshot parameters, with each mesh named (as in `math-3d`, `molecule-3d`); when both occur, mix them. Whatever the source, everything after that is handled as named parts (see `createPartRegistry` below).

The platform's three is the WebGPU build; browsers without WebGPU fall back to WebGL2 on their own:

- `import * as THREE from 'three/webgpu'` (`from 'three'` gets the same copy); use `three/tsl` for node materials and custom shading.
- Hand the renderer to `createThreeHost(canvas, { label, draw })` (`@vizchat/widget-sdk/three`), the recommended way: it handles the init gate, on-demand frames (`scheduleFrame()`, no standing rAF loop),
  size (`resize(w, h)`, paired with `useElementSize`), readiness (`whenFrameDrawn()`, passed to `useSettledSource`) and release (`dispose()`); when neither backend is available
  `rendererReady` settles to `false`, `draw` receives `null`, and you say so on screen (`WidgetError`). To run your own render loop use `WebGPURenderer` directly and follow these points:
  `await renderer.init()` before the first frame — calling `render()` before that throws. The picture is truly drawn in the frame after init; that's what the platform's thumbnail captures.
  There is no `WebGLRenderer` (compiling reports `is not exported`).
- A camera orbiting the origin: `orbitCameraSchema({ limits, defaults })` builds the `config.camera` schema, `mergeOrbitCamera` writes `setCamera`, and `OrbitCameraSync` handles the debounced
  write-back after the user drags and tells "the agent changed the camera" apart (all in `@vizchat/widget-sdk`, usable in `definition.ts` too). Other two-way values (a model transform) use `SyncedValue`, the same mechanism. To put it on three: `fitCameraToOrbit(camera, orbit, w, h)` places the camera (z up; set `camera.up` first) and `bindOrbitPointer(canvas, { get, limits, onChange })` handles dragging and the wheel (`@vizchat/widget-sdk/three`).
- For a scene made of parts (a molecule's atoms and bonds, a machine's components, the meshes in a glb) use `createPartRegistry()` (`@vizchat/widget-sdk/three`): while building the scene,
  `register(id, object)` each part; whenever the snapshot changes, replay the whole view with `apply(view, content.highlight, { emphasis })` — lit parts blend towards the emphasis colour and, with `fade`, the rest go faint.
  `view` follows `PartViewSchema` (`@vizchat/widget-sdk`, usable in `definition.ts`): isolate (`isolate`), take apart (`explode`, 0–1) and cut (`section`, one cut perpendicular to an axis).
  Take the transitions of explode and section from the board clock: `tweenPartValue(from, to, clock.now() - start)`, so pausing and export freeze at the moment the clock gives. `bounds(ids)` gives the box to focus on,
  `anchor(id)` the part's current centre (projected to the screen, that is where its `data-vizchat-item` anchor goes). Emphasis goes through `highlightOps`, the same as in 2D widgets. `PartAnchorLayer` projects each part into an anchor box carrying `data-vizchat-item` (`sync` to build, `project` every frame), so the canvas emphasis boxes and callouts can point at 3D parts.
- Screen-reader alternative: spread the `imageProps` of `useChartDescription(...)` onto the `<canvas>` and put `dataTable` next to the canvas (see "Screen-reader alternative" in the conventions reference); tabulate the objects in the scene that have coordinates (points, parts).
- Transparent background: create `WebGPURenderer` with `alpha: true` and set no clearColor / `scene.background`, so empty areas show the slide background.
- Always write addons as `three/addons/...` (the platform serves them by directory, sharing one instance with your three). Don't write `three/examples/jsm/...`, and don't import the aggregate entry `three/addons` —
  that bundles a second whole copy of three; compiling reports it and gives the rewrite.
- Addons that depend on GLSL import fine but draw nothing: `ShaderMaterial` / `RawShaderMaterial` / `onBeforeCompile`, `postprocessing/*` (the `EffectComposer` family),
  `shaders/*`, the `lines/Line2.js` family. For thick lines use `three/addons/lines/webgpu/Line2.js` (with `THREE.Line2NodeMaterial`, line width in CSS pixels); for post-processing and effects use
  `three/addons/tsl/display/*`. `THREE.Line` is only 1 physical pixel wide on every backend; use `Line2` for short and dashed lines.
- These addons pull code from a public CDN at runtime and don't work offline: `LottieLoader`, `TTFLoader`, `3DMLoader`, `physics/*` (Ammo / Jolt / Rapier), `webxr/` controller and
  hand models, `libs/demuxer_mp4.js`. `DRACOExporter` requires the page to load the Draco encoder first (global `DracoEncoderModule`), which the platform doesn't provide.
- Release with `renderer.dispose()` (there is no `forceContextLoss`). Don't dispose a renderer whose init failed — it waits for init again, and the failure becomes an unhandled rejection
  (`createThreeHost` already handles this).
