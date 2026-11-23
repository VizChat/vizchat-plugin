# Writing a demo

`src/demo.stb` is an ordinary storyboard, written as `vizchat-board` describes; it is a user's first look at the widget: the marketplace detail page plays it, and publish review renders it slide by slide.
This page covers only the criteria specific to demos.

**Refer to this widget as `<author>/<slug>@draft`**: previews and the publish review show the current draft, and publishing pins it to the version being published, so you never edit the version yourself.
Refer to other widgets as usual (they are pinned to an exact version when added).

## Topic and structure

- **One real topic per demo**: monthly sales, a geometry problem, a piece of code to walk through. Operations serve the story, ordered as "set up → develop → discover → wrap up", 3–7 slides.
- The compile gate `demo-op-coverage` requires every declared op to be demonstrated. The step that covers it still needs a reason in the narration ("this number was entered wrong, let's fix it", "now look at it another way") —
  don't line the ops up as a feature checklist, and don't tack an unmotivated action onto the last slide.

## Narration

- **Say what the viewer sees change**: "three more months come in", not "addItems appends three items". No op names, field names or implementation details, and no feature-description words like "basic form", "initialize"
  or "batch". A camelCase op name or `canvas_*` in the narration is blocked by the gate `demo-narration-plain`.
- Every number in the narration can be found on that slide; the unit goes with the first number it applies to.
- **Language**: `config.sourceLocale` states the narration's language. The narration and slide titles are translated into every language, but **text inside widgets is not translated** — chart titles, axis and data labels,
  body text: every viewer sees the original. So write the whole demo (slide titles, text inside widgets, narration) in one language, the one your viewers read best;
  a widget meant for viewers of every language uses English.
- Keep on-canvas text sparse and neutral: conclusions go in the narration; the canvas shows mostly numbers, symbols, formulas and short labels.

## Formulas

All math in the narration is written as `$…$` (variables, equations, sub- and superscripts, Greek letters, statistics): `$\sqrt{1000} \approx 32$`, `$\chi^2$`, `$R_0$`. They are read aloud the way they are spoken
and rendered as formulas in the subtitles. Don't spell math with Unicode (`√`, `²`, `₀`, `π`, `≈`) — it gets read out character by character, and `check_board` flags it. Widget fields that render LaTeX
take LaTeX too.

## Layout

- Follow the layout grid in `vizchat-board`: a single lead widget is full-width (1760×740) or centered (860×740); the lead widget plus one explanation uses a 7:5 left-right split; content stays within y 200–940.
- The lead widget is this widget; its position and size stay the same across slides and only its content changes; an auxiliary widget is at most half the lead widget's area.

## Expressive tools

Each one needs a reason in the narration; without one, leave it out:

| Tool | When | How |
| --- | --- | --- |
| Background | Every demo picks an html-embed preset that fits the scene (`paper` for science, `desk` for charts and business, `space` for astronomy and 3D, `nature` for biology and geography, `plain` for documents) | The first pinned widget, see "Canvas background" in `vizchat-board`; it carries no information |
| Item highlight + `text` | The narration names a specific data point | `items` of `canvas_highlight`; `text` states the conclusion itself; range cue + `transient: true` |
| Widget highlight `glow` / `beam` + `others: fade` | The slide has auxiliary widgets and the narration says "look at this chart" | Range cue + `transient: true` |
| The widget's own highlight op | Stepping through code line by line, a test paper question by question, a solution step by step | Persistent, advancing slide by slide |
| `entrance` | The narration wants the viewer to notice a newly appearing widget | Follow the entrance table in `vizchat-board`; at most one `zoom` per slide; ordinary content omits it |
| `transition` | The opening slide or the first slide of a new section | Not at document level; one or two in the whole demo at most |
| Auxiliary widgets | The narration has a conclusion, formula or data note that should land on the canvas | Add a rich-text or kpi-card in a 7:5 split, with an edge if needed; slides that simply show this widget keep a single lead |
| Zooming the viewport `canvas_setViewport` | The widget is dense and a detail needs a closer look | Range cue + `transient: true`, pull back once explained |
