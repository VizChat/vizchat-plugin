# Compile gates

Compiling runs a set of gates (types, font sizes, style classes, demo data and coverage, i18n, and more). Violations start with `[gate-name]` and appear in the compile result's `errors`;
type errors carry `file:line`. Find the row for the gate name below and fix it as "Where to fix" says.

| Gate | Meaning | Where to fix |
| --- | --- | --- |
| `[typecheck]` | Type errors, each `file:line:column TSxxxx message` | Fix line by line. `applyOp`'s op names and payloads, and snapshot fields, are all constrained by the types `defineWidget` infers |
| `[typography]` | Font sizes written as fixed values on the canvas: app font-size steps (`text-xl`), arbitrary `text-[..]` sizes, `fontSize` numbers inline, `ctx.font`, font-size literals in d3, px font sizes in stylesheets — canvas font sizes only accept references to type styles | Switch to the style the error gives (`text-<style>`, `typeStyleProps` / `typeStyleCss`, `var(--vz-type-<style>-size)`). Put the DataEditor in its own file — the property panel isn't governed by canvas typography; for drawing text that scales with the picture, or a module rendered only in a dialog portaled elsewhere, write `typography-ignore: <reason>` above the line (or the constant's declaration, or the import) |
| `[widget-css]` | `className` uses a class that doesn't exist in the build output (commonly Tailwind's default palette, `text-emerald-700`) | Use semantic color classes |
| `[worker-new]` | `new` on the default export of `?worker` (it's an async factory), or `new Worker(new URL(...))` | `const worker = await createX()` |
| `[public-path]` | Code references a file in `public/` by path | Move the file into `src/` and `import url from './x.png?url'` |
| `[asset-presets]` | The preset names the schema declares (`assetSourceOf(…, { presets })`) don't match the files in `presets/`, or `presets/` has an invalid name, a duplicate name, a subfolder or a link pointing outside the package | Add the missing file or remove the name from `presets`; delete extra files or list them in some field's `presets` |
| `[vue-sole-condition]` | In Vue JSX, `{cond && …}` as the only child of an element or component (shows the text "false" when cond is false) | Write `{cond ? <X /> : null}` |
| `[inner-html]` | nested writes data into `innerHTML` / `outerHTML` / `insertAdjacentHTML` | `createElement` + `textContent`; HTML that truly must be rendered goes through `DOMPurify.sanitize(...)` in the same expression |
| `[demo-payloads]` | The snapshot or op arguments `demo.stb` writes for this widget don't match the schema (including keys the schema doesn't know) | Fix `demo.stb` using the correct path the error gives |
| `[demo-op-coverage]` | A declared op is never demonstrated in `demo.stb` (built-in `updateConfig` / `item.scrollTo` excepted) | Add a cue in `demo.stb` that uses it |
| `[demo-op-names-exist]` | `demo.stb` references an op name the widget doesn't declare (operations sent to auxiliary widgets, created or pinned as another type, do not count) | Change it to a declared op, or declare it in the definition |
| `[demo-narration-plain]` | The narration `markedText` contains markdown markup (`**` `*` `` ` `` links), or a `{{PKG}}/…` asset reference (compiling rewrites it, so the published narration no longer matches the draft and locally synthesized audio can't be reused) | Remove the markup; keep only spoken text (math written as LaTeX inside `$…$` is not markup); put assets in cue args or the widget config |
| `[shared-field-placement]` | An SDK shared field (`strokeStyleField()`, `chartGridField()`, `ColorSchemeSchema` …) isn't in its standard place | Move it to the `config.<group>.<field>` the error gives |
| `[i18n-config-sync]` | config has a field but the `config` section lacks its translation (SDK field fragments excepted: they carry platform labels) | Add the field to the `config` section of `src/i18n/*.json` |
| `[i18n-required-locales]` | `src/i18n/` lacks the file for an interface language (seven: en, zh, es, fr, de, ja, ru) | Create the missing file from an existing one and translate every entry |
| `[i18n-locale-parity]` | Keys differ between languages | Fill in the missing language |
| `[i18n-missing-keys]` | Source `t('x')` takes a key that doesn't exist, or gets a group of keys (a group object) instead of one string | Add the key, fix the spelling, or take the specific leaf key |

An inline bundle over 20MB is rejected by the compiler, and the error lists the largest modules: switch to a lighter library, or import only the subpaths you need.

## Keys the schema doesn't know

Keys a schema doesn't know are errors in snapshots, op arguments, `demo.stb`, and property panel writes alike; they are never silently stripped. The error gives the full path and the closest valid path
("`config.labelFontSize` does not exist; did you mean `config.display.labelFontSize`"): fix it to the path given.
