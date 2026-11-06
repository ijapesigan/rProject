.LintCppNames <- function(path) {
  level <- .LintLevel(path = path)
  snake <- "^[a-z][a-z0-9_]*$"
  .LintBind(
    rows = lapply(
      X = setdiff(
        x = .LintCppList(path = path),
        y = file.path(".setup", "cpp", "000-forward-declarations.cpp")
      ),
      FUN = function(file) {
        raw <- .LintRead(path = path, file = file)
        lines <- .LintCppStrip(lines = raw)
        found <- .LintCppFunctions(lines = raw)
        bad_fn <- found[!grepl(
          pattern = "^[A-Z][A-Za-z0-9]*$",
          x = found$name
        ), , drop = FALSE]
        arg_names <- lapply(
          X = strsplit(x = found$args, split = ",", fixed = TRUE),
          FUN = function(arg) {
            sub(
              pattern = "^.*[\\s&*]([A-Za-z_]\\w*)\\s*(=.*)?$",
              replacement = "\\1",
              x = trimws(x = arg),
              perl = TRUE
            )
          }
        )
        bad_arg <- lapply(
          X = seq_along(along.with = arg_names),
          FUN = function(i) {
            bad <- arg_names[[i]][!grepl(pattern = snake, x = arg_names[[i]])]
            .LintRow(
              file = rep(x = file, times = length(x = bad)),
              line = rep(x = found$line[i], times = length(x = bad)),
              rule = "cpp-names",
              message = paste0("argument ", bad, ": use snake_case"),
              level = level
            )
          }
        )
        variable <- paste0(
          "^\\s+(?:const\\s+)?",
          "(?:arma::\\w+|Rcpp::\\w+|std::\\w+(?:<[^>]*>)?|double|int|bool)",
          "&?\\s+([A-Za-z_]\\w*)\\s*(?:=|;|\\(|\\{)"
        )
        hit <- regexpr(pattern = variable, text = lines, perl = TRUE)
        start <- attr(x = hit, which = "capture.start")[, 1]
        size <- attr(x = hit, which = "capture.length")[, 1]
        names_found <- substring(
          text = lines,
          first = start,
          last = start + size - 1L
        )
        bad_var <- which(
          x = hit > 0L & !grepl(pattern = snake, x = names_found)
        )
        dot_file <- grepl(pattern = "-dot\\.cpp$", x = file)
        bad_export <- integer(length = 0L)
        if (dot_file) {
          bad_export <- grep(pattern = "^// \\[\\[Rcpp::export\\]\\]", x = raw)
        }
        .LintBind(
          rows = c(
            list(
              .LintRow(
                file = rep(x = file, times = nrow(x = bad_fn)),
                line = bad_fn$line,
                rule = "cpp-names",
                message = paste0(
                  "function ",
                  bad_fn$name,
                  ": use BigCamelCase"
                ),
                level = level
              ),
              .LintRow(
                file = rep(x = file, times = length(x = bad_var)),
                line = bad_var,
                rule = "cpp-names",
                message = paste0(
                  "variable ",
                  names_found[bad_var],
                  ": use snake_case"
                ),
                level = level
              ),
              .LintRow(
                file = rep(x = file, times = length(x = bad_export)),
                line = bad_export,
                rule = "cpp-names",
                message = "internal functions: // [[Rcpp::export(.Name)]]",
                level = level
              )
            ),
            bad_arg
          )
        )
      }
    )
  )
}
