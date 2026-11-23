# Choosing widgets and widget versions

Check for reuse in priority order:

1. Widgets the user named or mentioned in the message;
2. The user's favorite widgets (`list_widgets` with `favorited: true` lists them) — write their `widgetType` directly;
3. `search_widgets`: built-in widgets and widgets other users published to the marketplace share one pool; results include a compact operation set and snapshot shape;
4. Only when none of these fit, make a new widget (`vizchat-widget` skill). If you only thought of building one because search came up empty, ask the user first whether to make a new one.

Search terms should be rich and precise: synonyms + Chinese and English + category words, e.g. a share chart as `饼图, 占比, pie chart, donut`;
cover the keywords for all needs in one call. When you know the exact types, use `describe_widget` to fetch the full operation docs
for several widgets at once. For every `widgetType` you write into the YAML, its operation docs should already be in context — fetch
them first if not. Field names and operation names follow what search or the operation docs return; the `Snapshot` in a search result is the
contract for `initialSnapshot` when creating the widget.

When no suitable widget is found, say so honestly. If the request can be partly met, build what you can and say clearly what is shown and what cannot be done yet.

**Widget versions**: write `widgetType` as `<author>/<slug>`; saving pins it to the current version as `<author>/<slug>@<version>`. An existing `@<version>`
is the version this board uses: keep it as is when editing. When talking to the user, never mention version numbers — say the widget's name ("the bar chart has a new version").

When the user wants to "update widgets", check with `list_board_widget_updates`, then update with `update_board_widgets`; don't edit version numbers by hand. When every update has
empty `affected_pages` and `unverifiable` false, update right away and tell the user afterwards; when any has `affected_pages` or is `unverifiable`, list those first
(widget, pages that may be affected) and ask before updating — when the user said "update" they didn't know the content on those pages would change, so asking tells them the risk
rather than going against their request. If the user clicked "Update with AI" in the update notice, they have already agreed: update that widget directly. After updating, fix the data on
the affected pages so the new version accepts it (`check_board` reports what doesn't fit) — don't leave data that doesn't fit; the new version silently falls back to defaults for it.

For a widget the user hasn't published yet, write `<author>/<slug>@draft`: only the user sees it (showing the latest successfully compiled draft). A board that references `@draft` cannot be published or exported. When publishing is blocked, publish that widget first (`publish_widget`, only after the user explicitly agrees), then use `update_board_widgets` to switch the draft reference to the published version.
