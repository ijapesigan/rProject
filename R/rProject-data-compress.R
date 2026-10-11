#' Compress Data Files
#'
#' Compresses data files in place with xz
#' (e.g., `data.txt` becomes `data.txt.xz`),
#' checks that the compressed copy reads back byte for byte,
#' and then removes the original.
#' Compressed files are binary, so they do not count
#' as editable text in Overleaf (see [SizeCheck()]).
#' Scripts that find files with [DataPath()] keep working unchanged.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param files Character vector.
#'   Files to compress, relative to `path`.
#' @return Returns the paths of the compressed files, invisibly.
#' @export
DataCompress <- function(path,
                         files) {
  out <- vapply(
    X = files,
    FUN = function(file) {
      from <- file.path(path, file)
      to <- paste0(from, ".xz")
      if (!file.exists(from)) {
        stop(
          paste0("\n\n", from, " does not exist.\n\n"),
          call. = FALSE
        )
      }
      .DataCopy(
        from = from,
        to = to,
        compress = TRUE
      )
      check <- tempfile()
      .DataCopy(
        from = to,
        to = check
      )
      same <- unname(tools::md5sum(check)) == unname(tools::md5sum(from))
      unlink(check)
      if (!same) {
        unlink(to)
        stop(
          paste0(
            "\n\nThe compressed copy of ",
            from,
            " does not match. The original was kept.\n\n"
          ),
          call. = FALSE
        )
      }
      before <- file.info(from)$size
      unlink(from)
      message(
        sprintf(
          "%s: %.1f MB -> %.1f MB",
          file,
          before / 1024^2,
          file.info(to)$size / 1024^2
        )
      )
      to
    },
    FUN.VALUE = character(1)
  )
  invisible(unname(out))
}
