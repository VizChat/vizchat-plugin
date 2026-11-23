# Reviewing a board

Follow this page as the last step of the production flow, or when the user asks you to check a board.

## 1. Get the machine-checkable findings

`render_board` (locally `vizchat board render <file>`) renders page by page and returns each page's screenshot, measurements and findings; use `pages` to look at just a few pages and `theme`
to look at the light or dark variant. Each page is captured in its end state (after all its cues have run): a caption card that goes away when its sentence ends, or the middle of a step-by-step reveal, is not in it — use
`cues: [{ page, cue }]` to capture the moment that cue is speaking, and check on that image whether the card covers a title or another widget. Passing only `cues` skips the page end states;
at most 8 screenshots per call in total. Findings cover these dimensions:

| Dimension | What is checked |
| --- | --- |
| Correctness | Widget render errors; structure and reference errors (same as `check_board`) |
| Overflow and overlap | Widgets outside the canvas; truncated text; widgets overlapping each other |
| Readability | Text shrunk too far (below 70% of its size); text smaller than the smallest type style; contrast between text and background |
| Visibility | Elements that are set but not visible (transparent, zero size, covered, labels hidden by default) |

These all have a clear right and wrong. Density, spacing and alignment have no absolute standard, so they are not checked by machine: judge them from the screenshots as described in the next section; the widget count, text length and narration duration in each page summary are there for reference. When no screenshots are attached (your environment can't read images), judge from the text measurements.

## 2. Then look at what needs judgment

Beyond screenshots and measurements, go through each page:

- **Matches personal preferences** — this comes first, and wins over any item below when they conflict;
- **Density fits the scene**: there is no absolute standard; first think about who the board is for and where it is seen. A presentation (seen from a distance, while listening) should be sparse: one point per slide, only the key points on screen,
  details in the narration, a minute or two of narration per slide at most; a handout (read up close, printable) can be dense, with a full derivation or comparison on one page; a poster relies on the camera pushing in and can be very full overall,
  but each part a camera shot frames must still read at a glance. Density and narration length in personal preferences come first;
- **Spacing shows grouping**: gaps within a group are equal, and gaps between groups are clearly larger (a heading sitting close to its body and apart from the next block is right); don't let two blocks touch by accident;
- **Alignment**: widget edges line up to shared columns and page margins — scattered widgets make the layout look careless; a full-screen 3D scene or freely laid-out poster blocks follow their own logic;
- **Label only what is being explained**: annotations and highlights on a figure follow the narration and are cleared once that step is done, so labels from earlier steps don't pile up on screen;
- **Information density**: a sensible ratio of text to visualization; what can be shown as a chart isn't written as a paragraph;
- **Layout** (judge from the screenshots, not numbers): no large empty areas on the page or inside widget frames — including a PDF focused on one part sitting in a frame of a different shape with blank margins (reshape the frame to match the part);
  the lead widget is large enough, and widgets with little content are shrunk to just fit;
- **Consistency across widgets** (judge from the screenshots): text on one page looks about the same size and density across widgets. Titles and widgets you want to emphasize can be larger;
  fix unexplained gaps (a whole PDF page shrunk down, a few small words in a big frame) — resize widgets, and show only that part (focusRegion) when quoting one part;
- **Narrative** (storyboards only): narration and picture are in sync, the cue rhythm, transition sentences between slides point the right way;
- **Accuracy**: data matches its sources, and citations appear with the information.

## 3. Make a decision for each finding

**Hard items** — widget render errors, structure and reference errors reported by `check_board` — fix them directly, no choice: they break the board for whoever views it.

For every other finding, pick one of three:

| Decision | When | What to do |
| --- | --- | --- |
| Fix | The fix is clear, doesn't change the meaning of the content, and is cheap | Change it directly, then render again to check |
| Accept | There is a sound reason: the content needs it (a data table that must be shown in full), it matches personal preferences, the widget's nature dictates it (a full-screen 3D scene has no "alignment") | Give the reason when you report |
| Ask the user | It involves the user's intent or taste (complete vs. concise), personal preferences conflict with the standard, fixing it would change the meaning, or you're unsure | See below |

When you **ask the user**, merge findings of the same kind into one question instead of interrupting item by item: say which pages and what kind of problem, give two or three options with their consequences, and add your recommendation. Example:

> Slides 3, 5 and 7 are text-heavy (about 260 characters each, and this board is for presenting — too much to read from a distance). Options: A. split each into two slides — longer, but each slide is easier to read; B. condense to key points
> and move the details into the narration; C. keep them as they are. I recommend B.

**Decisions are not recorded per finding**: reviews are not stored, so reviewing the same board again raises the same judgement findings — follow what you and the user already settled
in this conversation instead of asking again.

**Taste can become a preference**: when the user's answer is a matter of taste ("I just like full slides"), ask whether to save it to personal preferences, and if they agree, `update_preferences`
(density and narration length go in their own fields, everything else in `instructions`). Issues of that kind are then handled per the preference.

## 4. Report

Tell the user what you fixed, what you accepted (with reasons), and what is waiting for their decision. When a board is published, the publish job runs the same review again on the content being published:
findings that need judgment appear in the publish summary and don't block publishing; unfixed hard items make the publish fail.

The web workbench's editor also renders every page in the background and prechecks it with the same rules (default thresholds); treat the "issues found by the page-by-page check" that the user hands you from the problems panel the same way as the findings here.
Those measurements come from the canvas in the user's browser and can be affected by widget code: when in doubt, re-check with `render_board` and go by its result.
