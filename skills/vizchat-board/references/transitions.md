# Page transitions

Turning the page plays a transition between the old and the new slide. Without one, it is a 400 ms fade; leave `transition` out of new storyboards and let the default apply.

```yaml
config:
  transition: { type: fade, durationMs: 500 } # type: none / fade / slide / wipe / zoom; durationMs: 200–1500
slides:
  - id: cover
    transition: { type: zoom } # overrides only the transition into this slide; unset fields follow config
```

- Set it once at the document level; override only on slides you want to stand out (the cover, section openers). For a hard cut write `type: none`.
- `slide` / `wipe` follow the direction of the page turn; jumps always fade; a slide whose narration starts by reusing widgets from the previous slide always fades, and those widgets move smoothly from their old place to the new one.
- Narration starts after the transition ends: each slide gets longer by the transition time, and so does the exported video.
- `type` has only these five values and `durationMs` must be within 200–1500; `check_board` reports an error otherwise.
