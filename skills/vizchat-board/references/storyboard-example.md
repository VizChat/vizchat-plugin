# Complete example, common edits and quality

## Complete example

This example shows the structure (`slides[].cues[].operations[].args.data.initialSnapshot`) and the "marker — cue — operation" correspondence; `content` fields and operation names like `reveal`
belong to each widget's own contract — follow their operation docs.

```yaml
slides:
  - id: sales-overview
    title: 'Sales overview'
    markedText: '{@1}First, the key finding. {@2}Building on it, the pie chart on the right breaks down the sales share of the three products. {@3:start}Product B is the clear leader{@3:end}.'
    cues:
      - id: '1'
        operations:
          - id: rich-text-overview-create
            widgetId: rich-text-overview
            widgetType: vizchat/rich-text
            operation: canvas_createWidget
            args:
              position: { x: 80, y: 200 }
              width: 860
              height: 740
              data:
                initialSnapshot:
                  content:
                    blocks:
                      - markdown: |
                          ## Sales overview
                      - markdown: |
                          ### Key finding
                          - Product B leads
                  config:
                    revealUpTo: 1
      - id: '2'
        operations:
          - id: pie-chart-sales-create
            widgetId: pie-chart-sales
            widgetType: vizchat/pie-chart
            operation: canvas_createWidget
            args:
              position: { x: 980, y: 200 }
              width: 860
              height: 740
              title: 'Sales share ($K)'
              entrance: rise # the narration explicitly builds on the previous finding
              data:
                initialSnapshot:
                  content: <the widget's content>
      - id: '3'
        operations:
          - id: rich-text-overview-reveal-analysis
            widgetId: rich-text-overview
            operation: reveal
            args: { upTo: 2 }
          - id: pie-chart-sales-highlight-b
            operation: canvas_highlight
            transient: true # range cue; removed automatically at {@3:end}
            args:
              target: pie-chart-sales
              items: [item-2]
              text: Product B has the largest share
```

## Common edits

- "Change product A's figure to 250": `read_yaml_path` to find the operation → `edit_yaml_path` to change that value → `check_board`.
- "Make the page number read 'Page N of M'": read `pinned.widgets[?id='default-page-number']` to confirm it exists → `set`
  `pinned.widgets[?id='default-page-number'].bindings.content` to `"'Page ' + slide.number + ' of ' + slides.length"` → `check_board`.
- "Make this widget's move a separate step": insert a move operation, add a cue and a narration marker for it, and adjust the surrounding text so the narrative flows.

## Quality

Narrative structure matters more than piling up information:

- 3–6 progressive steps per presentation, with a clear progression between them (whole to part, simple to complex);
- 1–3 widgets per slide, at most 15 operations in total;
- rich text on each slide totals at most 120 characters;
- narration length follows the personal preference: short about 30 seconds, medium about a minute, long at most two minutes, and
  medium when unset. Speech runs about 2.5 English words (4.5 Chinese characters) per second; the `narration_seconds` that
  `render_board` returns is estimated at that rate.
