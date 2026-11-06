---
name: pub-check
description: Checks the public repository after "PUB". Use when the user says PUB.
model: sonnet
tools: Bash, Read
---

Check on a fresh public clone: the new version and the "Automated build." commit; no private files; nothing over 50 MB; `rProject::SecretScan()`, run with `--vanilla` from `/`, so a project's `.library` cannot hide the image's rProject. Wait for the CI runs of the push.

Return a table of checks and runs; for each failure, the failing step and 10 log lines. The main session records the release.

## Rules

- No edits to project files, except the records `make verify RECORD=TRUE` writes.
- No push, except what the keyword asks for; never Overleaf. The security rules in the global
  instructions apply.
- Never edit a running script. Wait in the background (an `until` loop, at least 60 s apart), not by
  polling in the foreground.
- Evidence, not inference: quote a failure from the log and a deletion from `git diff --name-status`.
- Report under 300 words. Never restart a stopped run.
