#' Clean Project
#'
#' Remove all files except `project.Rproj` and,
#' optionally, `.library`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param lib Logical.
#'   If `lib = TRUE`, delete `.library`.
#'   If `lib = FALSE`, `.library` is not deleted.
#' @param sim Logical.
#'   If `sim = TRUE`, delete `.sim`.
#'   If `sim = FALSE`, `.sim` is not deleted.
#' @param sif Logical.
#'   If `sif = TRUE`, delete `.sif`.
#'   If `sif = FALSE`, `.sif` is not deleted.
#' @export
CleanProj <- function(path,
                      lib = FALSE,
                      sim = FALSE,
                      sif = FALSE) {
  dirs <- list.dirs(
    path = path,
    full.names = FALSE,
    recursive = FALSE
  )
  if (!lib) {
    if (".library" %in% dirs) {
      dirs <- dirs[
        stats::complete.cases(
          gsub(
            pattern = ".library",
            replacement = NA,
            x = dirs
          )
        )
      ]
    }
  }
  if (!sim) {
    if (".sim" %in% dirs) {
      dirs <- dirs[
        stats::complete.cases(
          gsub(
            pattern = ".sim",
            replacement = NA,
            x = dirs
          )
        )
      ]
    }
  }
  if (!sif) {
    if (".sif" %in% dirs) {
      dirs <- dirs[
        stats::complete.cases(
          gsub(
            pattern = ".sif",
            replacement = NA,
            x = dirs
          )
        )
      ]
    }
  }
  dirs <- file.path(
    path,
    dirs
  )
  try(
    unlink(
      x = dirs,
      recursive = TRUE,
      force = TRUE
    )
  )
  files <- list.files(
    path = path,
    all.files = TRUE,
    recursive = FALSE,
    full.names = FALSE,
    no.. = TRUE
  )
  files <- files[
    stats::complete.cases(
      gsub(
        pattern = "project.Rproj",
        replacement = NA,
        x = files
      )
    )
  ]
  if (!lib) {
    files <- files[
      stats::complete.cases(
        gsub(
          pattern = ".library",
          replacement = NA,
          x = files
        )
      )
    ]
  }
  files <- file.path(
    path,
    files
  )
  try(
    unlink(
      x = files,
      recursive = TRUE,
      force = TRUE
    )
  )
}
