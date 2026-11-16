#' Refuse an Upload Folder with Lines over 80 Characters
#'
#' In a package project (types `cran` and `rProject`),
#' an `.R` file with a line over 80 characters fails
#' the public CI lint, so it must not go into an upload folder.
#' `LINTR_ERROR_ON_LINT=false` switches the check off.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param path Character string. The project.
#' @param files Character vector. Paths relative to `path`.
#' @param type Character string or `NULL`. The template type.
#'
#' @return Returns `files`, invisibly, or stops.
#'
#' @family Upload Functions
#' @keywords rProject upload internal
#' @noRd
.UploadLineLength <- function(path,
                              files,
                              type) {
  off <- identical(
    x = tolower(
      x = Sys.getenv(
        x = "LINTR_ERROR_ON_LINT",
        unset = "true"
      )
    ),
    y = "false"
  )
  package <- !is.null(x = type) && type %in% c("cran", "rProject")
  where <- if (package && !off) {
    .LongLines(
      path = path,
      files = files
    )
  } else {
    character(length = 0L)
  }
  if (length(x = where) > 0L) {
    stop(
      paste0(
        "\n\n",
        length(x = where),
        " line(s) over 80 characters in the upload folder files;",
        " the public CI lint fails on them.\n",
        paste(
          utils::head(x = where, n = 20L),
          collapse = "\n"
        ),
        ifelse(
          test = length(x = where) > 20L,
          yes = "\n...",
          no = ""
        ),
        "\n\nWrap them (LINTR_ERROR_ON_LINT=false skips this check).\n\n"
      ),
      call. = FALSE
    )
  }
  invisible(x = files)
}
