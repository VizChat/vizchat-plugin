# Scaffold

The files `create_widget` writes into a new widget's draft are word for word the ones below, with the example names replaced by yours: `author` → your username, `my-widget` → the slug,
`MyWidget` / `myWidget` → the class name and identifier derived from the slug. The platform dependency ranges (`>=<platform version>`) are concrete versions in the draft; leave them as they are.
There are also `.gitignore` and `tsconfig.json`, which you leave alone and which aren't listed here. Cloud drafts carry no tests; a local `vizchat widget create` adds `src/__tests__/`.

How to use it: look at the section for the file you're changing and build on it; a file you rewrite in full needn't be read first.

## inline

### `LICENSE`

```
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright 2026 author

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

### `NOTICE`

```
MyWidget
Copyright 2026 author
```

### `package.json`

```json
{
  "name": "@author/my-widget",
  "version": "1.0.0",
  "license": "Apache-2.0",
  "private": true,
  "type": "module",
  "vizchat": {
    "openSource": true,
    "mount": "inline",
    "displayName": "MyWidget",
    "sizeConfig": {
      "width": 400,
      "height": 300,
      "minWidth": 250,
      "minHeight": 150,
      "maxWidth": 1000,
      "maxHeight": 800
    }
  },
  "dependencies": {
    "@vizchat/widget-sdk": ">=<platform version>",
    "@vizchat/ui": ">=<platform version>",
    "react": "19.2.8",
    "react-dom": "19.2.8",
    "zod": "^4.6.7"
  },
  "devDependencies": {
    "@testing-library/dom": "^10.4.1",
    "@testing-library/jest-dom": "^7.0.0",
    "@testing-library/react": "^16.3.2",
    "@types/node": "^24.13.3",
    "@types/react": "^19.2.18",
    "@types/react-dom": "^19.2.4",
    "jsdom": "^30.0.1",
    "typescript": "^6.0.3",
    "vitest": "^4.1.12",
    "vizchat": ">=<platform version>"
  },
  "scripts": {
    "build": "vizchat widget build",
    "typecheck": "tsc --noEmit",
    "test": "vizchat widget test"
  }
}
```

### `src/definition.ts`

```ts
/**
 * MyWidget's data contract: the snapshot's shape, its defaults and the ops. Written the same way for inline and nested.
 *
 * - `snapshotSchema`: content holds the data the author provides; config holds display options adjustable in the property panel.
 *   Put each field's meaning, unit and constraints in `.describe()` (in English) — agents and the property panel both read it.
 * - `defaultSnapshot`: what shows when placed on the canvas before any data. Use neutral placeholders, not data that looks real.
 * - `ops`: what agents and demo scripts can do to this widget. Each op has a one-sentence English `description`.
 */

import { z } from 'zod';
import { defineWidget } from '@vizchat/widget-sdk';

const ItemSchema = z.object({
  id: z.string(),
  label: z.string().describe('Text shown for the item.'),
  value: z.number().describe('Numeric value shown next to the label.'),
});

export default defineWidget({
  // Whether the board's frame (frameStyle) applies to this widget: fill / padding / edge (corners, shadow, border).
  // All three are required. Leave spacing to the frame (padding: follow) and add no padding on the root; content that fills the box (photos, PDFs)
  // uses fill / padding: 'none'; content unreadable without a panel (code, tables) uses fill: 'solid'.
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
    content: {
      title: 'Title',
      items: [
        { id: 'a', label: 'A', value: 10 },
        { id: 'b', label: 'B', value: 20 },
        { id: 'c', label: 'C', value: 30 },
      ],
    },
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

### `src/demo.stb`

```yaml
# Demo script: every declared op must be demonstrated at least once (checked at compile time); referencing an op that doesn't exist also fails the compile.
config:
  sourceLocale: en
slides:
  - id: slide-1
    title: 'MyWidget'
    markedText: 'This is MyWidget. {@cue-create}Here it is with three items.'
    cues:
      - id: cue-create
        operations:
          - id: demo-create
            widgetId: demo-widget
            widgetType: author/my-widget@draft
            operation: canvas_createWidget
            args:
              position: { x: 120, y: 120 }
              width: 400
              height: 300
              title: 'MyWidget'
              data:
                initialSnapshot:
                  content:
                    title: 'Quarterly sales'
                    items:
                      - { id: q1, label: 'Q1', value: 120 }
                      - { id: q2, label: 'Q2', value: 150 }
                      - { id: q3, label: 'Q3', value: 90 }
                  config: {}

  - id: slide-2
    title: 'Editing items'
    markedText: '{@cue-add}Add the fourth quarter. {@cue-update}Correct the third. {@cue-remove}Drop the first.'
    cues:
      - id: cue-add
        operations:
          - id: demo-reuse-slide-2
            operation: canvas_reuseWidget
            args:
              widgets:
                - { id: demo-widget }
          - id: demo-add-items
            widgetId: demo-widget
            operation: addItems
            args:
              items:
                - { id: q4, label: 'Q4', value: 180 }
      - id: cue-update
        operations:
          - id: demo-update-items
            widgetId: demo-widget
            operation: updateItems
            args:
              items:
                ids: [q3]
                updates: { value: 110 }
      - id: cue-remove
        operations:
          - id: demo-remove-items
            widgetId: demo-widget
            operation: removeItems
            args:
              ids: [q1]

  - id: slide-3
    title: 'Replacing everything'
    markedText: '{@cue-replace}Swap in a new list. {@cue-title}And give it a new heading.'
    cues:
      - id: cue-replace
        operations:
          - id: demo-reuse-slide-3
            operation: canvas_reuseWidget
            args:
              widgets:
                - { id: demo-widget }
          - id: demo-replace-items
            widgetId: demo-widget
            operation: replaceItems
            args:
              items:
                - { label: 'North', value: 64 }
                - { label: 'South', value: 48 }
      - id: cue-title
        operations:
          - id: demo-set-title
            widgetId: demo-widget
            operation: setTitle
            args:
              title: 'Sales by region'

pinned:
  widgets:
    - id: demo-slide-title
      widgetType: vizchat/rich-text
      position: { x: 80, y: 24 }
      size: { width: 700, height: 130 }
      snapshot:
        content: ''
        config:
          typography:
            p: { fontSize: 24, color: { token: foreground } }
      bindings:
        content: 'slide.title'
    - id: demo-page-number
      widgetType: vizchat/rich-text
      position: { x: 1620, y: 960 }
      size: { width: 220, height: 100 }
      snapshot:
        content: ''
        config:
          typography:
            p: { fontSize: 14, color: { token: muted-foreground } }
      bindings:
        content: "slide.number + ' / ' + slides.length"
```

### `src/docs.mdx`

````mdx
# MyWidget

{/* One sentence: what this is and who it is for. Write for the people using it, not about the implementation (frameworks, libraries, data structures).
Not the same sentence as `description` in package.json — both show on the detail page. */}

## When to use

{/* Three points: when to pick this over other widgets */}

- ...
- ...
- ...

## Operations

<WidgetOperations widgetRef="author/my-widget" />

## Example

{/* The top level is the snapshot's two keys, content and config. Field names must exist in snapshotSchema (checked at compile time). */}

```yaml
content:
  title: Quarterly sales
  items:
    - { id: q1, label: Q1, value: 120 }
    - { id: q2, label: Q2, value: 150 }
config: {}
```
````

### `src/i18n/de.json`

```json
{
  "viewState": {
    "empty": "Noch keine Einträge"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Anzeige",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Werte anzeigen",
        "_rjsf_description": "Zeigt den Wert jedes Eintrags neben seiner Beschriftung"
      }
    }
  }
}
```

### `src/i18n/en.json`

```json
{
  "viewState": {
    "empty": "No items yet"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Display",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Show values",
        "_rjsf_description": "Show each item's value next to its label"
      }
    }
  }
}
```

### `src/i18n/es.json`

```json
{
  "viewState": {
    "empty": "Aún no hay elementos"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Visualización",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Mostrar valores",
        "_rjsf_description": "Muestra el valor de cada elemento junto a su etiqueta"
      }
    }
  }
}
```

### `src/i18n/fr.json`

```json
{
  "viewState": {
    "empty": "Aucun élément pour l’instant"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Affichage",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Afficher les valeurs",
        "_rjsf_description": "Affiche la valeur de chaque élément à côté de son libellé"
      }
    }
  }
}
```

### `src/i18n/ja.json`

```json
{
  "viewState": {
    "empty": "まだ項目がありません"
  },
  "config": {
    "display": {
      "_rjsf_title": "!表示",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "値を表示",
        "_rjsf_description": "各項目のラベルの横に値を表示します"
      }
    }
  }
}
```

### `src/i18n/ru.json`

```json
{
  "viewState": {
    "empty": "Пока нет элементов"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Отображение",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Показывать значения",
        "_rjsf_description": "Показывать значение каждого элемента рядом с его подписью"
      }
    }
  }
}
```

### `src/i18n/zh.json`

```json
{
  "viewState": {
    "empty": "暂无条目"
  },
  "config": {
    "display": {
      "_rjsf_title": "!显示",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "显示数值",
        "_rjsf_description": "在每个条目的标签旁显示数值"
      }
    }
  }
}
```

### `src/index.tsx`

```tsx
import { inlineWidget } from '@vizchat/widget-sdk/react';
import definition from './definition';
import { View } from './View';

export default inlineWidget(definition, { component: View });
```

### `src/View.tsx`

```tsx
import { useWidgetState, useWidgetT } from '@vizchat/widget-sdk/react';
import definition from './definition';

export function View() {
  const { content, config } = useWidgetState(definition);
  const t = useWidgetT('viewState');

  if (content.items.length === 0) {
    return (
      <div className="text-body-medium flex h-full w-full items-center justify-center text-muted-foreground">
        {t('empty')}
      </div>
    );
  }

  return (
    <div className="flex h-full w-full flex-col gap-3 overflow-hidden">
      {content.title && <h2 className="text-title-large">{content.title}</h2>}
      <ul className="flex flex-col gap-2">
        {content.items.map((item) => (
          // data-vizchat-item: the canvas uses it to frame this item and anchor captions during narration
          <li
            key={item.id}
            data-vizchat-item={item.id}
            className="text-body-medium flex justify-between"
          >
            <span>{item.label}</span>
            {config.display.showValues && <span className="tabular-nums">{item.value}</span>}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

## nested

### `LICENSE`

```
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright 2026 author

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

### `NOTICE`

```
MyWidget
Copyright 2026 author
```

### `package.json`

```json
{
  "name": "@author/my-widget",
  "version": "1.0.0",
  "license": "Apache-2.0",
  "private": true,
  "type": "module",
  "vizchat": {
    "openSource": true,
    "mount": "nested",
    "displayName": "MyWidget",
    "sizeConfig": {
      "width": 400,
      "height": 300,
      "minWidth": 250,
      "minHeight": 150,
      "maxWidth": 1000,
      "maxHeight": 800
    }
  },
  "dependencies": {
    "@vizchat/widget-sdk": ">=<platform version>",
    "zod": "^4.6.7"
  },
  "devDependencies": {
    "@types/node": "^24.13.3",
    "jsdom": "^30.0.1",
    "typescript": "^6.0.3",
    "vitest": "^4.1.12",
    "vizchat": ">=<platform version>"
  },
  "scripts": {
    "build": "vizchat widget build",
    "typecheck": "tsc --noEmit",
    "test": "vizchat widget test"
  }
}
```

### `src/definition.ts`

```ts
/**
 * MyWidget's data contract: the snapshot's shape, its defaults and the ops. Written the same way for inline and nested.
 *
 * - `snapshotSchema`: content holds the data the author provides; config holds display options adjustable in the property panel.
 *   Put each field's meaning, unit and constraints in `.describe()` (in English) — agents and the property panel both read it.
 * - `defaultSnapshot`: what shows when placed on the canvas before any data. Use neutral placeholders, not data that looks real.
 * - `ops`: what agents and demo scripts can do to this widget. Each op has a one-sentence English `description`.
 */

import { z } from 'zod';
import { defineWidget } from '@vizchat/widget-sdk';

const ItemSchema = z.object({
  id: z.string(),
  label: z.string().describe('Text shown for the item.'),
  value: z.number().describe('Numeric value shown next to the label.'),
});

export default defineWidget({
  // Whether the board's frame (frameStyle) applies to this widget: fill / padding / edge (corners, shadow, border).
  // All three are required. Leave spacing to the frame (padding: follow) and add no padding on the root; content that fills the box (photos, PDFs)
  // uses fill / padding: 'none'; content unreadable without a panel (code, tables) uses fill: 'solid'.
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
    content: {
      title: 'Title',
      items: [
        { id: 'a', label: 'A', value: 10 },
        { id: 'b', label: 'B', value: 20 },
        { id: 'c', label: 'C', value: 30 },
      ],
    },
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

### `src/demo.stb`

```yaml
# Demo script: every declared op must be demonstrated at least once (checked at compile time); referencing an op that doesn't exist also fails the compile.
config:
  sourceLocale: en
slides:
  - id: slide-1
    title: 'MyWidget'
    markedText: 'This is MyWidget. {@cue-create}Here it is with three items.'
    cues:
      - id: cue-create
        operations:
          - id: demo-create
            widgetId: demo-widget
            widgetType: author/my-widget@draft
            operation: canvas_createWidget
            args:
              position: { x: 120, y: 120 }
              width: 400
              height: 300
              title: 'MyWidget'
              data:
                initialSnapshot:
                  content:
                    title: 'Quarterly sales'
                    items:
                      - { id: q1, label: 'Q1', value: 120 }
                      - { id: q2, label: 'Q2', value: 150 }
                      - { id: q3, label: 'Q3', value: 90 }
                  config: {}

  - id: slide-2
    title: 'Editing items'
    markedText: '{@cue-add}Add the fourth quarter. {@cue-update}Correct the third. {@cue-remove}Drop the first.'
    cues:
      - id: cue-add
        operations:
          - id: demo-reuse-slide-2
            operation: canvas_reuseWidget
            args:
              widgets:
                - { id: demo-widget }
          - id: demo-add-items
            widgetId: demo-widget
            operation: addItems
            args:
              items:
                - { id: q4, label: 'Q4', value: 180 }
      - id: cue-update
        operations:
          - id: demo-update-items
            widgetId: demo-widget
            operation: updateItems
            args:
              items:
                ids: [q3]
                updates: { value: 110 }
      - id: cue-remove
        operations:
          - id: demo-remove-items
            widgetId: demo-widget
            operation: removeItems
            args:
              ids: [q1]

  - id: slide-3
    title: 'Replacing everything'
    markedText: '{@cue-replace}Swap in a new list. {@cue-title}And give it a new heading.'
    cues:
      - id: cue-replace
        operations:
          - id: demo-reuse-slide-3
            operation: canvas_reuseWidget
            args:
              widgets:
                - { id: demo-widget }
          - id: demo-replace-items
            widgetId: demo-widget
            operation: replaceItems
            args:
              items:
                - { label: 'North', value: 64 }
                - { label: 'South', value: 48 }
      - id: cue-title
        operations:
          - id: demo-set-title
            widgetId: demo-widget
            operation: setTitle
            args:
              title: 'Sales by region'

pinned:
  widgets:
    - id: demo-slide-title
      widgetType: vizchat/rich-text
      position: { x: 80, y: 24 }
      size: { width: 700, height: 130 }
      snapshot:
        content: ''
        config:
          typography:
            p: { fontSize: 24, color: { token: foreground } }
      bindings:
        content: 'slide.title'
    - id: demo-page-number
      widgetType: vizchat/rich-text
      position: { x: 1620, y: 960 }
      size: { width: 220, height: 100 }
      snapshot:
        content: ''
        config:
          typography:
            p: { fontSize: 14, color: { token: muted-foreground } }
      bindings:
        content: "slide.number + ' / ' + slides.length"
```

### `src/docs.mdx`

````mdx
# MyWidget

{/* One sentence: what this is and who it is for. Write for the people using it, not about the implementation (frameworks, libraries, data structures).
Not the same sentence as `description` in package.json — both show on the detail page. */}

## When to use

{/* Three points: when to pick this over other widgets */}

- ...
- ...
- ...

## Operations

<WidgetOperations widgetRef="author/my-widget" />

## Example

{/* The top level is the snapshot's two keys, content and config. Field names must exist in snapshotSchema (checked at compile time). */}

```yaml
content:
  title: Quarterly sales
  items:
    - { id: q1, label: Q1, value: 120 }
    - { id: q2, label: Q2, value: 150 }
config: {}
```
````

### `src/i18n/de.json`

```json
{
  "viewState": {
    "empty": "Noch keine Einträge"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Anzeige",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Werte anzeigen",
        "_rjsf_description": "Zeigt den Wert jedes Eintrags neben seiner Beschriftung"
      }
    }
  }
}
```

### `src/i18n/en.json`

```json
{
  "viewState": {
    "empty": "No items yet"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Display",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Show values",
        "_rjsf_description": "Show each item's value next to its label"
      }
    }
  }
}
```

### `src/i18n/es.json`

```json
{
  "viewState": {
    "empty": "Aún no hay elementos"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Visualización",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Mostrar valores",
        "_rjsf_description": "Muestra el valor de cada elemento junto a su etiqueta"
      }
    }
  }
}
```

### `src/i18n/fr.json`

```json
{
  "viewState": {
    "empty": "Aucun élément pour l’instant"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Affichage",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Afficher les valeurs",
        "_rjsf_description": "Affiche la valeur de chaque élément à côté de son libellé"
      }
    }
  }
}
```

### `src/i18n/ja.json`

```json
{
  "viewState": {
    "empty": "まだ項目がありません"
  },
  "config": {
    "display": {
      "_rjsf_title": "!表示",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "値を表示",
        "_rjsf_description": "各項目のラベルの横に値を表示します"
      }
    }
  }
}
```

### `src/i18n/ru.json`

```json
{
  "viewState": {
    "empty": "Пока нет элементов"
  },
  "config": {
    "display": {
      "_rjsf_title": "!Отображение",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "Показывать значения",
        "_rjsf_description": "Показывать значение каждого элемента рядом с его подписью"
      }
    }
  }
}
```

### `src/i18n/zh.json`

```json
{
  "viewState": {
    "empty": "暂无条目"
  },
  "config": {
    "display": {
      "_rjsf_title": "!显示",
      "_rjsf_description": "",
      "showValues": {
        "_rjsf_title": "显示数值",
        "_rjsf_description": "在每个条目的标签旁显示数值"
      }
    }
  }
}
```

### `src/index.ts`

```ts
import { nestedWidget } from '@vizchat/widget-sdk/nested';
import definition from './definition';

export default nestedWidget(definition, {
  // Called once after the handshake: build the DOM skeleton only; data is drawn in render
  mount(ctx) {
    ctx.root.className = 'flex h-full w-full flex-col gap-3 overflow-hidden';
  },

  // Called for the first frame and after every snapshot change. This redraws everything; compare snapshot with prev to update only part
  render(snapshot, _prev, ctx) {
    const { root } = ctx;
    root.replaceChildren();

    if (snapshot.content.items.length === 0) {
      const empty = document.createElement('p');
      empty.className = 'm-auto text-body-medium text-muted-foreground';
      empty.textContent = ctx.t('viewState')('empty');
      root.append(empty);
      return;
    }

    if (snapshot.content.title) {
      const title = document.createElement('h2');
      title.className = 'text-title-large';
      title.textContent = snapshot.content.title;
      root.append(title);
    }

    const list = document.createElement('ul');
    list.className = 'flex flex-col gap-2';
    for (const item of snapshot.content.items) {
      const row = document.createElement('li');
      row.className = 'flex justify-between text-body-medium';
      // data-vizchat-item: the canvas uses it to frame this item and anchor captions during narration
      row.dataset.vizchatItem = item.id;
      const label = document.createElement('span');
      label.textContent = item.label;
      row.append(label);
      if (snapshot.config.display.showValues) {
        const value = document.createElement('span');
        value.className = 'tabular-nums';
        value.textContent = String(item.value);
        row.append(value);
      }
      list.append(row);
    }
    root.append(list);
  },
});
```
