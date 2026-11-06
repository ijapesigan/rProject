.LintRCode <- function(path) {
  # all R code: .R files, and the chunks of .Rtex, .Rmd, and .qmd files
  files <- .LintList(
    path = path,
    pattern = "\\.(R|r|Rtex|Rmd|qmd)$|\\.Rmd\\.orig$"
  )
  # tests/testthat.R is R CMD check's own file: it must attach the package
  files <- setdiff(
    x = files,
    y = c(file.path("R", "RcppExports.R"), file.path("tests", "testthat.R"))
  )
  # vignettes built from .setup/vignettes are generated
  built <- file.path(
    "vignettes",
    sub(
      pattern = "\\.orig$",
      replacement = "",
      x = basename(
        path = files[grepl(pattern = "^\\.setup/vignettes/", x = files)]
      )
    )
  )
  files <- files[!(files %in% built)]
  lapply(
    X = files,
    FUN = function(file) {
      lines <- .LintRChunks(
        file = file,
        lines = .LintRead(path = path, file = file)
      )
      list(file = file, lines = lines, data = .LintRParse(lines = lines))
    }
  )
}
