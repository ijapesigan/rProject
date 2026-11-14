.ConformLocked <- function(path) {
  # locked copies: files that make copies from .setup/r-dependencies/<lib>/
  # into R/, and from .setup/cpp/<lib>/ into src/; they keep the name that
  # the other library gave them
  deps <- list.files(
    path = file.path(path, ".setup", "r-dependencies"),
    recursive = TRUE,
    pattern = "\\.[Rr]$"
  )
  cpp <- list.files(
    path = file.path(path, ".setup", "cpp"),
    recursive = TRUE,
    pattern = "\\.cpp$"
  )
  c(
    file.path("R", basename(path = deps)),
    file.path("src", basename(path = cpp)),
    file.path(".setup", "cpp", cpp[grepl(pattern = "/", x = cpp)])
  )
}
