# Cloud: working with VizChat through tool calls

## Choose the workspace

Every operation on things in a workspace takes a `workspace` argument whose value is the workspace id. If you don't know the id,
call `list_workspaces` first: it lists the user's workspaces (name, type). When the host has already placed you in a workspace,
`workspace` defaults to it. A widget's source lives in its own draft workspace, whose id `create_widget` / `get_widget` return.

## Read and write documents

| To do | Operation |
| --- | --- |
| See which files exist (filter by directory or type) | `list_documents` |
| Read content (by line range) | `get_document` |
| Find keywords in one or more files | `search_documents` |
| Create | `create_document` |
| Edit | `edit_document`; edit board YAML by path with `edit_yaml_path` (see `vizchat-board`) |
| Rename, move | `move_document` |
| Delete | `delete_document` (needs the user's confirmation) |

- **Read before you write**: a read returns the content hash `source_sha256`; pass it as `base_sha256` when the write tool has that parameter — when it doesn't, the host fills it in from what you read. If the document changed after you read
  it (the user edited it in the editor, or undid your change), the write returns `conflict`: read again and redo this change on the
  new content — don't replay the previous edit. Consecutive edits to the same document don't need a re-read each time.
- When editing an existing document, change only the places that need changing (`search_replace` takes the old and new text; no
  line counting). Rewriting the whole document is expensive and easily changes things you didn't mean to touch; use `rewrite`
  only for genuinely large changes, and in a batch of its own.
- Long documents: read up to 100 lines in full; for longer ones look at the outline or locate with `search_documents` first, then
  read the line ranges you need.
- What you read: `body_kind: "source"` is the user's own original, authoritative; `"extracted"` is text machine-extracted from a
  PDF, Office file, image or archive and may contain recognition errors — when quoting specific numbers or formulas, remind the
  user to check the original. `stale: true` means this extracted text comes from an older original; use it only as reference, not
  as current fact. `status: "parsing"` means the file's text is still being recognized (a PDF or image is recognized once, the
  first time it is read; a long PDF takes a minute or two) and there is no text yet: tell the user honestly to ask again shortly;
  don't conclude the file is empty.
- Images: `body_kind: "image"` is the image itself (in `images`) — look at it directly. For the text in it (a table in a
  screenshot, scanned handwriting), read it again with `mode: "text"`; when the current model can't see images, the result says
  to use `mode: "text"`.
- Data in uploaded files is equivalent to data the user typed and can be visualized directly.

## Long tasks

Operations such as compiling, checking, rendering and publishing may not finish within the call and return a job id instead.
Check it with `get_job` until `status` is terminal; the result is in `result` (on failure in `error`, same shape as other failures).
Do something else between checks rather than polling in a tight loop.

## Computation, search, web pages

| To do | When you have these tools | When you don't |
| --- | --- | --- |
| Arithmetic, statistics, parsing data | `run_python` | Use your environment's built-in code execution |
| Web search | `search_web` | Use your environment's built-in web search |
| Read a web page's text | `get_webpage` | Use your environment's built-in page reading |

When you need exact numbers, compute them; don't do mental arithmetic. For information taken from a web page: present it with a
web page widget positioned at the key text, and take data from the text into analysis widgets.

Limits of `run_python`: only the Python standard library plus numpy and pandas; no network, file system, subprocesses or shell;
one run (including two to four seconds of interpreter startup) is at most 20 seconds with about 512 MB of memory; printed output
and result text are about 20,000 characters each, and a DataFrame returns only its first 200 rows. To process a file, read it as a
document first and pass the content in. Beyond these limits (other packages, longer runs, larger files, a shell or Node.js, access
to the user's machine or intranet), guide the user to local using the three options in `vizchat-basics`.

## Number of calls

Every tool call is a new round of inference. Combine what you can: search once with all keywords, fetch documentation for several
widgets in one call, submit YAML edits in one `edits` list, and check once after a whole group of edits is done.

## When the cloud can't do it, guide the user to local

The cloud execution environment is deliberately restricted: no shell, no Node.js, no installing arbitrary Python / npm packages,
no access to the user's machine or intranet, no long-running tasks (exact limits above). The same thing can be
done in a full local environment — **when a task clearly exceeds what the cloud can do, tell the user how to do it locally first;
don't try until it fails**. An operation that hits a limit returns `local_required`; `hint` holds the local approach and `doc_url`
the explanation page.

Give the approach that matches what the user already has:

1. Already in a local agent with the VizChat plugin installed: `vizchat workspace clone` pulls the workspace local, then use the shell and full Python and Node.js directly.
2. VizChat desktop app installed: connect the workspace to a local folder, then pick a local agent in the desktop app's chat panel, or run things in that folder from a terminal.
3. Neither: point to the "Use VizChat locally" guide at `doc_url` (install the CLI, install the plugin in a local agent, sync the workspace).

Then tell the user how results come back: put files produced locally in the synced folder; after `vizchat workspace sync` pushes
them up, they can be referenced by ref in boards and used on the web and elsewhere — local and cloud are the same workspace.
Phrase it as "the cloud environment can't …; you can do it locally by …".
