.LintCppConstRef <- function(path) {
  level <- .LintLevel(path = path)
  .LintBind(
    rows = lapply(
      X = .LintCppList(path = path),
      FUN = function(file) {
        found <- .LintCppFunctions(lines = .LintRead(path = path, file = file))
        rows <- lapply(
          X = seq_len(length.out = nrow(x = found)),
          FUN = function(i) {
            parts <- trimws(
              x = strsplit(x = found$args[i], split = ",", fixed = TRUE)[[1]]
            )
            parts <- parts[grepl(
              pattern = "\\b(arma|Rcpp)::",
              x = parts,
              perl = TRUE
            )]
            bad <- parts[!grepl(
              pattern = "^const\\s.*&",
              x = parts,
              perl = TRUE
            )]
            .LintRow(
              file = rep(x = file, times = length(x = bad)),
              line = rep(x = found$line[i], times = length(x = bad)),
              rule = "cpp-const-ref",
              message = paste0(
                "`",
                bad,
                "`: const reference, unless the function changes it"
              ),
              level = level
            )
          }
        )
        .LintBind(rows = rows)
      }
    )
  )
}
