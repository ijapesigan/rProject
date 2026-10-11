.PublicExport <- function(root) {
  files <- list.files(
    path = root,
    all.files = TRUE,
    recursive = TRUE,
    no.. = TRUE
  )
  files <- files[!grepl(pattern = "^\\.git/", x = files)]
  # what `make auto` would publish: files the .gitignore does not exclude
  ignored <- suppressWarnings(
    system2(
      command = "git",
      args = c(
        "-C",
        shQuote(root),
        "check-ignore",
        "--no-index",
        "--stdin"
      ),
      input = files,
      stdout = TRUE,
      stderr = FALSE
    )
  )
  setdiff(files, ignored)
}
