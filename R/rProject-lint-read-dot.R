.LintRead <- function(path,
                      file) {
  lines <- readLines(con = file.path(path, file), warn = FALSE)
  iconv(x = lines, from = "UTF-8", to = "UTF-8", sub = "")
}
