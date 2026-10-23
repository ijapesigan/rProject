.LockWrite <- function(path,
                       sha,
                       version,
                       sif = list(kind = "none"),
                       r_version = NA_character_,
                       extra_cran = character(0),
                       extra_github = character(0),
                       sif_sha256 = NA_character_) {
  out <- NULL
  if (is.null(sha) || is.na(sha) || !nzchar(sha)) {
    message("\n\nLock(): this rProject has no commit; no lock written.\n\n")
  } else {
    quote <- function(x) {
      ifelse(is.na(x), "NA", paste0("\"", x, "\""))
    }
    named <- function(name, x) {
      if (length(x) == 0) {
        paste0(name, " <- c()")
      } else {
        paste0(
          name,
          " <- c(",
          paste0("\"", names(x), "\" = ", quote(x), collapse = ", "),
          ")"
        )
      }
    }
    image <- NA_character_
    if (!is.null(sif$image) && !is.na(sif$image)) {
      image <- ifelse(
        is.na(sif$digest),
        sif$image,
        paste0(sif$image, "@", sif$digest)
      )
    }
    text <- c(
      "# Written by rProject::Lock() at make auto. Do not edit.",
      "# make project restores it (locally and in GitHub Actions);",
      "# make upgrade moves it forward at the next make auto.",
      paste0("rproject_sha <- ", quote(sha)),
      paste0("rproject_version <- ", quote(version)),
      "# the image: CI runs `image` (a digest), or `image_name`:latest",
      "# when it has no digest; packages the image lacks come from the",
      "# Posit Package Manager snapshot of `snapshot`",
      paste0("image <- ", quote(image)),
      paste0(
        "image_name <- ",
        quote(ifelse(is.null(sif$image), NA_character_, sif$image))
      ),
      paste0(
        "snapshot <- ",
        quote(ifelse(is.null(sif$created), NA_character_, sif$created))
      ),
      paste0("r_version <- ", quote(r_version)),
      "# packages the project adds (project.R): version or commit",
      named("extra_cran", extra_cran),
      named("extra_github", extra_github)
    )
    if (identical(sif$kind, "addon")) {
      text <- c(
        text,
        "# built in a proprietary add-on sif: CI runs the public image",
        paste0("image_local <- ", quote(basename(sif$sif))),
        paste0("image_local_source <- ", quote(sif$source)),
        paste0("image_local_proprietary <- ", quote(sif$proprietary)),
        paste0("sif_sha256 <- ", quote(sif_sha256)),
        paste0(
          "sif_built <- ",
          quote(ifelse(is.null(sif$built), NA_character_, sif$built))
        )
      )
    }
    out <- file.path(path, ".setup", "scripts", "rproject.lock")
    writeLines(
      text = text,
      con = out
    )
    message(
      paste0(
        "\n\nLock(): rProject ",
        version,
        " (",
        substr(sha, 1, 7),
        "), image ",
        ifelse(is.na(image), "none", image),
        " in .setup/scripts/rproject.lock\n\n"
      )
    )
  }
  out
}
