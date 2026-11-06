#' Compare the Files Linked from the Functions Repository
#'
#' The files in `.setup/r-dependencies/` are Overleaf links to the private
#' functions repository: `<lib>/<file>` there. They are changed only there.
#' `Linked()` compares each one, by content, with a local clone of functions.
#'
#' The status of a file is `same`, `differs`, `name differs`
#' (the source has only the `-dot` variant of the name), or `no source`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param functions Character string or `NULL`.
#'   The local clone of the functions repository.
#'   If `NULL`, the path in `.setup/repo/functions.md`,
#'   else `functions` next to the project.
#' @return Returns a data frame with the columns `file` and `status`,
#'   invisibly.
#' @examples
#' \dontrun{
#' Linked(path = getwd())
#' }
#' @export
Linked <- function(path,
                   functions = NULL) {
  functions <- .LinkedFunctions(path = path, functions = functions)
  if (!dir.exists(paths = functions)) {
    stop(
      paste0(
        "\n\nNo clone of the functions repository at ",
        functions,
        ". Clone it read-only over SSH on the host, or pass `functions`.\n\n"
      ),
      call. = FALSE
    )
  }
  status <- .LinkedStatus(path = path, functions = functions)
  bad <- status$status != "same"
  message(
    paste0(
      "\n\n",
      paste0(
        status$file[bad],
        ": ",
        status$status[bad],
        "\n"
      )[seq_len(length.out = sum(bad))],
      collapse = ""
    ),
    nrow(x = status),
    " linked files: ",
    sum(!bad),
    " same as functions, ",
    sum(bad),
    " not.\n\n"
  )
  invisible(x = status)
}
