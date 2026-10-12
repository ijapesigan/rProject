#' Check a Project Against Overleaf's Limits
#'
#' Measures what goes to Overleaf: every file in the project
#' except local-only folders
#' (`.git`, `.verify`, `.library`, `.Rproj.user`, `detritus`)
#' and build output that `make` writes and Overleaf never gets
#' (`docs`, `pkgdown`, `quarto`, `.setup/build`, `.setup/latex/pdf`,
#' `.setup/quarto/bib`),
#' the local-only data tiers (`.setup/data-external`, `.setup/data-cache`),
#' and images (`.sif`).
#'
#' - **Editable text** (fails): non-binary files in total
#'   above `editable` MB. Overleaf's GitHub sync stops above 7 MB.
#' - **Text file size** (fails): any non-binary file above `text_file` MB.
#'   Overleaf caps editable files at 2 MB.
#' - **File size** (fails): any file above `file` MB.
#'   Overleaf caps uploads at 50 MB.
#' - **Number of files** (fails): more than `files` files.
#'   Overleaf allows 2,000.
#' - **Total size** (warning): above `total` MB.
#'   Overleaf recommends under 100 MB with GitHub sync or git.
#' - **Duplicates** (warning): files of at least 1 MB with the same content.
#'
#' The report also lists the largest text files and the largest files.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param editable Numeric.
#'   Limit for all editable text, in MB.
#' @param text_file Numeric.
#'   Limit for one editable text file, in MB.
#' @param file Numeric.
#'   Limit for one file, in MB.
#' @param total Numeric.
#'   Recommended limit for the whole project, in MB.
#' @param files Integer.
#'   Limit for the number of files.
#' @param error Logical.
#'   If `TRUE`, stop with an error when a check fails.
#' @return Returns a data frame of checks
#'   with the columns `check`, `status`, and `detail`.
#' @export
SizeCheck <- function(path,
                      editable = 7,
                      text_file = 2,
                      file = 50,
                      total = 100,
                      files = 2000L,
                      error = FALSE) {
  mb <- 1024^2
  all_files <- list.files(
    path = path,
    all.files = TRUE,
    recursive = TRUE,
    no.. = TRUE
  )
  # local only, or build output that make writes and Overleaf never gets
  skip <- paste0(
    "^(",
    paste(
      c(
        "\\.git",
        "\\.verify",
        "\\.library",
        "\\.Rproj\\.user",
        "detritus",
        "docs",
        "pkgdown",
        "quarto",
        "\\.setup/build",
        "\\.setup/latex/pdf",
        "\\.setup/quarto/bib",
        "\\.setup/data-external",
        "\\.setup/data-cache",
        "\\.sif"
      ),
      collapse = "|"
    ),
    ")(/|$)"
  )
  all_files <- all_files[!grepl(pattern = skip, x = all_files)]
  size <- file.info(file.path(path, all_files))$size
  size[is.na(size)] <- 0
  is_text <- vapply(
    X = file.path(path, all_files),
    FUN = .SizeCheckIsText,
    FUN.VALUE = logical(1)
  )
  text_mb <- sum(size[is_text]) / mb
  large_text <- all_files[is_text & size > text_file * mb]
  large <- all_files[size > file * mb]
  duplicates <- .SizeCheckDuplicates(
    path = path,
    files = all_files[size >= mb]
  )
  checks <- data.frame(
    check = c(
      "Editable text",
      "Text file size",
      "File size",
      "Number of files",
      "Total size",
      "Duplicates"
    ),
    status = c(
      ifelse(text_mb > editable, "fail", "pass"),
      ifelse(length(large_text) > 0L, "fail", "pass"),
      ifelse(length(large) > 0L, "fail", "pass"),
      ifelse(length(all_files) > files, "fail", "pass"),
      ifelse(sum(size) / mb > total, "warn", "pass"),
      ifelse(length(duplicates) > 0L, "warn", "pass")
    ),
    detail = c(
      sprintf("%.1f MB (limit %s MB)", text_mb, editable),
      ifelse(
        length(large_text) > 0L,
        paste(length(large_text), "files over", text_file, "MB"),
        paste("none over", text_file, "MB")
      ),
      ifelse(
        length(large) > 0L,
        paste(paste(large, collapse = "; "), "over", file, "MB"),
        paste("none over", file, "MB")
      ),
      paste(length(all_files), "files (limit", files, ")"),
      sprintf("%.1f MB (recommended under %s MB)", sum(size) / mb, total),
      ifelse(
        length(duplicates) > 0L,
        paste(duplicates, collapse = "; "),
        "none"
      )
    ),
    stringsAsFactors = FALSE
  )
  top <- function(keep) {
    o <- order(size, decreasing = TRUE)
    o <- o[keep[o]][seq_len(min(10L, sum(keep)))]
    sprintf("  %8.2f MB  %s", size[o] / mb, all_files[o])
  }
  report <- paste0(
    "\n\nOverleaf size check of ",
    path,
    ":\n",
    paste0(
      "[",
      checks$status,
      "] ",
      checks$check,
      ": ",
      checks$detail,
      collapse = "\n"
    ),
    "\n\nLargest editable text files:\n",
    paste(top(is_text), collapse = "\n"),
    "\n\nLargest files:\n",
    paste(top(rep(TRUE, length(size))), collapse = "\n"),
    "\n\n"
  )
  if (error && any(checks$status == "fail")) {
    stop(
      report,
      call. = FALSE
    )
  } else {
    message(report)
  }
  invisible(checks)
}
