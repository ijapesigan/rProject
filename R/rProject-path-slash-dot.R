.PathSlash <- function(x) {
  # forward slashes on every platform, for paths written into files
  # (.Rprofile, .Renviron) or compared as text; symlinks are not resolved
  gsub(
    pattern = "\\",
    replacement = "/",
    x = x,
    fixed = TRUE
  )
}
