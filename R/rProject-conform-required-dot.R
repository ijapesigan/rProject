.ConformRequired <- function(path,
                             template,
                             reference) {
  # files that every package has but the manifest does not keep:
  # written from the reference, else from a default (fix)
  required <- c(
    "vignettes/.gitignore",
    "inst/CITATION",
    "tests/testthat.R",
    ".setup/pkgdown/_pkgdown.yml"
  )
  if (template$type %in% c("cran", "rProject")) {
    exists <- file.exists(file.path(path, required))
    twin <- file.exists(file.path(path, "vignettes", "gitignore")) &
      required == "vignettes/.gitignore"
    missing <- !exists & !twin
    from_reference <- !is.null(x = reference) &
      file.exists(file.path(c(reference, "")[1], required))
    .ConformBind(
      rows = list(
        .ConformRow(
          rule = "required-file",
          class = "fix",
          file = required[missing],
          message = "every package has this file (not a manifest row)",
          fix = ifelse(
            test = from_reference[missing],
            yes = "reference",
            no = "default"
          )
        ),
        .ConformRow(
          rule = "dotless-twin",
          class = "info",
          file = required[twin],
          message = paste(
            "Overleaf dropped the dot (the dotless twin is accepted);",
            "create the .gitignore by hand in Overleaf"
          )
        )
      )
    )
  } else {
    .ConformEmpty()
  }
}
