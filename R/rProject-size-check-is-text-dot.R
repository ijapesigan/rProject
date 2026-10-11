.SizeCheckIsText <- function(file) {
  con <- file(
    description = file,
    open = "rb"
  )
  head_bytes <- readBin(
    con = con,
    what = "raw",
    n = 8000
  )
  close(con)
  length(head_bytes) > 0L && !any(head_bytes == as.raw(0))
}
