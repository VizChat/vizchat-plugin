---
description: Update my published VizChat widgets and boards - see what has updates, then apply them in one batch after I confirm
---

Update the VizChat works I have published.

1. Call `check_updates` (locally: `vizchat updates check`) and summarize what it lists: which works have updates, why, and how stale they are.
2. Tell me what `apply_updates` would do for this batch - widgets republished with the current runtime, board widgets moved to new versions where the data fits - and that publishing cannot be undone. Wait for my answer.
3. Once I agree, call `apply_updates` (locally: `vizchat updates apply --yes`) and report what started, what was updated, and what needs attention.
4. For each item in `needs_attention`, offer to fix it in my workspace (change the widget source or the board data), then publish as usual.

$ARGUMENTS
