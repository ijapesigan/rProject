.DataCache <- function(path,
                       source,
                       file) {
  cache <- file.path(path, ".setup", "data-cache", file)
  stamp <- paste0(cache, ".md5")
  md5 <- unname(obj = tools::md5sum(files = source))
  fresh <- file.exists(cache) &&
    file.exists(stamp) &&
    identical(x = readLines(con = stamp, warn = FALSE), y = md5)
  if (!fresh) {
    dir.create(
      path = dirname(path = cache),
      showWarnings = FALSE,
      recursive = TRUE
    )
    .DataCopy(
      from = source,
      to = cache
    )
    writeLines(text = md5, con = stamp)
  }
  cache
}
