# Storyboard document structure

A storyboard is a narrated step-by-step presentation: during playback, the markers in the narration trigger cues one by one and run their operations, while the narration is read aloud and shown as subtitles.

## Document structure

Four top-level keys: `meta` (the board's title, description and tags — see the SKILL's “A board's title, description and tags”), `slides` (array of slides),
`config` (canvas size, theme, widget defaults, page transitions, narration language and voice — each has its own reference), `pinned` (pinned widgets, a reference of its own).

```yaml
meta:
  title: <board title>
  description: <one- or two-sentence description>
  tags: [<tag>, <tag>]
  cover: <which page is the cover, optional, defaults to 1>
slides:
  - id: <slide id>
    title: <slide title>
    markedText: <narration with embedded markers>
    cues:
      - id: <cue id>
        operations:
          - id: <operation id>
            widgetId: <widget instance id>
            widgetType: <widget type, required for canvas_createWidget>
            operation: <operation name>
            args:
              <operation arguments>
```

| Level | Field | Meaning |
| --- | --- | --- |
| Slide | `id` | Descriptive kebab-case (e.g. `sales-overview`), unique within the document |
| | `title` | Outline title, shown in the outline panel |
| | `markedText` | Narration; embedded `{@id}` markers trigger cues |
| | `cues` | List of cues, one for each marker in the narration |
| | `transition` | Optional; the transition into this slide (page transitions have a reference of their own) |
| Cue | `id` | Unique within the slide, charset `[\w-]+` (`1`, `2` or `intro`, `rel` all work) |
| | `operations` | List of operations; widget operations and canvas operations both go here |
| | `wait` | Optional; wait for content to finish before running this cue (in the reference on narration and markers) |
| Operation | `id` | `<widgetId>-<action>[-<n>]` (e.g. `bar-chart-sales-create`), unique in the document |
| | `widgetId` | Widget instance id, `<slug>-<meaning>` (e.g. `bar-chart-sales`) |
| | `widgetType` | `<author>/<slug>[@<version>]`, required for `canvas_createWidget` |
| | `operation` | Operation name |
| | `args` | Operation arguments |
| | `transient` | Optional; `true` means undone once narrated (in the reference on widget and canvas operations) |

## Size limits

A storyboard has at most 200 slides and 500 pinned widgets; a dashboard at most 100 widgets and 1000 edges; each cue at most 10 operations.
