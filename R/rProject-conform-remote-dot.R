.ConformRemote <- function(path,
                           info) {
  # read-only: `git ls-remote` of the private repository (skipped quietly
  # without git, ssh, or a network) and the local origin URL
  github <- info$private_github
  rows <- list()
  has_git <- nzchar(x = Sys.which(names = "git"))
  has_ssh <- nzchar(x = Sys.which(names = "ssh"))
  if (has_git && has_ssh) {
    out <- tryCatch(
      expr = suppressWarnings(
        expr = system2(
          command = "git",
          args = c(
            "ls-remote",
            "--exit-code",
            paste0("git@github.com:", github, ".git"),
            "HEAD"
          ),
          stdout = TRUE,
          stderr = TRUE,
          env = c(
            "GIT_TERMINAL_PROMPT=0",
            "GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10'"
          ),
          timeout = 30
        )
      ),
      error = function(e) {
        character(length = 0)
      }
    )
    if (any(grepl(pattern = "not found|does not exist", x = out))) {
      rows <- c(
        rows,
        list(
          .ConformRow(
            rule = "remote",
            class = "decide",
            file = ".setup/repo/private-github.md",
            message = paste0(
              "the private repository ",
              github,
              " does not exist on GitHub"
            )
          )
        )
      )
    }
  }
  if (dir.exists(paths = file.path(path, ".git"))) {
    origin <- tryCatch(
      expr = suppressWarnings(
        expr = system2(
          command = "git",
          args = c(
            "-C", shQuote(string = path), "config", "--get",
            "remote.origin.url"
          ),
          stdout = TRUE,
          stderr = FALSE
        )
      ),
      error = function(e) {
        character(length = 0)
      }
    )
    name <- sub(
      pattern = "\\.git$",
      replacement = "",
      x = sub(
        pattern = "^.*[:/]([^:/]+/[^:/]+)$",
        replacement = "\\1",
        x = origin
      )
    )
    wanted <- c(github, info$public_github)
    if (length(x = origin) == 1L && !(name %in% wanted)) {
      rows <- c(
        rows,
        list(
          .ConformRow(
            rule = "remote",
            class = "decide",
            file = ".git/config",
            message = paste0(
              "origin (",
              name,
              ") is neither the private nor the public repository"
            )
          )
        )
      )
    }
  }
  .ConformBind(rows = rows)
}
