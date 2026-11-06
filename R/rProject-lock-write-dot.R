.LockWrite <- function(path,
                       sha,
                       version,
                       sif = list(kind = "none"),
                       r_version = NA_character_,
                       extra_cran = character(length = 0),
                       extra_github = character(length = 0),
                       sif_sha256 = NA_character_) {
  out <- NULL
  if (is.null(x = sha) || is.na(x = sha) || !nzchar(x = sha)) {
    message("\n\nLock(): this rProject has no commit; no lock written.\n\n")
  } else {
    quote <- function(x) {
      ifelse(test = is.na(x = x), yes = "NA", no = paste0("\"", x, "\""))
    }
    named <- function(name, x) {
      if (length(x = x) == 0) {
        paste0(name, " <- c()")
      } else {
        paste0(
          name,
          " <- c(",
          paste0("\"", names(x = x), "\" = ", quote(x = x), collapse = ", "),
          ")"
        )
      }
    }
    image <- NA_character_
    if (!is.null(x = sif$image) && !is.na(x = sif$image)) {
      image <- ifelse(
        test = is.na(x = sif$digest),
        yes = sif$image,
        no = paste0(sif$image, "@", sif$digest)
      )
    }
    text <- c(
      "# Written by rProject::Lock() at make auto. Do not edit.",
      "# make project restores it (locally and in GitHub Actions);",
      "# make upgrade moves it forward at the next make auto.",
      paste0("rproject_sha <- ", quote(x = sha)),
      paste0("rproject_version <- ", quote(x = version)),
      "# the image: CI runs `image` (a digest), or `image_name`:latest",
      "# when it has no digest; packages the image lacks come from the",
      "# Posit Package Manager snapshot of `snapshot`",
      paste0("image <- ", quote(x = image)),
      paste0(
        "image_name <- ",
        quote(
          x = ifelse(
            test = is.null(x = sif$image),
            yes = NA_character_,
            no = sif$image
          )
        )
      ),
      paste0(
        "snapshot <- ",
        quote(
          x = ifelse(
            test = is.null(x = sif$created),
            yes = NA_character_,
            no = .SnapshotDate(created = sif$created)
          )
        )
      ),
      paste0("r_version <- ", quote(x = r_version)),
      "# packages the project adds (project.R): version or commit",
      named("extra_cran", extra_cran),
      named("extra_github", extra_github)
    )
    if (identical(x = sif$kind, y = "addon")) {
      text <- c(
        text,
        "# built in a proprietary add-on sif: CI runs the public image",
        paste0("image_local <- ", quote(x = basename(path = sif$sif))),
        paste0("image_local_source <- ", quote(x = sif$source)),
        paste0("image_local_proprietary <- ", quote(x = sif$proprietary)),
        paste0("sif_sha256 <- ", quote(x = sif_sha256)),
        paste0(
          "sif_built <- ",
          quote(
            x = ifelse(
              test = is.null(x = sif$built),
              yes = NA_character_,
              no = sif$built
            )
          )
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
        substr(x = sha, start = 1, stop = 7),
        "), image ",
        ifelse(test = is.na(x = image), yes = "none", no = image),
        " in .setup/scripts/rproject.lock\n\n"
      )
    )
  }
  out
}
