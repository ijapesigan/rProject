.ConformRow <- function(rule,
                        class,
                        file,
                        message,
                        fix = "") {
  # one finding per file: rule, class (fix, decide, info), file, message,
  # and the fix ("template", "reference", "default", "remove-overleaf",
  # "remove-local", or "" when nothing is written)
  n <- length(x = file)
  data.frame(
    rule = rep(x = rule, length.out = n),
    class = rep(x = class, length.out = n),
    file = as.character(x = file),
    message = rep(x = message, length.out = n),
    fix = rep(x = fix, length.out = n),
    stringsAsFactors = FALSE
  )
}
