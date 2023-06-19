#' Install Applications on Local Machine
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param what Character string.
#'   Vector of applications to install.
#'   Valid values include
#'   `"tmux"`, `"julia"`, `"mpdemo"`, and `"lazygit"`.
#' @param all Logical.
#'   If `all = TRUE`, ignore `what` and install all valid `what` values.
#'
#' @export
InstallLocal <- function(what = c(
                           "tmux",
                           "julia",
                           "mpdemo",
                           "lazygit",
                           "pfetch"
                         ),
                         all = FALSE) {
  all_apps <- c(
    "tmux",
    "julia",
    "mpdemo",
    "lazygit"
  )
  if (all) {
    what <- all_apps
  }
  for (i in seq_along(what)) {
    if (what[i] %in% all_apps) {
      if (Sys.which(what[i]) == "") {
        run_sh <- TRUE
      } else {
        run_sh <- FALSE
      }
      if (run_sh) {
        install <- system.file(
          "extdata",
          paste0("install-", what[i]),
          package = "rProject"
        )
        bin <- file.path(
          Sys.getenv("HOME"),
          ".local",
          "bin"
        )
        dir.create(
          bin,
          showWarnings = FALSE
        )
        app <- file.path(
          bin,
          what[i]
        )
        if (!file.exists(app)) {
          run_sh <- TRUE
        }
        if (run_sh) {
          tmp_dir <- tempdir()
          system(
            paste(
              "(",
              "cd",
              tmp_dir,
              ";",
              "bash",
              install,
              ")"
            )
          )
          on.exit(
            unlink(
              tmp_dir
            )
          )
        }
      }
    }
  }
  return(NULL)
}
