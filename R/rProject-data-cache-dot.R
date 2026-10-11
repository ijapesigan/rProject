.DataCache <- function(path,
                       source,
                       file) {
  cache <- file.path(path, ".setup", "data-cache", file)
  stamp <- paste0(cache, ".md5")
  md5 <- unname(tools::md5sum(source))
  fresh <- file.exists(cache) &&
    file.exists(stamp) &&
    identical(readLines(con = stamp, warn = FALSE), md5)
  if (!fresh) {
    dir.create(
      path = dirname(cache),
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
