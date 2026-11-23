# Dashboards

A dashboard is a static canvas layout: no narration, no steps, all widgets laid out at once. The coordinate system, columns, widget types and editing method are the same as for storyboards, but there is **no title band and no footer band**.
The canvas has no edges, but `config.canvas` (default 1920 × 1080) sets **the view it opens with**: the first screen of the editor and of read-only viewing fits the box from (0, 0) to (width, height) to the window,
and covers, render screenshots and embeds show that same box. Widgets outside it still exist but readers have to pan to see them, and the geometry check flags them. So keep widgets inside the box: for the default box, lay them out on the storyboard grid within
x ∈ [80, 1840], y ∈ [80, 1000]; with more content, make the box bigger — see the canvas and layout reference for choosing a size. Document structure:

```yaml
meta: # a board's title, description and tags — same as storyboards
  title: <board title>
  description: <one- or two-sentence description>
  tags: [<tag>, <tag>]
config: # optional: canvas size (the view it opens with), theme, background, widget defaults — same as storyboards
nodes: # widget list
  - widgetId: rich-text-intro
    widgetType: vizchat/rich-text
    position: { x: 80, y: 80 }
    size: { width: 1760, height: 120 } # optional
    snapshot: # optional, the widget's initial state
      content:
        markdown: '## This quarter'
  - widgetId: bar-chart-sales
    widgetType: vizchat/bar-chart
    title: 'Sales by region' # optional, the widget's title — the same as canvas_createWidget's title in storyboards; charts draw it as the chart title
    # frameStyle: { preset: glass } # optional, this widget's frame; overrides the document and type levels
    position: { x: 80, y: 240 }
    size: { width: 1010, height: 760 }
edges: # optional, edges between widgets
  - id: e1
    source: rich-text-intro
    target: bar-chart-sales
```

Editing by path:

```
edit_yaml_path(file="dashboards/overview.dsb", edits=[
  {path: "nodes", action: "append", value: '{"widgetId": "rich-text-note", "widgetType": "vizchat/rich-text", "position": {"x": 80, "y": 640}}'},
  {path: "nodes[?widgetId='bar-chart-sales'].position.x", action: "set", value: "1130"},
])
```

It must be readable on one screen: arrange it for "see everything at once, compare side by side", with a clear hierarchy and the most important metric at the top left.
