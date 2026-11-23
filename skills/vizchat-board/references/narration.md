# Narration, markers and waiting

Apart from markers and formulas, narration is plain text only: it is read aloud and shown as subtitles, with no markdown rendering — the symbols of `**bold**`, `` `code` `` and links are read out and seen.
Write narration as natural spoken language that sounds right read aloud: short sentences, one point per sentence, no parenthetical asides, no list-style strings of items.

## Formulas

Write math as LaTeX inside `$…$`, `$$…$$`, `\(…\)` or `\[…\]`: the subtitle typesets it (subtitles are one line, so all four are set inline, with fractions and the like expanded), and it is read aloud as its spoken form.
Do not build math out of Unicode (`eˣ`, `√65/2`, `x₀`) — it looks right in the subtitle and is read out wrong.

```yaml
markedText: '{@1}Let $f(x)=\frac{x+2}{e^{x}+a}$, {@2}and find its tangent at $x_0$.'
```

- Write a literal dollar sign as `\$` (`\$100`). Plain coordinates, numbering and the like that need no typesetting stay plain text (`(4,0)`).
- Markers cannot go inside a formula; put them before or after it.
- `check_board` reports a formula that is not valid LaTeX, an unpaired `$`, and a marker inside a formula.

## Voice and language

```yaml
config:
  sourceLocale: en # language code the narration and slide titles are actually written in (zh, en, ja, …; for an unknown code check_board lists every allowed value)
  locales: [en, zh] # narration languages kept with the board (written by the platform on creation; usually left alone)
  voice: Charon # the narration voice; Kore when omitted
```

- **When you create or rewrite the narration, set `sourceLocale` to the language you actually wrote**: without it the platform guesses the source language from the text, and narration mixed with terminology gets it wrong; `check_board` warns when it is missing.

- Voices: Kore, Despina, Erinome, Aoede, Leda (female); Charon, Rasalgethi, Sadaltager, Puck, Iapetus (male). `check_board` reports a voice not on this list.
- Write the narration in one language only (`sourceLocale`): the platform translates it into the other `locales` and keeps them in step after every save (only pages whose source changed, charged to the author by usage); do not write translations into the YAML yourself. Translations the author edited in the editor are kept.
- Publishing prepares the translation and the audio for every slide in each `locales` language (paid by the author; publishing stops if credits run short; players embedded on other websites play only these languages); viewers can also pick other languages and voices in the playback bar, and a language the author did not provide is generated at the cost of the first viewer who picks it.

| Marker | Syntax | Effect |
| --- | --- | --- |
| Point marker | `{@cueId}` | Triggers the cue's operations at that position |
| Range marker | `{@cueId:start}…{@cueId:end}` | Triggers at start; when the range ends, operations in that cue marked `transient` are undone automatically |

- Put a marker at the start of the sentence that describes the content: the operation fires first and the narration introduces it right after, keeping picture and speech in sync. Example: `{@1}First, set up the axes, {@2}then mark point P, {@3}and finally draw the tangent`.
- Several markers can sit at the same position and fire in written order; range markers can nest (outer one highlights the whole passage, inner one stresses a word):
  `{@setup}Now compare the quarters. {@bar:start}The bar chart shows all four quarters, {@q3:start}and the third quarter{@q3:end} grew the most{@bar:end}.`

Three correspondences are hard rules; validation blocks them as errors:

- Every cue has a marker in the narration — without a marker it never fires;
- Every marker's cue has operations — when you delete all operations of a cue, delete its marker too;
- A range marker's start and end are not at the same position.

Users can edit narration too: change the text directly (markers move with the text), drag markers, delete stale markers, so read the current content before changing narration rather than assuming the version you last wrote.
Users cannot add markers or switch between point and range markers — requests like "keep this highlight until the end of this sentence" or "trigger it here too" are yours to make.

## Waiting for content before narrating on

Some widgets have their own duration: a physics simulation plays in real time, a countdown runs, a random process accumulates samples at a set rate. During auto-play, once the narration ends the player waits for them to finish before turning the page —
this happens automatically, nothing to write, and the narration does not need padding to cover the animation.

When the next sentence talks about the result of the animation, put `wait` on the cue that starts that sentence: playback stops the narration there, waits for the listed widgets to finish, then runs the cue and reads on.

```yaml
markedText: '{@throw}Throw the ball at forty-five degrees. {@landing}It lands twenty meters away, the farthest any angle can reach.'
cues:
  - id: throw
    operations:
      - id: physics-sim-throw-play
        widgetId: physics-sim-throw
        operation: setPlayhead
        args: { time: 3 }
  - id: landing
    wait: [physics-sim-throw]
    operations:
      - id: physics-sim-throw-trace
        widgetId: physics-sim-throw
        operation: keepTrace
        args: {}
```

- `wait: [<widget id>, …]` waits only for the listed widgets; `wait: true` waits for everything on the page. The listed widgets must already be on this slide before the cue (or be pinned widgets); a wrong id is rejected as an error.
- When there is nothing to wait for, playback passes straight through without pausing. Viewers can always skip; in a video export each page waits at most the cap chosen when exporting.
- Use it only where not waiting would make the narration wrong; do not add it where narration and visuals already line up.
