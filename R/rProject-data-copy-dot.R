.DataCopy <- function(from,
                      to,
                      compress = FALSE) {
  # stream in chunks: data files can be large
  input <- if (grepl(pattern = "\\.xz$", x = from)) {
    xzfile(description = from, open = "rb")
  } else if (grepl(pattern = "\\.gz$", x = from)) {
    gzfile(description = from, open = "rb")
  } else {
    file(description = from, open = "rb", raw = TRUE)
  }
  output <- if (compress) {
    xzfile(description = to, open = "wb", compression = 9)
  } else {
    file(description = to, open = "wb")
  }
  on.exit(
    expr = {
      close(input)
      close(output)
    },
    add = TRUE
  )
  repeat {
    chunk <- readBin(con = input, what = "raw", n = 1e7)
    if (length(chunk) == 0L) {
      break
    }
    writeBin(object = chunk, con = output)
  }
  invisible(to)
}
