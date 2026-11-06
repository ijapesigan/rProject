.LintRFormals <- function(name,
                          pkg,
                          known) {
  # the formal names of a function, or NULL when it cannot be found;
  # S4 generics, primitives without formals, and unknown names give NULL
  if (is.na(x = pkg) && name %in% names(x = known$local)) {
    known$local[[name]]
  } else {
    fn <- tryCatch(
      expr = {
        if (!is.na(x = pkg)) {
          getExportedValue(ns = pkg, name = name)
        } else if (name %in% known$base) {
          get(x = name, envir = baseenv())
        } else if (name %in% names(x = known$pkg)) {
          getExportedValue(ns = known$pkg[[name]], name = name)
        } else {
          NULL
        }
      },
      error = function(e) {
        NULL
      }
    )
    if (is.function(x = fn)) {
      if (is.primitive(x = fn)) {
        fn <- args(name = fn)
      }
      names(x = formals(fun = fn))
    } else {
      NULL
    }
  }
}
