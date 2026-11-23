# inline: a React component

```tsx
// src/index.tsx
import { inlineWidget } from '@vizchat/widget-sdk/react';
import definition from './definition';
import { View } from './View';

export default inlineWidget(definition, { component: View });
```

```tsx
// src/View.tsx
import { useWidgetState, useWidgetT } from '@vizchat/widget-sdk/react';
import definition from './definition';

export function View() {
  const { content, config } = useWidgetState(definition);
  const t = useWidgetT('viewState'); // empty-state and similar strings: t('empty')

  return (
    <div className="flex h-full w-full flex-col gap-3 overflow-hidden">
      {content.title && <h2 className="text-title-large">{content.title}</h2>}
      <ul className="flex flex-col gap-2">
        {content.items.map((item) => (
          // data-vizchat-item: the canvas uses it to frame this item and anchor captions during narration
          <li key={item.id} data-vizchat-item={item.id} className="flex justify-between text-label-medium">
            <span>{item.label}</span>
            {config.display.showValues && <span className="tabular-nums">{item.value}</span>}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

- `useWidgetState(definition)` returns `{ content, config, applyOp, readOnly }`, all typed from the definition.
- The widget's own interactions (buttons, dragging) always change state with `applyOp({ type: 'setTitle', payload: { title } })` — the same path agents dispatch on, saved automatically
  and undoable. Op names and payload shapes are type-checked.
- When `readOnly` is true (presenting, inspecting), hide editing controls — no toolbar at all.
- On the canvas it is "select first, then interact": an unselected widget's content takes no pointer events. To let users drag or select text in content, give that region `className="nodrag"`,
  and for selectable text also `style={{ userSelect: 'text' }}`.
