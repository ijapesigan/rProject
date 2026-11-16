#' Lines over 80 Characters in R Files
#'
#' The public CI lint fails on a line over 80 characters in an `.R` file.
#' This finds them in a list of files, for the upload folder
#' and for `Verify()`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param path Character string. The folder the files are in.
#' @param files Character vector. Paths relative to `path`.
#'   Only `.R` files that exist are read.
#'
#' @return Returns a character vector of `file:line`, empty if none.
#'
#' @family Lint Functions
#' @keywords rProject lint internal
#' @noRd
.LongLines <- function(path,
                       files) {
  r_files <- files[
    grepl(
      pattern = "\\.R$",
      x = files
    ) & file.exists(file.path(path, files))
  ]
  out <- unlist(
    x = lapply(
      X = r_files,
      FUN = function(file) {
        lines <- readLines(
          con = file.path(path, file),
          warn = FALSE
        )
        long <- which(x = nchar(x = lines, type = "chars") > 80L)
        if (length(x = long) > 0L) {
          paste0(file, ":", long)
        }
      }
    )
  )
  as.character(x = out)
}
