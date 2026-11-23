# Reviewing a widget

Follow this page as the last step of building, or when the user asks you to check a widget.

## 1. Get the machine-checkable findings

`check_widget` renders the most recently compiled version — run `compile_widget` first; without a build it fails with `invalid_content`. Locally, `vizchat widget check` pushes and compiles first. It renders the default snapshot and every demo page (including the dark variant), returning screenshots and findings grouped by dimension:

| Dimension | What it checks |
| --- | --- |
| Runtime correctness | Exceptions during render, reported errors, console errors, readiness timeouts, failed ops; "snapshot changed but the picture didn't", "op ran but the snapshot didn't change" |
| Interfaces | Capabilities only through the SDK and declared dependencies: no requests to undeclared origins, no `window.parent` / `postMessage`, no direct `localStorage` / cookie access, no changes to the host DOM |
| Languages | All seven interface languages are present, keys match across languages, and each file really is in its language (not copied English); no UI strings in source outside i18n; no key paths show on screen when rendered |
| Theme | Colors use theme tokens; nothing becomes "invisible" in the dark variant compared with the light one |
| Visibility | The default snapshot is not a nearly blank box; no label in the default snapshot is set but invisible; no label that must show is crowded out |
| Performance | Bundle size, first-frame time, time per demo op, memory after rendering, number of long tasks |
| Accessibility | Interactive elements are focusable and have readable names; text contrast reaches 4.5:1 |
| Code | Type checking; no `any` in the exported schema |

For a quick look at the picture use `render_widget` (locally `vizchat widget render`); it only renders and gives no full review. When no screenshots are attached (your environment can't read images),
judge from the text report and measurements.

## 2. Then look at what needs judgment

- Defaults hold for "a read-only presentation where the reader doesn't interact": labels are visible by default, not on hover;
- The default snapshot shows at a glance what the widget is for: an author importing it, an agent creating it and the marketplace card all see it first. Where only the author can write the content (a cover, body text, code),
  draw a placeholder in every context (muted text, dashed outline) that says what goes there, without passing itself off as the author's content;
- Ops, picture, and description agree: what the schema's `describe`, the docs, and op names promise matches what is drawn;
- Op granularity and naming: one op does one thing, and its name says what it does;
- The snapshot schema is serializable, minimal, with self-explanatory field names;
- Empty, loading, and error states all have a visible presentation; config option names and defaults match an ordinary user's common sense;
- The demo covers the core capabilities, and every page shows the value of this widget; one real topic, no op names in the narration, math written as formulas, a background.

## 3. Make a decision for each finding

**Hard items** are fixed directly, no choice — they break the widget for other users or make it unsafe, and they also block listing: exceptions during render, reported errors, readiness timeouts, failed ops;
i18n keys missing at runtime (the UI shows key paths); unauthorized interface use (`window.parent` / `postMessage`, requests to undeclared origins); evaluating strings
as code at runtime (`eval`, `new Function`) or compiling WebAssembly — strict MCP hosts don't allow it; if the reported source file is in a dependency, upgrade or replace that dependency (when choosing dependencies, avoid libraries that work by eval, such as runtime template compilation or expression evaluators).

Every other finding gets one of three decisions:

| Decision | When | What to do |
| --- | --- | --- |
| Fix | The fix is clear, doesn't change the widget's intended behavior, and is cheap | Change it directly, then check again |
| Accept | There is a sound reason: the content itself needs it, it matches personal preferences, the nature of the widget dictates it (a full-screen 3D scene has no "alignment") | Give the reason when you report |
| Ask the user | It involves the user's intent or taste, personal preferences conflict with the standard, fixing it changes behavior, or you're unsure | See below |

When you **ask the user**, merge similar findings into one question instead of interrupting item by item: say what kind of problem it is and where it appears, offer two or three options with their consequences, and add your recommendation. Example:

> In the dark variant, 3 pieces of secondary text have low contrast (about 3:1). Options: A. switch to `text-muted-foreground`, clear in both variants; B. keep the current brand color, slightly dark in the dark variant.
> I recommend A.

**Decisions are not recorded per finding**: reviews are not stored, so a later check raises the same judgement findings again — follow what you and the user already settled in this conversation instead of asking again.
When the user makes a choice of taste, ask whether to save it to personal preferences; if they agree, `update_preferences` (density and narration length go in their own fields, everything else in `instructions`);
every later turn then follows the preference.

## 4. Report

Tell the user what you fixed, what you accepted (with reasons), and what still awaits their decision. The publish job runs the same review again on the content being published: findings that need judgment appear in the publish summary and don't block publishing; unfixed hard items make the publish fail and prevent listing.
