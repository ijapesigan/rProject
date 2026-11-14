.ConformCode <- function(path) {
  # file names (R/, tests, .setup/cpp) and one function per file; locked
  # copies keep the name of the library they come from and are exempt
  pkg <- .LintPkg(path = path)
  re <- gsub(pattern = ".", replacement = "\\.", x = pkg, fixed = TRUE)
  locked <- .ConformLocked(path = path)
  find <- function(folder, pattern) {
    files <- list.files(path = file.path(path, folder), pattern = pattern)
    setdiff(x = file.path(folder, files), y = locked)
  }
  names_rows <- function(files, good, rule) {
    files <- files[!(basename(path = files) %in% "RcppExports.R")]
    bad <- files[!grepl(pattern = good, x = basename(path = files))]
    foreign <- grepl(
      pattern = "^[A-Za-z][A-Za-z0-9]*-[a-z0-9-]+\\.(R|cpp)$",
      x = basename(path = bad)
    ) & !startsWith(x = basename(path = bad), prefix = paste0(pkg, "-")) &
      !startsWith(x = basename(path = bad), prefix = "test-")
    .ConformBind(
      rows = list(
        .ConformRow(
          rule = rule,
          class = "info",
          file = bad[foreign],
          message = paste(
            "named for another library (a locked copy? put it in",
            ".setup/r-dependencies/<lib>/ or .setup/cpp/<lib>/)"
          )
        ),
        .ConformRow(
          rule = rule,
          class = "decide",
          file = bad[!foreign],
          message = paste0("name it <folder>/", pkg, "-<name>")
        )
      )
    )
  }
  r_files <- find(folder = "R", pattern = "\\.[Rr]$")
  rows <- list(
    names_rows(
      files = r_files,
      good = paste0("^", re, "-[a-z0-9-]+\\.R$"),
      rule = "file-name"
    ),
    names_rows(
      files = find(folder = ".setup/cpp", pattern = "\\.cpp$"),
      good = paste0("^(000-forward-declarations|", re, "-[a-z0-9-]+)\\.cpp$"),
      rule = "cpp-file-name"
    ),
    names_rows(
      files = find(folder = "tests/testthat", pattern = "\\.[Rr]$"),
      good = paste0("^(test-", re, "-[a-z0-9-]+|helper-", re, ")\\.R$"),
      rule = "file-name"
    )
  )
  one <- r_files[
    grepl(pattern = paste0("^R/", re, "-[a-z0-9-]+\\.R$"), x = r_files) &
      !grepl(pattern = "-(package|methods)\\.R$", x = r_files)
  ]
  for (file in one) {
    found <- .ConformFunctions(file = file.path(path, file))
    n <- length(x = found$names)
    if (n > 1L) {
      rows <- c(
        rows,
        list(
          .ConformRow(
            rule = "one-function-per-file",
            class = "decide",
            file = file,
            message = paste0(
              n,
              " functions (",
              paste(utils::head(x = found$names, n = 4L), collapse = ", "),
              ifelse(test = n > 4L, yes = ", ...", no = ""),
              ")",
              ifelse(
                test = found$s3,
                yes = "; an S3 generic and its methods share the file",
                no = ""
              )
            )
          )
        )
      )
    }
  }
  .ConformBind(rows = rows)
}
