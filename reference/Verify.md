# Verify an Overleaf Push

Checks a push from Overleaf to the private GitHub repository against the
change-set log in `.setup/logs`.

## Usage

``` r
Verify(
  path,
  private = file.path(path, ".verify"),
  log = NULL,
  record = FALSE,
  error = TRUE
)
```

## Arguments

- path:

  Character string. Project path.

- private:

  Character string. Path to a clone of the private repository at the
  pushed commit. By default `.verify` in the project.

- log:

  Character string. File name of the change-set log in `.setup/logs`. If
  `NULL`, the newest log with a pending push in `.setup/logs/index.md`,
  else the log named in the pushed commit message
  (`Log: .setup/logs/<log>`), as for a fix-up push.

- record:

  Logical. If `TRUE`, write the commit and the result in the log's
  "Pushes" table and in `.setup/logs/index.md`, filling the pending row,
  or adding a row when there is none.

- error:

  Logical. If `TRUE`, stop with an error when a check fails.

## Value

Returns a data frame of checks with the columns `check`, `status`, and
`detail`.

## Details

The checks, and when each fails:

- **New commit:** the commit is already recorded in `index.md`
  (`.verify` is stale, or there was no new push). Nothing is recorded.

- **Listed files:** a file listed under "Files to update in Overleaf" is
  missing from or differs in the private repository. The list is the one
  of the pushed commit: the section of the log with a code block that
  starts with the commit's first line (the top-level lists for the log's
  own commit message; the lists inside a later push's `##` section, none
  for a push of records only). If no block matches, every list in the
  log is used.

- **Deletions:** a file listed under "Delete in Overleaf" is still in
  the private repository.

- **Unlisted changes:** (warning only) other files differ between the
  project and the private repository (`.setup/notes/claude.txt`, the
  resume commands, and `.setup/todo/`, the user's to-do list, are not
  counted).

- **Commit message:** (warning only) the last commit message does not
  end with `Log: .setup/logs/<log>`.

- **Secrets:**
  [`SecretScan()`](https://github.com/ijapesigan/rProject/reference/SecretScan.md)
  finds a token in the private repository.

- **Public export:** a file that `make auto` would publish is private
  (e.g., `.setup/ai/`, `.setup/logs/`, `.setup/repo/`, `AGENTS.md`) or
  larger than 50 MB.

- **Repo info:** `.setup/repo/private-overleaf.md` is not an Overleaf
  project URL (for example, a share link, which grants access). Warning
  only: a file in `.setup/repo/` is missing, `private-github.md` differs
  from the `.verify` remote, or `public-github.md` differs from the
  repository in `clone.sh`.

Generated files (e.g., `NAMESPACE`, `man/`), local folders (e.g.,
`.library`), and secret files are never compared.

The private repository must be cloned on the host, because SSH keys are
not available in the container. `.setup/scripts/verify.sh` clones or
pulls it into `.verify` (local only; never uploaded) and then calls
`Verify()`.

## Author

Ivan Jacob Agaloos Pesigan
