#' Find a Data File in the Data Tiers
#'
#' Finds a data file by its plain name in the data tiers, in this order:
#' `.setup/data-raw` (shareable), `.setup/data-private` (restricted;
#' never public), and `.setup/data-external` (local only).
#' The file can be stored as is or compressed (`.xz` or `.gz`);
#' [utils::read.table()] and similar functions read compressed files directly.
#'
#' With `plain = TRUE`, a compressed file is unpacked into
#' `.setup/data-cache` (local only), for tools that need plain text,
#' such as Mplus.
#' The copy is refreshed when the compressed file changes.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param file Character string.
#'   Plain file name, e.g., `"data.txt"`, even if it is stored as `data.txt.xz`.
#' @param plain Logical.
#'   If `TRUE`, return a path to an uncompressed copy.
#' @return Returns the path of the file.
#' @export
DataPath <- function(path,
                     file,
                     plain = FALSE) {
  tiers <- file.path(
    path,
    ".setup",
    c("data-raw", "data-private", "data-external")
  )
  candidates <- as.vector(
    t(
      outer(
        X = tiers,
        Y = paste0(file, c("", ".xz", ".gz")),
        FUN = file.path
      )
    )
  )
  found <- candidates[file.exists(candidates)][1]
  if (is.na(found)) {
    stop(
      paste0(
        "\n\n",
        file,
        " is not in .setup/data-raw, .setup/data-private, ",
        "or .setup/data-external",
        " (as is, .xz, or .gz).",
        "\nIf it is external, copy it to .setup/data-external",
        " (see .setup/ai/data.md for its location).\n\n"
      ),
      call. = FALSE
    )
  }
  if (plain && grepl(pattern = "\\.(xz|gz)$", x = found)) {
    found <- .DataCache(
      path = path,
      source = found,
      file = file
    )
  }
  found
}
