# Widget data and YAML syntax

When creating a widget, `content` carries only the necessary data; omit `config` to use the default configuration. Data comes from what the user provides, the documents you read, or computed results.

**Referencing workspace files**: get the file's `ref` (returned when listing or reading files) and write `{ kind: document, value: <ref> }` in the widget's `content.source`;
for an external address write `{ kind: url, value: 'https://…' }`. `value` must come from a real return value — never make one up.

```yaml
operation: canvas_createWidget
widgetId: pdf-viewer-report
widgetType: vizchat/pdf-viewer
args:
  position: { x: 80, y: 200 }
  width: 1760
  height: 740
  data:
    initialSnapshot:
      content:
        source: { kind: document, value: 01900000-0000-7000-8000-000000000001 }
```

**Exact values**: when the problem gives a fraction, a root or π (`2√2`, `1/6`, `π/4`), write it as a constant expression string and the widget
shows it in exact form (`(1, 2\sqrt{2})`, `\frac{2}{9}`); don't work it out to a decimal first — once it is `2.8284271` it can never be shown as
`2√2` again. Syntax: numbers, `+ - * / ^`, parentheses, `sqrt` / `cbrt` / `sin` / `cos` / `tan`, `pi` / `e`, no variables. In math-coordinate
it goes on the object's `definition: { kind: exact, params: { fields: { y: "2*sqrt(2)" } } }` (keep a placeholder number in the field itself);
a probability tree's branch chances and a distribution's `p` take it directly (`p: "1/3"`). Values that are not exact stay plain numbers —
`0.5` is shown as `0.5`.

**Showing sources alongside**: when you take information from a document or web page to visualize it, decide whether to put the original source on the canvas too (document widgets generally support "locate + highlight").

- Yes: you cite key data or a chart from a PDF (show the PDF too, at that page); you cite a snippet of code or a config file (show the source file and highlight those lines);
  you cite a core argument from a web page (show the page and highlight that passage); the user asks to "show the source".
- No: the information comes straight from user input; minor background knowledge or definitions; the document content has been fully turned into chart data (e.g. CSV → bar chart); the canvas is already full.
- When the source is one part of a page (a question, a quoted passage) and readers need to read it, show only that part (pdf-viewer's focusRegion) in a wide strip shaped roughly like it, placed on top, with two columns below;
  to point out where it sits in the original, show the whole page and mark that spot with canvas_highlight. The two combine: focus on a question, then highlight its key condition.
  Use "source left, analysis right" only when the whole page needs reading: source on the left, analysis on the right, using "small left, large right 4:8".

## YAML rules

There are only two correct ways to write a line break: a block scalar `|`, or `\n` inside double quotes. YAML single-quoted scalars don't process escapes — the `\n` in `'…\n…'` is a backslash and the letter n,
and it shows up on screen literally.

```yaml
# Multi-line content: block scalar, no escapes, no quotes, least error-prone
content: |
  ## Title
  - List item 1

# Short text with a line break: double quotes
content: "## Title\nKey point: short content"

# Single line, no break: single quotes
content: '## Title'
```

The same applies when you write YAML flow (`{...}`) in the `value` of `edit_yaml_path`.
