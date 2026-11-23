# Data contract: `src/definition.ts`

```ts
import { z } from 'zod';
import { defineWidget } from '@vizchat/widget-sdk';

const ItemSchema = z.object({
  id: z.string(),
  label: z.string().describe('Text shown for the item.'),
  value: z.number().describe('Numeric value shown next to the label.'),
});

export default defineWidget({
  // all three required: does the board's frame apply to this widget (see "The host draws the panel and frame")
  frameStyle: { fill: 'follow', padding: 'follow', edge: 'follow' },
  snapshotSchema: z.object({
    content: z.object({
      title: z.string().default('').describe('Heading above the list; empty hides it.'),
      items: z.array(ItemSchema).default([]),
    }),
    config: z.object({
      display: z.object({
        showValues: z.boolean().default(true).describe('Show each item value.'),
      }),
    }),
  }),

  defaultSnapshot: {
    content: { title: 'Title', items: [{ id: 'a', label: 'A', value: 10 }, { id: 'b', label: 'B', value: 20 }] },
    config: { display: { showValues: true } },
  },

  ops: ({ op, collectionOps }) => ({
    // addItems / updateItems / removeItems / replaceItems, keyed by collection name: addItems({ items: [...] })
    ...collectionOps({ items: { requiredInputFields: ['label', 'value'] } }),

    setTitle: op(
      {
        description: 'Replace the heading above the list. An empty string hides it.',
        args: z.object({ title: z.string() }),
      },
      (snapshot, { title }) => ({ ...snapshot, content: { ...snapshot.content, title } }),
    ),
  }),
});
```

- `snapshotSchema` is always `z.object({ content, config })`. content holds the data given by the author or agent; config holds display options — the property panel is generated from it,
  so you write no panel code.
- Put a field's meaning in its `.describe()` (in English): units, coordinate system, value constraints, "what omitting it means", counter-intuitive semantics ("omitting is not the same as 0"),
  environment prerequisites (external links need CORS). Only `.describe()` reaches agents, via the operation docs (and the property panel); `docs.mdx` and code comments don't (see "A contract written for an agent to read" below).
- Once a widget is published, **when a field's meaning changes, give it a new name** instead of changing its meaning in place (if `value` goes from a percentage to a fraction, rename it `ratio`).
  Before a user's board moves to a new version, the platform checks the board's data against the new version's schema: with a new name the old data no longer fits, so the update marks the affected pages
  and hands them to the AI; a meaning changed in place passes the check, and the board silently shows the wrong thing. Publishing asks nothing about compatibility and has no version level to pick.
- Collections an author may leave out get `.default([])`: content is not merged with the default snapshot — if the author gives content, it is taken as a whole, and fields without defaults that are missing are errors.
- `defaultSnapshot` is the first screen when the widget is placed on the canvas before it gets data; it must satisfy `snapshotSchema` (otherwise compiling fails with the reason). See "Conventions" in the main file for how to write it.
- `frameStyle` (required, all three keys): whether the board's frame applies to this widget, per item — `fill` / `padding` / `edge`; there is no default, and leaving one out fails the compile. See
  "The host draws the panel and frame" in the main file for how to decide.
- Build ops with `op({ description, args }, reducer)`:
  - `description` is required — one English sentence: what it does, whether it merges with or replaces existing values, what omitting an argument means. Don't copy field semantics into op descriptions (a field is often changed by several ops,
    and each copy drifts);
  - `args` is the zod schema of the argument object (omit it for ops without arguments). The reducer receives arguments already parsed by it (defaults filled in); extra or misspelled keys are errors;
  - the reducer returns a new snapshot and never mutates in place.
- Use `collectionOps` for collections: declare an array of objects with `id` in content once and get four ops. Arguments are keyed by collection name: `addItems({ items: [{ label, value }] })`,
  `updateItems({ items: { ids, updates } })`, `removeItems({ ids })`, `replaceItems({ items: [...] })`. The item schema is inferred from content;
  `requiredInputFields` are the fields required when adding. Ids are unique within a collection: `addItems` with an id that is already taken (or repeated within the call) is an error and adds nothing — use `updateItems` to change an existing item.
- To let a narration emphasize data items inside the widget, use `highlightOps({ target, apply, clear })`: `target` is the zod schema of **one**
  target (an item id, a line number, a region on a page…), and you get two ops, `highlight({ items, style, others })` and `clearHighlight()`.
  When a board's `canvas_highlight` points at this widget's items, the host hands the `items` to `highlight` and calls `clearHighlight`
  when the sentence ends; for widgets that don't declare it, the host draws a frame where the items are. `highlight` means "set to these
  items", not "add" (the host computes the union when emphases overlap); `style` is `ring` / `glow` / `pulse` / `beam`, and drawing them
  all the same way is fine; with `others: 'fade'`, dim the other items. Read the color from the emphasis token `emphasis` (`bg-emphasis`,
  `var(--vz-emphasis)`). Charts that keep their items in a collection store the emphasis in a content field `highlight`
  (`ItemHighlightSchema`) and draw it with `applyItemEmphasis` in the d3 renderer — see `d3.md`. The names `highlight` and
  `clearHighlight` are reserved for it; don't declare ops with those names yourself.
- Built-in ops you don't write: `updateConfig` (provided automatically when config has fields; argument `{ configUpdates }` is deep-merged); `item.scrollTo` (mark data items with
  `data-vizchat-item` when rendering, see "Conventions" in the main file). Writing an op with the same name in `ops` overrides the built-in one.
- `demo.stb` must demonstrate every op you declare and may only reference ops that exist (checked at compile time; the two built-in ops are exempt).
  A `canvas_highlight` on this widget's items counts as demonstrating `highlight`, and one marked `transient: true` also counts for `clearHighlight`.

## A contract written for an agent to read

`snapshotSchema`, each op's `args` and `description`, and the fields' `.describe()` are compiled into the operations document, and the whole document enters the agent's context every time it finds or looks up this widget.
Design the contract for a reader who sees only that document:

1. **Put every constraint you can into the schema**: when a value isn't valid in a position, have argument validation reject it on the spot, rather than marking the object invalid at runtime and silently not drawing it.
   Narrow discriminated unions to where they're used — a kind only points can host doesn't belong in a line's field.
   Lengths, ranges and counts (`.min()` / `.max()` / `.int()`) are printed in the doc (`/* length 1–100 chars */`, `/* integer, ≥ 0 */`); don't restate them in `.describe()`.
2. **Spell out ordered and counted arguments**: for id lists, tuples, `deps` and the like, say in `.describe()` how many, what each is and in which order
   (`[from, vertex, to]: three point ids, the vertex in the middle`). With a bare `string[]` the agent can only guess.
3. **Make omission work through defaults**: defaults are printed in the document (`/* default true */`), but "omitted = default" only helps when the default is sensible;
   a default that most real uses have to override isn't a good default.
4. **Mark fields the widget computes and writes back with `.meta({ readOnly: true })`**: they stay in the snapshot but are left out of the operations document, so the agent doesn't think it has to fill them in.
   Write derived fields and cross-field invariants in `afterOp(next, prev)` (optional in `defineWidget`): called once after every op that produces a new snapshot (built-in ops included), it returns the final snapshot;
   throwing rejects that op. No need to wrap each op.
5. **Describe only what is specific to this widget**: units, constraints, counter-intuitive semantics. Conventions shared by all widgets (prefer theme tokens for colours and the like) needn't be repeated on every field.
6. **Don't keep a second copy of what the platform provides**: the node title (`context.title`), theme colours and the widget's size come from the platform;
   don't add fields that mean the same in the schema — the two copies drift: the user renames the title on the canvas while ops change the other one.
7. **Keep view and emphasis apart**: an op that changes what is in view (flying to a place, showing only one part) starts with `focus` (`focusRegion`);
   emphasizing a spot without changing the view always goes through `highlightOps` — don't write a highlight op of your own. The two are orthogonal and combine.
8. **Check the size when you're done**: after `vizchat widget build`, read `dist/assets/operations-*.md`. When it runs to tens of KB, look first for overly wide unions and repeated long descriptions —
   they are usually also signs of an imprecise contract; fix them in the schema and the document, validation and errors all come right together.
