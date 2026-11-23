# File content sources, demo assets, and asset imports

## Widgets whose content comes from a file

Widgets for images, PDF, HTML and the like keep the default snapshot empty (no references to package assets), name the source field `content.source` (`AssetSource`), and make the empty state a drop zone:

- inline: `useDocumentDrop({ accept })` (destructure it);
- nested: `bindDocumentDrop(el, { accept, upload: () => ctx.documentUpload(), onPhaseChange })`.

The host uploads the file into the current workspace and writes `content.source` back itself; the widget dispatches no op. When unavailable (`available` is false / `documentUpload()` is `null`), say only "no content yet";
when available, say "drop or choose a file" and offer a "Choose file" button (`nodrag`); explain `uploading` / `rejected` / `failed` in place. For inline, the recommended way is `@vizchat/ui/widget-editor`'s
`<DocumentDropEmptyState drop={drop} unavailable={…} />` (platform wording, any line overridable through `messages`; `icon` / `title` / `className` replaceable); a nested widget writing its own empty state
uses `documentDropView(phase, available)` to decide which line to show and whether to show the button — the same mapping as inline.

## Render readiness: wait for external resources

The platform takes the thumbnail and advances video export only once the widget has drawn its final state. Anything that finishes drawing asynchronously — remote images, fetched data, map tiles,
animations that must play to their end — has to be registered, or thumbnails and videos capture the loading state:

- inline: `const tracker = useTrackPending()`, then `tracker.track(promise)`; for event-style resources, `const end = tracker.begin()` and call
  `end()` in `onLoad` / `onError`. You can register several; the final state is reached only when all have finished. The hosts of `d3View` and three already register their own parts — register only what you add.
  Drawing that decides its own final state (hand-written rAF, per-frame canvas) uses `useSettledSource(() => gate.whenSettled())`, which can be combined with `useTrackPending`.
  Once anything is registered, the platform stops observing CSS transitions and animations — cover the transitions you need waited on with one of the two ways above.
- nested: `ctx.trackPending` has the same shape. The last step of the default check waits for it; with `readiness: 'manual'`, `ctx.signalReady()` also waits for it to finish before actually reporting.
- Each item has a timeout (15 seconds); when it expires the item counts as finished and a warning goes to the console. Failure is also a final state: draw the failure state, then end the registration (a `track`ed promise that rejects ends it automatically).

## External links

The canvas may sit in a host sandbox that forbids popups (MCP Apps hosts), and so does a nested widget's iframe — neither `window.open` nor the default navigation of
`<a target="_blank">` opens anything. Always ask the host to open external links: inline uses `const openLink = useOpenLink()`, nested uses `ctx.openLink(url)`, called
from the click handler. Keep the `<a href>` (copy-link from the context menu still works); in `onClick`, call `preventDefault()` first, then call it. Only http(s)
is accepted; the host won't open other schemes.

## `public/`: files only for the demo

Files in `public/` serve only `demo.stb`: in the demo write `{{PKG}}/<file name>` (rewritten at compile time to a hashed address; referencing a missing file fails compilation). Choose common formats
(SVG / PNG, unencrypted PDF, HTML without external links), sized in the hundreds of KB. Code doesn't reference files in `public/` by path (compiling reports `[public-path]`); assets code uses go through the next section.

## `presets/`: built-in resources users can pick directly

Use presets when you want to offer users a few ready-made choices (backgrounds, sample models, sample data): put the files at the package root in `presets/<name>.<ext>` (names are lowercase letters, digits and hyphens,
one file per preset), and write the field that accepts them as `assetSourceOf(['document'], { presets: ['paper', 'space'] })` — that field then accepts both workspace files and
`{ kind: 'preset', value: 'paper' }`, and the schema lists every valid name. At runtime:

```ts
import { fetchAssetText, type AnyAssetSource } from '@vizchat/widget-sdk';
import { useHostFetch } from '@vizchat/widget-sdk/react';
import presets from 'vizchat:presets'; // { paper: '<hashed address>', space: … }

export function useLoadText() {
  const hostFetch = useHostFetch();
  // When you need a URL instead, use resolveAssetSourceToUrl(source, hostFetch, { presets })
  return (source: AnyAssetSource) => fetchAssetText(source, hostFetch, { presets });
}
```

- Preset names go into i18n: `presets.<name>` is the name users see (every language needs it).
- The declared names and the files in `presets/` must match one to one (compile reports `[asset-presets]`).
- Presets ship with the widget version: after you change a preset, works that use it see the new look only once they upgrade the widget version.

## Asset imports (`?url` / `?worker` / `?init`)

```ts
import sampleUrl from './sample.png?url'; // address string (relative to the module itself: new URL(sampleUrl, import.meta.url))
import createHeavyWorker from './heavy.worker.ts?worker'; // async factory: await createHeavyWorker()
import initWasm from './lib.wasm?init'; // wasm instantiation function
```

- The default export of `?worker` is an async factory, not a constructor (don't `new` it; compiling reports `[worker-new]`): it verifies the worker script's integrity before constructing. Hand libraries the instance
  (`GlobalWorkerOptions.workerPort = await createPdfWorker()`), not the address.
- Inside a worker, `import.meta.url` is a blob address: the main thread passes in the asset addresses it needs with `postMessage`.
- Don't `?url` a `.js` / `.mjs`, and don't use `?worker&url` / `?sharedworker` — compilation fails. `?raw` (the file's text) / `?inline` (the processed styles) put the content into the bundle as a string; they can only read files inside your widget package and its installed dependencies — reading a file outside them fails compilation.
