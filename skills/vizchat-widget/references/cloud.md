# Cloud: developing a widget through tool calls

A widget's source is a set of documents in its own draft workspace: read and write them with the document operations (`get_document` / `edit_document` / `create_document` /
`move_document` / `delete_document`), with `workspace` set to the draft workspace's id and `file` set to the path within the package (such as `src/View.tsx`). The read-before-edit
rule is the same as for ordinary documents. Only the widget-specific steps are listed below.

The first argument of every widget operation is `widget`: write `<author>/<slug>`, or just `<slug>` (= the current user); the `widget` in results is always the full name.

## Development loop

1. `create_widget(widget, mount, description?)`
   - `mount` is `inline` or `nested`, decided from the request per "Choosing mount";
   - creates the widget and writes a skeleton that compiles and renders, returning `widget` (full name) and `workspace` (draft workspace id). If a widget with that name already belongs to you, it is returned as is;
   - you usually choose the name: take a short English slug from the request (lowercase letters, digits and hyphens, e.g. `quarterly-sales-bar`); if unsure, ask the user.
     If the user wants a **new** widget and you get `created: false`, that name is taken by another of their widgets — don't change that one; pick another name and call `create_widget` again;
   - then call `show_widget(widget)` so the user sees the widget being built.
2. Look at the skeleton: when it returns `created: true`, the draft's files are word for word the ones for that mount in the scaffold reference listed in the skill index (with your widget's name),
   so look a file up there instead of calling `get_document` on each. The returned `files` carry each file's content hash, so they count as read: change them with `edit_document` directly. When the widget already existed (`created: false`),
   the files are as it stands — `list_documents(workspace)` and read the ones you'll change. The skeleton is a minimal working widget (a title + an item list); build on it.
   Write file paths exactly as in the skeleton or as listed, never guess — writing to a path outside the list means writing a file that is never loaded.
3. Change: `edit_document` × N (`search_replace` for a few spots, `rewrite` for a full rewrite, in its own batch); new files with `create_document`. Iterate on what you read.
4. `compile_widget(widget)`: call after every source change (it mints no version and doesn't publish). It shares the compile path with the editor's preview; once it compiles, the preview shows this version.
   On failure, `errors` lists diagnostics one by one (type errors carry `file:line`; gate violations start with `[gate-name]`).
5. `render_widget(widget)`: call right after compiling succeeds; it renders the version just compiled — the default snapshot (including the dark variant) and every demo page, with each page's errors, warnings, and op results,
   plus screenshots. A blank picture, misplaced elements, exposed `widgets.…` key paths, or text and borders hard to see in the dark variant are all problems: change the source and go again from step 4.
   This round is done only when both compiling and rendering are clean.

For the full final check use `check_widget(widget)`: it adds the remaining review items on top of rendering (runtime, interface, i18n, theme, performance, accessibility, code) and returns findings grouped by dimension.

To see whether it's published, the latest version, whether the latest version is open source, and whether there are pending merges, use `get_widget(widget)`; it isn't part of the development loop.
When the user wants to change "that widget of mine" without naming it, `list_widgets` lists all their widgets (with draft workspace ids).

## Creating from the conversation

The host may tell you the user just named a new widget in the interface (author and slug only), with the request attached:

- the widget doesn't exist yet → decide `mount` per "Choosing mount", `create_widget(widget, mount, description=<request>)`, then follow the development loop;
- the request is empty → ask the user what they want first, and create it once you agree;
- the widget already exists → it's an edit request: read first, then change.

## Restore when you break it

When you break it (it doesn't compile and you can't fix it, or the user says "go back to the earlier version"):

1. `list_widget_history(widget)` lists snapshots: `source` says when it was saved (before a round of agent changes, before a manual user edit, at a publish, before a restore),
   and `summary` and the changed files say what changed after that point.
2. `restore_widget(widget, snapshot_id)` returns to that point. The restore itself can be undone: the returned `undo_snapshot_id` is the state before the restore.
3. After restoring, every file you read is stale: re-read any file before changing it, then compile as usual.

## Merging pending changes

Two kinds of changes are not written straight into the cloud draft; they are stored as pending changes for whoever next works on the widget — you — to merge in:

- Code the user changed on their own computer: both the local copy and the cloud draft changed, and an unattended sync found it;
- A community change someone submitted from a fork, which the author accepted.

The cloud draft stays as it is. While pending changes exist, writes to the draft and publishing return `merge_pending`. To handle them:

1. `get_widget_merge(widget)` returns the earliest group: each file carries `base` (what the change started from: as the user last synced, or the published version that was changed),
   `local` (after the change: the user's local copy, the contributor's, or the platform's fix) and `remote` (the cloud draft when the group was stored), plus the group's `record_id`. While handling this group, pass that `record_id` to write tools that take a `merge_record_id` parameter; for those that don't, the system fills it in.
2. Text files: first read the **current** draft (it may be newer than `remote`), treat it as authoritative, merge the base → local changes into it and write it back. If the user renamed a function locally and you changed its call sites in the cloud,
   line these cross-file changes up together — the goal is a tree that compiles.
3. Binary files changed on both sides can't be merged line by line: choose `local` or `remote` for each in `binary_choices`, and ask the user if unsure.
4. `resolve_widget_merge(widget, record_id, binary_choices?)` finishes up: it compiles first, and if that fails it returns the compile errors and the group stays pending — keep fixing and call it again.
   Repeat for the next group, if any.
5. Once merged, do what the user actually asked you to do this time, and tell the user which changes you merged and where they came from.

## Fields returned by widget operations

The fields each operation returns on success are listed below. Fields with empty values don't appear in results. Failures are always the error object described in `vizchat-basics`.

## `show_widget`

Shows a widget to the user. Your own widget opens in the widget editor with its draft; another author's widget must be published and opens on its marketplace page. Returns a stable reference and links (VizChat site page, desktop deep link).

| Field | Type | Meaning |
| --- | --- | --- |
| `kind` | `"board" \| "widget" \| "document"` | What is being shown. |
| `workspaceId` | `string \| null` | Workspace holding the target; null for a published board and for a widget that is not yours. |
| `ref` | `string \| null` | Stable document ref inside the workspace; null for a widget and for a published board. |
| `author` | `string \| null` | Author of the widget or published board; null for a workspace document. |
| `slug` | `string \| null` | Slug of the widget or published board; null for a workspace document. |
| `version` | `string \| null` | Published version shown, or null for the draft. |
| `revision` | `string \| null` | Revision at the time it was shown (the document content hash, or the published version); null for a widget draft. Always present in a show result. (may be absent) |
| `title` | `string` |  |
| `links` | `{web, deep}` |  |

## `list_widgets`

Lists your widgets, drafts and published ones, most recently changed first: name, summary, latest published version (null = never published), whether it is listed on the marketplace, whether its source is open, and its draft workspace id. With favorited: true it lists the widgets you favorited instead, including other authors' (those have no draft workspace).

| Field | Type | Meaning |
| --- | --- | --- |
| `widgets` | `{widget, name, description, latest_version, listed, source_open, workspace}[]` |  |

## `search_widgets`

Searches the marketplace widgets: built-in and published user widgets in one pool, ranked by relevance. Each result carries its operations document (snapshot shape and operations) when one is published. Matching combines literal hits (name and tags rank first, then description and translations) with semantic similarity across languages, so a short phrase for what you want to show works; synonyms in both English and Chinese and category words still widen the literal recall.

| Field | Type | Meaning |
| --- | --- | --- |
| `results` | `{widget, name, description, version, source, operations}[]` |  |

## `describe_widget`

Returns the full operations document of one or more widgets: snapshot shape (the initialSnapshot contract) and every operation with its arguments. Reads the latest published version unless a version is given; widgets you cannot use (unpublished, taken down, paid without entitlement) are listed in not_found.

| Field | Type | Meaning |
| --- | --- | --- |
| `results` | `{widget, operations}[]` |  |
| `not_found` | `string[]` | Requested widgets with no readable operations document. |

## `create_widget`

Creates an unpublished widget with a draft workspace holding a runnable skeleton (a title and a list of items) for the given mount. The slug is 3–30 characters: lowercase letters and digits in segments joined by single hyphens, starting with a letter. When a widget with that name already exists under your account, returns it unchanged (created: false). Returns the draft workspace id: its source files are read and written with the document operations.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `workspace` | `string` | Draft workspace id: the workspace argument of the document operations. |
| `created` | `boolean` | False when the widget already existed. |
| `entry_file` | `string \| null` | Runtime entry inside the package; null when the widget already existed. |
| `files` | `{file, ref, source_sha256}[]` | Files written by this call, each with its content hash (empty when the widget already existed). |
| `links` | `{web, deep}` |  |

## `get_widget`

Returns the state of one of your widgets: its draft workspace id, whether the draft has a package.json, whether and which version is published, whether its source is open, and how many groups of local changes are waiting to be merged. Compile errors are not reported here.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `workspace` | `string \| null` | Draft workspace id. |
| `draft_ready` | `boolean` | The draft has a package.json. |
| `published` | `boolean` |  |
| `latest_version` | `string \| null` |  |
| `source_open` | `boolean` | The latest version's source is public: other users can read and fork it. |
| `pending_merges` | `integer` | Groups of local changes waiting to be merged (get_widget_merge). |

## `compile_widget`

Compiles the draft of one of your widgets with every check publishing runs (contract, dependencies and licenses, size, style vocabulary, types), without minting a version. The editor preview uses the same build, so a compiled draft is what the preview shows. Writes the build to the draft preview store. Fails with invalid_content listing one problem per entry; lines from a compile gate start with [gate-name].

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `build_hash` | `string` | Identifies this build of the source tree. |
| `cached` | `boolean` | True when this exact source tree was compiled before and the build was reused. |
| `warnings` | `string[]` | Non-blocking findings from the compile, one per entry, e.g. a declared range for a platform package that does not cover the version the platform compiles with. Empty when there are none. |

## `publish_widget`

Publishes the draft of one of your widgets as a new version on the marketplace, visible to and installable by every user; a published version cannot be withdrawn. The draft stays editable. Publishing runs in the background: returns a job id whose result (version) or error comes from get_job.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `job_id` | `string` |  |
| `status` | `"queued" \| "running" \| "succeeded" \| "failed"` |  |
| `links` | `{web, deep}` |  |

## `restore_widget`

Restores the draft of one of your widgets to a snapshot from list_widget_history: files go back to their snapshot content, files added since are deleted and deleted ones come back. The current draft is snapshotted first (undo_snapshot_id), so restoring that snapshot undoes the restore. Every file read before the restore is stale afterwards. Fails with merge_pending while local changes wait to be merged.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `snapshot_id` | `string` |  |
| `undo_snapshot_id` | `string \| null` | Snapshot of the draft before this restore; null when nothing changed. |
| `changes` | `string[]` | "<added\|removed\|modified> <path>" for every file changed. |

## `render_widget`

Renders the last compiled build of your widget draft in a headless browser: the default snapshot and every demo slide, with screenshots. Returns per-scene errors (render exceptions, widget-reported errors, console errors, untranslated i18n keys, readiness timeouts), warnings (an op that left the snapshot unchanged, a snapshot change that did not change the picture) and the result of every demo op. Renders what compile_widget last built and fails with invalid_content when the draft changed since; it never compiles.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `build_hash` | `string` | The compiled draft build that was rendered. |
| `scenes` | `{name, errors, warnings, image_index, dark_image_index, render_ms}[]` |  |
| `ops` | `{op, slide, ok, snapshot_changed, error}[]` | Every demo op that ran, and whether it succeeded. |
| `missing_i18n_keys` | `string[]` | i18n key paths that showed up on screen untranslated. |
| `unrendered_scenes` | `string[]` | Scenes not rendered because the time limit ran out. |
| `images` | `{index, label, width, height, mime_type, data}[]` | Screenshots, referenced by image_index. |
| `message` | `string` |  |

## `check_widget`

Reviews the last compiled build of your widget draft: everything render_widget returns (both themes), plus findings on runtime correctness, use of interfaces outside the SDK, i18n, theming, performance, accessibility and code. Each finding has a stable id, evidence and a suggested fix, and is either hard (blocks listing in the marketplace) or a judgement call. Fails with invalid_content when the draft changed since the last compile_widget.

| Field | Type | Meaning |
| --- | --- | --- |
| `widget` | `string` | Full name <author>/<slug>. |
| `build_hash` | `string` | The compiled draft build that was rendered. |
| `scenes` | `{name, errors, warnings, image_index, dark_image_index, render_ms}[]` |  |
| `ops` | `{op, slide, ok, snapshot_changed, error}[]` | Every demo op that ran, and whether it succeeded. |
| `missing_i18n_keys` | `string[]` | i18n key paths that showed up on screen untranslated. |
| `unrendered_scenes` | `string[]` | Scenes not rendered because the time limit ran out. |
| `images` | `{index, label, width, height, mime_type, data}[]` | Screenshots, referenced by image_index. |
| `message` | `string` |  |
| `findings` | `{id, rule, dimension, severity, message, evidence, suggestion, standard, params}[]` | Findings of this review. |
| `thresholds` | `{name, value}[]` | Thresholds used to raise findings. |
| `hard_count` | `integer` | Number of open hard findings; listing in the marketplace is blocked while it is above 0. |
