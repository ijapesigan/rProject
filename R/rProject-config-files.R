#' Setup Config Files
#'
#' Clones a public `dotfiles` GitHub repository and runs `make` in it.
#' The clone ignores the global Git configuration,
#' so URL rewrites to SSH host aliases do not apply
#' and the repository is fetched anonymously over HTTPS.
#' This also works inside a container without access to SSH keys.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param repo Character string.
#'   GitHub repository in the form `owner/name`.
#'
#' @export
ConfigFiles <- function(repo = "ijapesigan/dotfiles") {
  if (Sys.which("git") == "") {
    stop("git is not installed.")
  }
  tmp_dir <- tempfile(pattern = "dotfiles")
  on.exit(
    expr = unlink(
      tmp_dir,
      recursive = TRUE
    ),
    add = TRUE
  )
  status <- system2(
    command = "git",
    args = c(
      "clone",
      "--depth",
      "1",
      paste0("https://github.com/", repo, ".git"),
      .ShellQuote(x = tmp_dir)
    ),
    env = c(
      "GIT_CONFIG_GLOBAL=/dev/null",
      "GIT_TERMINAL_PROMPT=0"
    )
  )
  if (status != 0) {
    stop(
      paste0(
        "\n\nCould not clone https://github.com/",
        repo,
        ".\n\n"
      ),
      call. = FALSE
    )
  }
  # make -C runs make in the clone, as `cd <clone> && make` did
  status <- system2(
    command = "make",
    args = c(
      "-C",
      .ShellQuote(x = tmp_dir)
    )
  )
  if (status != 0) {
    stop(
      paste0(
        "\n\n`make` failed in ",
        repo,
        ".\n\n"
      ),
      call. = FALSE
    )
  }
  invisible(NULL)
}
