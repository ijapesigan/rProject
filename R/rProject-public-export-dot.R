.PublicExport <- function(root) {
  files <- list.files(
    path = root,
    all.files = TRUE,
    recursive = TRUE,
    no.. = TRUE
  )
  files <- files[!grepl(pattern = "^\\.git/", x = files)]
  # git check-ignore needs a repository. Outside one (e.g., a folder
  # downloaded from Overleaf), use a temporary empty repository with the
  # project as its work tree, so the .gitignore files still apply.
  inside <- identical(
    .VerifyGit(private = root, args = c("rev-parse", "--is-inside-work-tree")),
    "true"
  )
  git <- c("-C", .ShellQuote(x = root))
  if (!inside) {
    git_dir <- tempfile(pattern = "public-export")
    on.exit(unlink(git_dir, recursive = TRUE), add = TRUE)
    system2(
      command = "git",
      args = c("init", "-q", .ShellQuote(x = git_dir)),
      stdout = FALSE,
      stderr = FALSE
    )
    git <- c(
      paste0("--git-dir=", .ShellQuote(x = file.path(git_dir, ".git"))),
      paste0("--work-tree=", .ShellQuote(x = root))
    )
  }
  # what `make auto` would publish: files the .gitignore does not exclude
  ignored <- suppressWarnings(
    system2(
      command = "git",
      args = c(
        git,
        "check-ignore",
        "--no-index",
        "--stdin"
      ),
      input = files,
      stdout = TRUE,
      stderr = FALSE
    )
  )
  setdiff(files, ignored)
}
