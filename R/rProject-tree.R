#' Project Folders and What They Are For
#'
#' Prints the standard folders of the project's type
#' (`inst/template/folders.tsv`) with their purpose, and flags the
#' folders that differ from the standard: a folder that `make` creates
#' for the type but that is missing, and a folder that is not standard
#' for the type.
#'
#' The type comes from the `type` line in `.setup/scripts/project.R`
#' (see [Template()]); without it, it is guessed as in [AI()].
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns a data frame, invisibly, with the columns `folder`,
#'   `status` (`"present"`, `"missing"`, `"absent"` for an optional
#'   folder, `"not standard"` for this type, or `"unknown"`), `private`,
#'   and `purpose`.
#' @export
Tree <- function(path) {
  type <- .TemplateTypeGuess(path = path)
  all <- .TemplateFolders()
  standard <- .TemplateFolders(type = type)
  present <- dir.exists(file.path(path, standard$folder))
  status <- ifelse(
    present,
    "present",
    ifelse(standard$create, "missing", "absent")
  )
  out <- data.frame(
    folder = standard$folder,
    status = status,
    private = standard$private,
    purpose = standard$purpose
  )
  # folders in the project that the standard does not have
  top <- list.dirs(path = path, full.names = FALSE, recursive = FALSE)
  top <- paste0(setdiff(top, c(".git", ".setup")), "/")
  setup <- list.dirs(
    path = file.path(path, ".setup"),
    full.names = FALSE,
    recursive = FALSE
  )
  setup <- if (length(setup) > 0L) paste0(".setup/", setup, "/")
  known <- function(x, folders) {
    vapply(
      X = x,
      FUN = function(i) {
        any(startsWith(x = folders, prefix = i))
      },
      FUN.VALUE = logical(1),
      USE.NAMES = FALSE
    )
  }
  found <- c(top, setup)
  extra <- found[!known(x = found, folders = standard$folder)]
  if (length(extra) > 0L) {
    other <- known(x = extra, folders = all$folder)
    out <- rbind(
      out,
      data.frame(
        folder = extra,
        status = ifelse(other, "not standard", "unknown"),
        private = FALSE,
        purpose = vapply(
          X = extra,
          FUN = function(i) {
            hit <- all$purpose[startsWith(x = all$folder, prefix = i)]
            ifelse(length(hit) > 0L, hit[1], "")
          },
          FUN.VALUE = character(1),
          USE.NAMES = FALSE
        )
      )
    )
  }
  flag <- c(
    present = "  ",
    absent = "  ",
    missing = "! ",
    `not standard` = "? ",
    unknown = "? "
  )[out$status]
  message(
    paste0(
      "\n\nFolders of this ",
      type,
      " project (! missing, ? not standard for ",
      type,
      "):\n\n",
      paste0(
        flag,
        format(out$folder),
        "  ",
        format(out$status),
        "  ",
        out$purpose,
        ifelse(out$private, " (private)", ""),
        collapse = "\n"
      ),
      "\n\n"
    )
  )
  invisible(out)
}
