# Writing a widget in Vue

A Vue widget is nested: it builds its own Vue app inside the iframe, and the Vue runtime ships in the bundle. The data contract
(`src/definition.ts`), ops and i18n are exactly the same as in a React widget; only the view becomes a Vue component.

```ts
// src/index.ts
import { vueNestedWidget } from '@vizchat/widget-sdk/vue';
import definition from './definition';
import { QuizCard } from './QuizCard';

export default vueNestedWidget(definition, { component: QuizCard });
```

```tsx
/** @jsxImportSource vue */
// src/QuizCard.tsx
import { computed, defineComponent } from 'vue';
import { useWidgetMeta, useWidgetState, useWidgetT } from '@vizchat/widget-sdk/vue';
import definition from './definition';

export const QuizCard = defineComponent({
  setup() {
    const { content, applyOp } = useWidgetState(definition);
    const t = useWidgetT('viewState');
    const { readOnly } = useWidgetMeta();
    const done = computed(() => content.value.revealed);
    return () => (
      <ul class="flex flex-col gap-3">
        {content.value.choices.map((c) => (
          <li key={c.id} data-vizchat-item={c.id}>
            <button
              type="button"
              class="focus-ring w-full rounded-lg border-2 px-5 py-3 text-label-large"
              disabled={readOnly.value || done.value}
              onClick={() => applyOp({ type: 'select', payload: { id: c.id } })}
            >
              {c.text}
            </button>
          </li>
        ))}
        {done.value && <p class="text-body-large">{t('revealed')}</p>}
      </ul>
    );
  },
});
```

- **How to write it**: `defineComponent` with a render function — `h()`, or JSX in a `.tsx` file imported from `src/index.ts` that starts with
  `/** @jsxImportSource vue */`. No template strings: compiling a template at runtime needs `new Function`, which strict-CSP hosts (MCP
  hosts among them) block. No `.vue` single-file components (the compiler does not process them).
- Declare `vue` in `dependencies`. A bundle only ever contains one copy of Vue (the compiler resolves `vue` from the entry for every importer).
- **Composables** (`@vizchat/widget-sdk/vue`, called in `setup()`):

  | Function | Gives |
  | --- | --- |
  | `useWidgetState(definition)` | `{ content, config }` (`ComputedRef`) and `applyOp` |
  | `useWidgetT(segment)` | translated text |
  | `useWidgetMeta()` | `readOnly` / `title` / `highlighted` / `displayMode` / `locale` (refs) |
  | `useMotionIntent()` | whether this change animates or lands on the end state (`'animate'` / `'instant'`) |
  | `useElementSize(ref)` | the element's size, `null` before mount |
  | `useHostColorScheme()` | the host's light / dark mode |
  | `useSettled()` | `{ trackPending, signalReady }` |
  | `useReportSpecIssues()` | reports content references that do not match to the agent and returns a one-line notice |
  | `useHostFetch()` / `useDocumentDrop(ref, { accept })` | read a workspace file / drop-to-upload |

- **Transitions**: Vue's own `<Transition>` / `<TransitionGroup>` with CSS transitions, binding `css` to `useMotionIntent().value === 'animate'` —
  page jumps, seeks and thumbnails then land on the end state. Put `data-vizchat-item` on the list items, not on the transition wrapper, so
  anchors stay in place during the transition.
- **Readiness**: by default the platform waits for the DOM and transitions to go quiet. When the picture keeps changing (a ticking timer), use
  `vueNestedWidget(…, { readiness: 'manual' })` and call `useSettled().signalReady()` once the first frame after each snapshot change is drawn.
- **Tests**: `mountVueWidget(definition, Component, { i18n, initialState, readOnly, motion })` (`@vizchat/widget-sdk/vue/testing`) mounts the
  component with the real state and op routing and returns `root`, `applyOp`, `replaceState`, `setReadOnly`, `dispatched` (ops the component
  dispatched itself), `reportedErrors` and `readyCount()`. Test files that mount DOM use `.test.tsx` (jsdom).
- Everything else (the nested ctx, the iframe's capabilities) is the same as for any nested widget; see the nested reference in the SKILL.md index.
