# Canvas coordinates and layout

The canvas size in pixels is declared by `config.canvas` (default 1920 × 1080). The origin is the top-left corner; `position`, width and height are all pixels in this coordinate system, and during playback the whole canvas scales proportionally to the screen.

**Type sizes are fixed; pick the canvas size by use to set the information density**: the same type style is the same size on every board, widgets don't change their type sizes, and you don't shrink text to fit more.
To fit more content, use a bigger canvas; to make each character bigger on screen, use a smaller one. Choose it by purpose when creating the board; the table below gives starting points, and width and height can also be custom
(480–7680 per side, aspect ratio between 1:4 and 4:1):

| Use | Canvas | Density |
| --- | --- | --- |
| Presentation (default): projectors and on-screen playback | 1920 × 1080 | Standard |
| Handout: close reading, printing | 2400 × 1350 | High (text relatively small) |
| Large print: the back of a classroom | 1440 × 810 | Low (text relatively large) |
| 4:3 / 16:10 | 1440 × 1080 / 1680 × 1050 | Standard |
| Portrait: full-screen phones, short videos | 1080 × 1920 | Portrait |
| Square: social media | 1080 × 1080 | Square |
| Academic poster (with camera zoom) | 2400 × 3394 | Very high (A0 proportions) |

Changing the canvas size of an existing board doesn't re-lay it out: widget coordinates stay put, and you rearrange them for the new canvas.

The grid and common layouts below are written for the default 1920 × 1080; for other sizes, recompute from the width and height with the same margin (80) and gutter (40).

Horizontal grid: 80 safe margin left and right, 12 columns × 110 + 11 gutters × 40 = 1760, content area x ∈ [80, 1840].

- Column start `col(n) = 80 + (n-1) × 150`: col(1)=80 col(4)=530 col(5)=680 col(7)=980 col(8)=1130 col(9)=1280
- Span width `span(n) = n × 110 + (n-1) × 40`: span(4)=560 span(5)=710 span(6)=860 span(7)=1010 span(8)=1160 span(12)=1760

Vertical (storyboards): regular widgets go in y ∈ [200, 940] (canvas height minus 140); the title band above and the footer band below are reserved for pinned widgets. Dashboards have neither band; see their reference.

Common layouts (all on the grid, right edge always 1840, bottom always 940 — copy as is):

- Single widget, full width: `{ x: 80, y: 200 }`, 1760×740
- Single widget, centered: `{ x: 530, y: 200 }`, 860×740
- Left/right halves: left `{ x: 80, y: 200 }` 860×740, right `{ x: 980, y: 200 }` 860×740
- Top/bottom halves: top `{ x: 80, y: 200 }` 1760×350, bottom `{ x: 80, y: 590 }` 1760×350
- Small left, large right 4:8: left `{ x: 80, y: 200 }` 560×740, right `{ x: 680, y: 200 }` 1160×740
- Large left, small right 7:5: left `{ x: 80, y: 200 }` 1010×740, right `{ x: 1130, y: 200 }` 710×740
- Left + right top/bottom: left `{ x: 80, y: 200 }` 860×740, top right `{ x: 980, y: 200 }` 860×350, bottom right `{ x: 980, y: 590 }` 860×350
- Three across: `{ x: 80, y: 200 }` / `{ x: 680, y: 200 }` / `{ x: 1280, y: 200 }`, each 560×740
- Top strip + two columns below: strip `{ x: 80, y: 200 }` 1760×H (H fits the content, commonly 120–200), the two columns from y = 240 + H down to 940, split in one of the ratios above

The heights above are the room available, not sizes to fill. **Size each widget to its content**: first decide which widget leads the page and give it the large area;
shrink widgets with little content (a two-row table, a set diagram with a few points) to just fit, and give the space to the widgets that need it. Leave no large empty
areas — spread the remaining space between widgets and along the margins, not inside widget frames.

**Size text boxes by the font size**: rich-text leaves about 26px above and below its content, plus "font size × line height" per line, and there are margins between headings and paragraphs. So a one-line `headline-small` (56px) heading box needs about 130px of height, and a one-line `label-small` (24px) footnote box about 90px; body text in `body-medium` (34px) takes about 51px per line.
When the box is shorter than its content, the text is scaled down as a whole, and below seven tenths the review flags it — make the box taller, cut the text, or switch to a smaller style; don't squeeze it in by shrinking.

**Text on one page looks about the same size and density across widgets**: titles and widgets you want to emphasize can be larger, but no unexplained gaps — a whole
PDF page shrunk down, or a few small words in a big frame, are this kind. For widgets whose text scales with the frame (PDF, charts, diagrams), size the frame so
the text lands close to the body text.
