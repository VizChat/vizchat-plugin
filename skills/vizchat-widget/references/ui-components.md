# Ready-made UI components and a custom data editor

## Prefer ready-made components

inline widgets can use two platform packages, both supplied by the platform: zero bundle bytes, a single global instance.

- `@vizchat/ui/widget-editor`: the common editor parts (`ArrayItemList` / `CollapsibleSection` / `ColorPickerField` / `ItemRow` / `NumericField` / `SelectField` /
  `SliderField` / `TextField`) and `useCollectionEditor` for data editors; the on-screen state frames `WidgetEmpty` / `WidgetLoading` / `WidgetError` /
  `WidgetNoticeBand` (empty / loading / failure / a one-line notice along the edge of the content — font size and the failure color `text-destructive-ink` already follow the typography table; `children`
  replaces the wording, `className` changes the style, `overlay` lays it over content that stays mounted) and the drop-zone empty state `DocumentDropEmptyState` for file widgets. For a different look, write the JSX yourself.
- `@vizchat/ui`: the shadcn primitives (`Button` / the `Dialog` family / `Input` / `Label` / `Switch` / the `Collapsible` family / `Select` / `Tooltip` …) and `cn`.
  Import primitives only from here, and declare it in `dependencies` in `package.json`.

- Each of the four input parts has its own commit timing: `NumericField` / `TextField` are draft-style (commit on blur or Enter, revert on Esc), `SliderField` commits at drag end, `SelectField`
  commits on change. DataEditor changes sync immediately with no "Apply" button, so use these for text, numbers, sliders, and dropdowns, not bare `<input>` / `<select>` — otherwise every keystroke and
  every drag frame pushes a snapshot.
- The three field parts shrink and don't fill by default: all have `min-w-0`, `TextField` also has `flex-1`, `NumericField` defaults to `w-16`, `SelectField` has no width. To fill, write `flex-1`;
  to fix the width, write `w-14 shrink-0`.
- `ColorPickerField`'s value is a hex or a theme reference `{ token }` (matching `themeableColor()`); its panel opens with the theme colors first. Pass `onClear` when the field may be left empty.
- Don't `shadcn add` your own copy into the widget: that bundles `@base-ui/react` as a second instance, and when mixed with platform components `DialogTrigger` cannot find `DialogContent`.

## A custom editor for content

`inlineWidget(definition, { component, editor: { DataEditor } })`, with props `{ content, onContentChange, config, readOnly }`.
Without it there is no "Data" tab; the config property panel is always generated.

For collections in content (arrays declared with `collectionOps`), `useCollectionEditor` is the recommended way to add, remove and update:

```tsx
const { add, remove, update } = useCollectionEditor({ content, onContentChange }, { definition });
add('items', { label: 'New item', value: 0 });   // same item builder as the agent's addItems: id prefix, defaults and schema defaults all come from the definition
remove('items', id);
update('items', id, { label });
```

You can use just one of the three (when a delete must also clear references elsewhere, keep writing that delete yourself). For arrays not declared with
`collectionOps` (such as arrays inside a content branch picked by `kind`), pass `{ createItem: { regions: (input) => … } }` with your own builder; when you need special
behavior, call `onContentChange` directly.

Test an editor with `createTestDataEditor` from `@vizchat/widget-sdk/testing` (it mounts the real strings and a draft content, so assertions name the text the user sees);
test a part inside an editor with `createTestEditorWrapper` as the `wrapper` of `render`. Pass `kitEditorMessages` from `@vizchat/ui/widget-editor` as `kitMessages` to both.

## How config fields show in the property panel

Only these union shapes get a dedicated control; any other union falls back to "option dropdown + sub-form", where the author can't tell which branch the value is in:

- `themeableColor()`: a color picker (the same one as `ColorPickerField`).
- Literals + a number (such as `z.union([z.literal('auto'), z.number().int().min(0)])`): a segmented control, one segment per literal plus "Fixed"; choosing "Fixed" shows a number box
  (bounded by the number branch's min / max). Put the literals' display names in the field's i18n entry as `"_rjsf_options": { "auto": "Auto" }`; without them the raw value is shown.
- A string + the empty string (such as `z.string().url().or(z.literal(''))`): a plain text box; clearing it writes `''` ("not filled in yet"); a half-typed value that doesn't meet the format isn't written.

Put the DataEditor in its own file: the property panel isn't governed by canvas typography, and a file separate from the canvas view isn't flagged by `[typography]`.
