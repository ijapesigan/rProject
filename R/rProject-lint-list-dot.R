.LintList <- function(path,
                      pattern) {
  # project files, relative to path, without generated or private folders;
  # the skipped top folders are never walked (.library is large)
  skip <- c(
    ".git", ".library", ".verify", ".quarto", ".claude", ".sif", "detritus",
    "inst", "man", "pkgdown", "quarto", "renv", "packrat", "docs"
  )
  tops <- list.files(path = path, all.files = TRUE, no.. = TRUE)
  tops <- tops[!(tops %in% skip)]
  files <- unlist(
    x = lapply(
      X = tops,
      FUN = function(top) {
        full <- file.path(path, top)
        if (dir.exists(paths = full)) {
          file.path(
            top,
            list.files(path = full, all.files = TRUE, recursive = TRUE)
          )
        } else {
          top
        }
      }
    )
  )
  files <- as.character(x = files)
  files <- files[
    !grepl(
      pattern = paste0(
        "^\\.setup/(notes|todo|build|data-[a-z]+|latex/pdf|latex/figures)/"
      ),
      x = files
    )
  ]
  files[grepl(pattern = pattern, x = files)]
}
