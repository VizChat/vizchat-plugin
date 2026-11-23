# Local: developing a widget on disk

Locally, use the `vizchat widget` commands. If the CLI isn't installed or you aren't signed in, set it up following the local steps in `vizchat-basics` and run `vizchat auth login`. Run commands in the widget directory
(the level containing `package.json`), or point to it with `--root <dir>`.

| Command | What it does |
| --- | --- |
| `vizchat widget create [options] <slug> [dir]` | Create a widget (and its cloud draft) and clone it into a local folder |
| `vizchat widget dev [options]` | Local preview server, rebuilds on change (long-running; first stdout line is {success, port, previewUrl}) |
| `vizchat widget build [options]` | Build the widget locally (writes dist/ and manifest.json) |
| `vizchat widget test [options]` | Run the widget's tests (failures in the last stdout JSON line) |
| `vizchat widget lint [options]` | Static checks that need no rendering: schema and dependency declarations |
| `vizchat widget merge [options]` | Show, finish or abandon a local merge (local and cloud both changed) |
| `vizchat widget tts [options]` | Synthesize demo narration into .vizchat/local/demo-derived/ (pages already synthesized are skipped) |
| `vizchat widget publish [options]` | Make the cloud draft match this folder (fast-forward only), then publish it (irreversible) |
| `vizchat widget show [options] [widget]` | Show a widget |
| `vizchat widget ls [options]` | List widgets |
| `vizchat widget search [options] <query>` | Search widgets |
| `vizchat widget describe [options] <widgets...>` | Describe widgets |
| `vizchat widget get [options] [widget]` | Get a widget |
| `vizchat widget history [options] [widget]` | List widget draft history |
| `vizchat widget restore [options] <snapshot-id>` | Restore a widget draft |
| `vizchat widget render [options] [widget]` | Render a widget |
| `vizchat widget check [options] [widget]` | Check a widget |

## Development loop

1. **Create**: `vizchat widget create <slug> --mount inline|nested [dir]` creates the widget and its draft workspace in the cloud, then pulls it into a local directory. For a widget that already exists in the cloud,
   `vizchat workspace clone <author>/<slug> [dir]` pulls its draft down. Only the source comes down: in the directory, run `npm install` (or your package manager's install) first —
   build, test and publish resolve dependencies on this machine and fail with a "dependencies not installed" error until they are.
2. **Read the skeleton**: the skeleton is a minimal working widget (a title + an item list). Read `src/definition.ts` and the entry first, and build on them.
3. **Change**: edit the files directly. `vizchat widget dev` starts a local preview server that refreshes on save.
4. **Compile**: `vizchat widget build` — the same compiler and the same gates as in the cloud. On failure it lists diagnostics one by one (type errors carry `file:line`; gate violations start with `[gate-name]`).
5. **Static checks**: `vizchat widget lint` runs the review items that don't need rendering.
6. **Test**: `vizchat widget test` (see below).
7. **Look at the rendered result**: `vizchat widget render` renders the default snapshot and every demo page (`--theme light|dark` picks the variant, `--scenes` picks pages); screenshots are written under `.vizchat/local/renders/`,
   and the last line of JSON gives the file paths, errors, and warnings — open them with your image-reading ability. A blank picture, misplaced elements, exposed `widgets.…` key paths, or things hard to see in the dark variant are all problems.

For the full final check use `vizchat widget check`; it returns findings grouped by dimension. `render`, `check`, and `vizchat widget show` (open it in VizChat)
all push your local changes to the cloud draft first — that is their side effect; if the push is rejected, merge first as described below. To only push without rendering, run `vizchat workspace sync`.

## Tests

Tests live in `src/__tests__/`:

| File | Applies to | Covers |
| --- | --- | --- |
| `definition.test.ts` | All | One normal case + one edge case per custom op; boundary values of business fields |
| `View.test.tsx` | inline | The picture and emitted changes after rendering through a real test host and dispatching ops |

```ts
// definition.test.ts — call ops directly as functions
import definition from '../definition';

const next = definition.ops.setTitle(definition.defaultSnapshot, { title: 'New' });
expect(next.content.title).toBe('New');
```

```tsx
// View.test.tsx — a real host: hooks, reducers, and i18n all run for real
import { createTestWidgetHost } from '@vizchat/widget-sdk/testing';
import widget from '../index';
import en from '../i18n/en.json';
import zh from '../i18n/zh.json';

const host = createTestWidgetHost({ widget, i18n: { en, zh }, locale: 'en' });
render(<host.Widget />);
act(() => host.applyOp({ type: 'setTitle', payload: { title: 'Updated' } }));
expect(screen.getByText('Updated')).toBeDefined();
expect(host.emittedChanges).toHaveLength(1);
```

- `host` also has `getSnapshot` / `replaceState` / `reportedErrors` / `Wrapper` (wraps without rendering).
- Don't `vi.mock('@vizchat/widget-sdk/react')` as a whole: once `useWidgetState` is a stand-in, snapshot completion, op routing, and change emission never run, and a misspelled op name won't fail.
- No need to test: the default snapshot satisfying the schema (checked at definition time), i18n keys being complete and consistent (compile gates). Worth testing yourself: i18n keys built at runtime (forms like `` t(`kinds.${k}`) ``
  that static scanning can't see).
- Rendering inside the nested iframe isn't covered by unit tests; check it with `vizchat widget render`.

## Merging: both local and cloud changed

When `vizchat workspace sync` finds the same widget changed on both sides: changes that need no merge (new files, files changed on only one side) are applied automatically; for the remaining files, the three versions are written to
`.vizchat/merge/<id>/{base,local,remote}/<path>`, the working directory keeps your local version, and the command fails with `merge_pending`.

1. Compare `base` (at the last sync) with `remote` (the cloud now), and merge the cloud's changes into the files in the working directory; for binary files changed on both sides, copy the chosen one into the working directory.
   Align cross-file changes together (a function renamed on one side, call sites changed on the other); the goal is that the whole tree compiles.
2. `vizchat widget merge --continue`: compiles locally first; on success it pushes the merged result as one whole push and cleans up the merge directory. If the cloud changed again during the push, it fails with `conflict` and
   refreshes the `remote` copy — go back to step 1. If compiling fails, it fails with `invalid_content` and the merge state is kept; fix it and `--continue` again.
3. Not merging now: `vizchat widget merge --abort` hands your local changes to the cloud as pending merges and restores the working directory to the cloud version.

When the cloud already holds pending merges (for example, created earlier by a background sync), `vizchat widget merge` fetches them locally to merge with the same steps; after `--continue` succeeds they are
marked merged in the cloud. Until the merge is finished, sync, push, and publish are all rejected.

## Restore when you break it

`vizchat widget history` lists draft snapshots (before a round of changes, before a manual user edit, at a publish, before a restore); `vizchat widget restore <id>` returns to that point,
and the state before the restore is saved as another snapshot, so it can be undone. Restoring changes the cloud draft: afterwards run `vizchat workspace sync` to pull it locally.
