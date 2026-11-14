.ConformTop <- function(path,
                        template) {
  # top-level files that are not in the standard list; `main.tex` (the
  # Overleaf default) and an empty `.tmp-r/` are strays that ConformFix()
  # removes from the working copy
  first <- function(x) {
    vapply(
      X = strsplit(x = x, split = "/", fixed = TRUE),
      FUN = function(i) {
        i[1]
      },
      FUN.VALUE = character(length = 1)
    )
  }
  standard <- unique(
    x = c(
      first(x = template$files$path),
      first(x = .TemplateFolders()$folder),
      "DESCRIPTION", "NEWS.md", "LICENSE", "LICENSE.md", "Makefile",
      "NAMESPACE", "README.md", "CITATION.cff", "project.Rproj",
      ".Rbuildignore", ".gitignore", "latexmkrc", "cran-comments.md",
      "AGENTS.md", "CLAUDE.md", ".git", ".Rproj.user", ".Renviron",
      ".Rprofile", ".lintr", ".here"
    )
  )
  top <- list.files(path = path, all.files = TRUE, no.. = TRUE)
  top <- setdiff(x = top, y = standard)
  folder <- dir.exists(paths = file.path(path, top))
  empty <- vapply(
    X = file.path(path, top),
    FUN = function(i) {
      dir.exists(paths = i) && length(
        x = list.files(path = i, all.files = TRUE, no.. = TRUE)
      ) == 0L
    },
    FUN.VALUE = logical(length = 1),
    USE.NAMES = FALSE
  )
  stray_file <- top == "main.tex" & !folder
  stray_dir <- top == ".tmp-r" & empty
  other <- !stray_file & !stray_dir & !folder
  # a folder is Tree()'s to report, except an unclaimed .tmp-r
  other_dir <- top == ".tmp-r" & folder & !empty
  .ConformBind(
    rows = list(
      .ConformRow(
        rule = "stray",
        class = "fix",
        file = top[stray_file],
        message = "Overleaf default file (delete in Overleaf too)",
        fix = "remove-overleaf"
      ),
      .ConformRow(
        rule = "stray",
        class = "fix",
        file = paste0(
          top[stray_dir],
          rep(x = "/", times = sum(stray_dir))
        ),
        message = "empty scratch folder (local only)",
        fix = "remove-local"
      ),
      .ConformRow(
        rule = "top-level",
        class = "decide",
        file = c(
          top[other],
          paste0(top[other_dir], rep(x = "/", times = sum(other_dir)))
        ),
        message = "top-level path is not in the standard list"
      )
    )
  )
}
