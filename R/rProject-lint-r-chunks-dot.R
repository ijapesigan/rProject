.LintRChunks <- function(file,
                         lines) {
  # the R code of a file; other lines are blank, so line numbers hold
  if (grepl(pattern = "\\.[Rr]$", x = file)) {
    lines
  } else {
    rtex <- grepl(pattern = "\\.Rtex$", x = file)
    open <- ifelse(test = rtex, yes = "^%% begin\\.rcode", no = "^```\\{r")
    close <- ifelse(test = rtex, yes = "^%% end\\.rcode", no = "^```\\s*$")
    inside <- FALSE
    out <- rep(x = "", times = length(x = lines))
    for (i in seq_along(along.with = lines)) {
      if (!inside && grepl(pattern = open, x = lines[i])) {
        inside <- TRUE
      } else if (inside && grepl(pattern = close, x = lines[i])) {
        inside <- FALSE
      } else if (inside) {
        out[i] <- lines[i]
        if (rtex) {
          out[i] <- sub(pattern = "^% ?", replacement = "", x = out[i])
        }
        if (grepl(pattern = "^#\\|", x = out[i])) {
          out[i] <- ""
        }
      }
    }
    out
  }
}
