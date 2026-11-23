# Error codes, self-correction and operations that need confirmation

Every failure has the same shape: `{code, reason?, message, hint, retryable, doc_url?, errors?}`. Decide the next step by `code`;
`reason` is only a finer description; `errors` points to each location (`file` + `line`, or `path`).

| `code` | What to do next | Retry |
| --- | --- | --- |
| `invalid_argument` | Fix the arguments and call again. | no |
| `client_outdated` | Upgrade the CLI, then run the command again. | no |
| `auth_required` | Sign in or re-authorize, then retry. | no |
| `invalid_content` | Fix the content listed in `errors`, then retry. | no |
| `confirmation_required` | Wait for the user to confirm (host confirmation dialog or the confirmation page in `hint`); in the CLI, rerun with --yes only after the user agrees. | no |
| `unavailable` | Retry later; if it keeps failing, tell the user. | yes |
| `permission_denied` | Check the target. If it belongs to someone else, is unlisted, or is outside the granted scope, tell the user. | no |
| `not_found` | Check the reference; list or search first, then retry. | no |
| `conflict` | Re-read the latest content before changing it again, or pick another name. | no |
| `merge_pending` | Merge the pending changes first. | no |
| `quota_exceeded` | Tell the user (top up credits or free storage); do not retry. | no |
| `local_required` | Tell the user this can be done in a full local environment and explain how, following `hint`. | no |
| `internal` | Tell the user. | no |

Operations that need the user's confirmation (delete, publish, writing personal preferences) don't run until confirmed. The host may
ask for confirmation itself, or the call may return `confirmation_required` with a confirmation page link: pass the link to the user
as is, ask them to open it, check it and confirm, and to tell you when done; once they say they've confirmed, call the same operation
again with exactly the same arguments (changed arguments make it a different action that needs confirming again). The link is valid
for a day; if it has expired, calling again gives a new one. Before confirmation, don't retry, don't call again with changed
arguments, don't switch tools to get around it; if the user declines, accept it.
