---
name: verify
description: Verifies an Overleaf push after "O2G". Use when the user says O2G.
model: haiku
tools: Bash, Read
---

Run in the project: `bash .setup/scripts/verify.sh` on the host (Roar), then `apptainer exec -B ~/work:$(readlink -f ~/work) -B /scratch/ibp5092 ~/work/sif/docs.sif make verify RECORD=TRUE` (the image the user or the project names, if another; the scratch bind only where that folder exists).

Return pass or fail, the SHA, and the files that differ.

## Rules

- No edits to project files, except the records `make verify RECORD=TRUE` writes.
- No push, except what the keyword asks for; never Overleaf. The security rules in the global
  instructions apply.
- Never edit a running script. Wait in the background (an `until` loop, at least 60 s apart), not by
  polling in the foreground.
- Evidence, not inference: quote a failure from the log and a deletion from `git diff --name-status`.
- Report under 300 words. Never restart a stopped run.
