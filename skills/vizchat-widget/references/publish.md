# Publishing

Publish only when the user explicitly asks. Publishing cannot be undone: once published, everyone can see and install it, and there is no "unpublish"; the draft stays, you keep editing it and publish the next version.

## Write the marketplace text first

`description` and `keywords` in `package.json` and `src/docs.mdx` are the marketplace's public text, written for the people who will use the widget:

- `description`: a one-sentence value proposition (for whom, solving what), ≤140 characters, no data structures or library names;
- `keywords`: one language per array (whatever language the user uses);
- `docs.mdx` has four sections in a fixed order; the Example's fields must exist in the snapshot schema (checked at compile time), with sample data close to real use; the body contains no implementation details (frameworks, libraries, data structures).
- Write the docs for the people who will use the widget by following them, so they can read and copy them:
  - **One example shows one thing** and reads in a dozen or so lines. To cover several uses, split `## Example` into `###` subsections, each opening with one sentence on what it shows, then a short yaml block;
    do not pile every field into one long example as a reference manual (the field list is what the Operations table and `.describe()` are for).
  - Each example stands on its own: every id it refers to is in the same block, so readers do not have to look elsewhere.
  - Examples must work as written: no placeholders like `'<workspace file ref>'`; write a valid value (for a file reference, a ref in uuid7 form with a trailing comment saying what it points to).
  - Comments only say what the code cannot (why, constraints) and do not repeat field names line by line. Pull rules that are easy to trip over into a short section after the examples instead of burying them in comments.
  - Code blocks longer than 30 lines are collapsed on the page (readers must click to expand the rest); write ` ```yaml open ` when a block really has to be shown whole.
- link and image addresses in `docs.mdx` may only be `https://` / `http://`, `mailto:`, site-absolute paths (`/…`) or in-page anchors (`#…`), and `href` / `src` are string literals; anything else (`data:`, `//host`, …) is rejected at compile time.

````
# <Widget Name>
<one-line positioning — not the same sentence as description; both show on the same screen>

## When to use
- Three bullets: in what situations to choose it over others

## Operations
<WidgetOperations widgetRef="<author>/<slug>" />   ← generated block; don't hand-write the op list

## Example
```yaml
content: …    # the top level is the snapshot's two keys, content / config
config: …
```
````

## Cloud

`publish_widget(widget)`:

- the call needs the user's confirmation; a confirmation the user didn't expect is itself an interruption;
- publishing runs in the background; wait for the result with `get_job` using the returned job id;
- with pending merges it returns `merge_pending`: merge first, then publish;
- a string that looks like a secret blocks the publish: a real secret goes, read from configuration instead; a hit matching a known secret format has no `fingerprint` and can only be removed.
  A hit with a `fingerprint` may be a false positive (a public id, a content hash, a licence link): show it to the user, and only once they confirm it is not a secret add its `fingerprint` to `secretScanAllow` in the `vizchat` block of `package.json`, which lets only that string through;
- when the widget is a fork whose `LICENSE` is broader than the original's, it returns `confirmation_required` (`reason: license_widening`): this is the user's declaration about their own rights,
  so don't judge it for them — ask whether the original author gave permission, or none of the original content remains; only if they confirm, call again with `acknowledge_license_widening=true`
  (VizChat records the confirmation); otherwise change `LICENSE` back to the original's license or a stricter one;
- the publish job runs the same review as `check_widget` on the content being published: with hard items the job fails with `invalid_content`
  and `errors` lists each finding — fix them, re-run `check_widget`, then publish again; findings that need judgment are
  in the result's `review` and don't block;
- after publishing, tell the user the version number and link, and mention any undecided judgment findings in the result's `review`.
- the demo is published along with it as this widget's demo (an unlisted board), and the job waits for that too; its outcome is in `demo`: on `failed` the widget is live but the demo wasn't updated — tell the user why (they can retry the demo publish from My creations); `skipped` means the demo is taken down and wasn't updated.
- republishing after changing only the demo mints no new widget version (the version stays the same) and only updates the demo.

After publishing, the platform rebuilds the widget with newer versions before old versions of runtime packages such as the SDK are retired (same version number; the author can switch back to the old build on the widget page). If a rebuild fails the author gets a notification;
fix the source using the error in it and publish the next version as usual.

## Local

`vizchat widget publish`: first makes sure the cloud draft matches local (fast-forward push; if rejected, merge first with `vizchat workspace sync`), then publishes the cloud draft.

- use `--dry-run` first to see what will be published;
- a string that looks like a secret blocks the publish: a real secret goes, read from configuration instead; a hit matching a known secret format has no `fingerprint` and can only be removed.
  A hit with a `fingerprint` may be a false positive (a public id, a content hash, a licence link): show it to the user, and only once they confirm it is not a secret add its `fingerprint` to `secretScanAllow` in the `vizchat` block of `package.json`, which lets only that string through;
- when a fork's `LICENSE` is broader than the original's, the command returns `confirmation_required` (`reason: license_widening`): as in the cloud, ask the user, and only after they confirm they have the right
  re-run with `--acknowledge-license-widening`;
- publishing needs the user's own confirmation in a browser: when the command returns `confirmation_required` with a confirmation link, give the link to the user and rerun the same command unchanged after they confirm;
  a confirmation covers this one run only — never click it on the user's behalf;
- synthesize the demo narration audio with `vizchat widget tts` (`--dry-run` lists the pages it would synthesize);
- the demo is published along with it as the demo, the command waits for that too, and `demo` in the result means the same as in the cloud;
- whether the source is public is declared by `vizchat.openSource` in `package.json` and applies per version: when it is `true`, this version's source goes public with the publish and can't be withdrawn. New widget templates are already open source (`openSource: true`, `license: Apache-2.0`, a `LICENSE` and `NOTICE` naming the author); tell the user before publishing that the source will be public, and remove `openSource` if they don't want that (no field means closed source).
  Change this declaration only when the user asks;
- the license is the `LICENSE` file at the package root (none means the Platform License: all rights reserved, forkable within VizChat), separate from whether the source is public. `license` in `package.json` must agree with it: when the file is MIT / Apache-2.0 / CC, write the same SPDX id; for the Platform License or a custom license, leave it out or write `"UNLICENSED"` (the Platform License may also be written as `"LicenseRef-VizChat-Platform-1.0"`) — if they disagree, publishing fails.
