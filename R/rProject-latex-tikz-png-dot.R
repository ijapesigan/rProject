.LatexTikzPng <- function(pdf_folder) {
  # F12: a PNG at 300 dpi next to each diagram, for the web, rebuilt only when
  # its PDF is newer; multi-page PDFs (animations) are left alone
  png_folder <- file.path(dirname(path = pdf_folder), "png")
  pdf_files <- list.files(
    path = pdf_folder,
    pattern = "\\.pdf$",
    full.names = TRUE
  )
  if (length(x = pdf_files) > 0L && Sys.which(names = "pdftoppm") != "") {
    dir.create(path = png_folder, showWarnings = FALSE, recursive = TRUE)
    for (pdf_file in pdf_files) {
      stem <- file.path(
        png_folder,
        sub(
          pattern = "\\.pdf$",
          replacement = "",
          x = basename(path = pdf_file)
        )
      )
      png_file <- paste0(stem, ".png")
      if (
        !file.exists(png_file) ||
          file.mtime(pdf_file) > file.mtime(png_file)
      ) {
        system2(
          command = "pdftoppm",
          args = c(
            "-r",
            "300",
            "-png",
            "-singlefile",
            .ShellQuote(x = pdf_file),
            .ShellQuote(x = stem)
          )
        )
      }
    }
  }
  invisible(x = png_folder)
}
