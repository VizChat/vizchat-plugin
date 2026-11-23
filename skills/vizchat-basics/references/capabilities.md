# What VizChat can do

Widgets can be custom-built: when no existing widget fits, build a new one on the spot (the `vizchat-widget` skill) and put it in
the board as soon as it is built. Missing a ready-made widget is no reason to fall back to plain text or a static image; when to
build one for a board, and whether to ask the user first, is in the reference on choosing widgets in the `vizchat-board` skill.

Widgets other users published are ready to use: built-in widgets and widgets other users published to the marketplace sit in one
pool that `search_widgets` searches together, and what you find goes straight into the board. Search first; build your own only
when nothing fits.

Results are live: charts stay wired to real data, and widgets keep running and stay interactive both on the canvas and during the
presentation — not a screenshot. Present everything with widgets — data goes into chart widgets, files go into document widgets by
`ref`; don't render a chart into an image and paste it in, since its data can then neither be changed nor explored.

Narration is read aloud: when a storyboard plays, its narration is read sentence by sentence and shown as subtitles, and the
markers in it trigger the canvas changes as the reading reaches them. Narration is written for the ear; how to write it is in the
`vizchat-board` skill.

Boards can be published and forked: a published board gets a public work page that opens without signing in and is indexed by
search engines; anyone can fork it and change their own copy, and the license chosen when publishing governs use outside VizChat. The files a
board references become public with it. The user publishes a board in VizChat (Publish in the property panel); your part is to
make the board right and tell the user which files in it will become public. The other way round, when the user wants to start
from a published board, `search_boards` finds one in the marketplace and `apply_board` forks it into the user's workspace, giving a
copy they can change freely.

Boards can be exported: a board exports as a `.vizpkg` package that carries the files it references, its narration audio and the
widgets it uses, and can be imported again into any workspace; the desktop app can also export a storyboard as MP4 video with narration audio, PNG images (several slides packed into a ZIP), a PDF, or PowerPoint (text widgets become editable text boxes, other widgets are each an image, narration goes into the speaker notes; one image per slide or one per cue),
and export a single widget as a PNG with a transparent background. The user does all of this from the property panel (or the widget's toolbar); the agent can't export on their behalf. In a local environment, the whole workspace can be exported with a command (see the local operations reference).
SVG export isn't available; on the web, the image, PDF, PowerPoint and video options guide the user to install the desktop app.
