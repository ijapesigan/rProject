.LintTexLabels <- function(path) {
  project <- .VerifyProject(path = path)
  good <- paste0("^(eq|fig|tab|sec|app):", project, "-.+$")
  .LintBind(
    rows = lapply(
      X = .LintTexSources(path = path, preamble = FALSE),
      FUN = function(file) {
        lines <- .LintTexStrip(lines = .LintRead(path = path, file = file))
        rows <- lapply(
          X = seq_along(along.with = lines),
          FUN = function(i) {
            found <- regmatches(
              x = lines[i],
              m = gregexpr(pattern = "\\\\label\\{[^}]*\\}", text = lines[i])
            )[[1]]
            found <- gsub(
              pattern = "^\\\\label\\{|\\}$",
              replacement = "",
              x = found
            )
            bad <- found[!grepl(pattern = good, x = found)]
            .LintRow(
              file = rep(x = file, times = length(x = bad)),
              line = rep(x = i, times = length(x = bad)),
              rule = "tex-label",
              message = paste0(bad, ": use <type>:", project, "-<name>")
            )
          }
        )
        .LintBind(rows = rows)
      }
    )
  )
}
