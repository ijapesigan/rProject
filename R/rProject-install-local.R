#' Install Applications on Local Machine
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param what Character string.
#'   Vector of applications to install.
#'   Valid values include
#'   `"tmux"`, `"julia"`, `"mpdemo"`,
#'   `"lazygit"`, `"fastfetch"`, and `"quarto"`.
#' @param all Logical.
#'   If `all = TRUE`, ignore `what` and install all valid `what` values.
#' @param force Logical.
#'   If `force = TRUE`, install whether or not the application is
#'   available in the system.
#'
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' InstallLocal()
#' }
#' @export
InstallLocal <- function(
  what = c(
    "tmux",
    "julia",
    "mpdemo",
    "lazygit",
    "fastfetch",
    "quarto"
  ),
  all = FALSE,
  force = FALSE
) {
  all_apps <- c(
    "tmux",
    "julia",
    "mpdemo",
    "lazygit",
    "fastfetch",
    "quarto"
  )
  if (all) {
    what <- all_apps
  }
  bin <- file.path(
    Sys.getenv(x = "HOME"),
    ".local",
    "bin"
  )
  dir.create(
    path = bin,
    showWarnings = FALSE
  )
  for (i in seq_along(along.with = what)) {
    if (what[i] %in% all_apps) {
      if (force) {
        run_sh <- TRUE
      } else {
        if (Sys.which(names = what[i]) == "") {
          run_sh <- TRUE
        } else {
          run_sh <- FALSE
        }
      }
      if (run_sh) {
        install <- system.file(
          "shell",
          paste0(
            "install-",
            what[i],
            ".sh"
          ),
          package = "rProject"
        )
        if (run_sh) {
          tmp_dir <- tempdir()
          # bash, in the temporary folder (Unix only)
          wd <- setwd(dir = tmp_dir)
          system2(
            command = "bash",
            args = .ShellQuote(x = install)
          )
          setwd(dir = wd)
          on.exit(
            expr = unlink(
              x = tmp_dir
            ),
            add = TRUE
          )
        }
      }
    }
  }
}
