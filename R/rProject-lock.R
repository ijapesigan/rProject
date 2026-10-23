#' Record What Built the Project
#'
#' Writes `.setup/scripts/rproject.lock` at `make auto`, before the project
#' is published. The lock records
#' \itemize{
#'   \item{the rProject that is running (`rproject_sha`, `rproject_version`);}
#'   \item{the image (`image`, a registry digest, and `image_name`),
#'     read from the running sif's labels;}
#'   \item{the Posit Package Manager snapshot (`snapshot`, the image's date)
#'     for packages the image lacks, and the R version (`r_version`);}
#'   \item{the packages the project adds in `project.R` (`extra_cran`,
#'     `extra_github`), with their versions or commits;}
#'   \item{for a proprietary add-on sif (`<name>-plus.sif`, built from the
#'     public image with `Bootstrap: localimage`): the sif's name, source,
#'     checksum (`sif_sha256`), and date. CI runs the public image.}
#' }
#' `make project` restores the lock, locally and in GitHub Actions;
#' `make upgrade` moves rProject forward, and the next `make auto`
#' records the running image.
#'
#' docker-* projects have no lock: their recurring image builds take the
#' newest upstream base and the newest rProject.
#'
#' Nothing is written in rProject itself (its CI builds rProject from
#' source), or when the running rProject has no commit (installed from a
#' local source).
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @return Returns the path of the lock file, invisibly, or `NULL` when
#'   nothing was written.
#' @export
Lock <- function(path) {
  out <- NULL
  type <- .TemplateType(path = path)
  if (identical(type, "rProject")) {
    message("\n\nLock(): rProject builds itself from source; no lock.\n\n")
  } else if (identical(type, "docker")) {
    # docker-* build on a schedule from the newest upstream base and the
    # newest rProject: never pinned (the user, 2026-10-23)
    message("\n\nLock(): docker projects follow the latest; no lock.\n\n")
  } else {
    description <- utils::packageDescription(pkg = "rProject")
    sif <- .SifInfo()
    sif_sha256 <- NA_character_
    addon <- identical(sif$kind, "addon") && !is.na(sif$sif)
    if (addon && file.exists(sif$sif)) {
      sif$built <- format(file.mtime(sif$sif), "%Y-%m-%d")
      sif_sha256 <- .LockSha256(file = sif$sif)
      message(
        paste0(
          "\n\nLock(): ",
          basename(sif$sif),
          " is a proprietary add-on; keep a copy in ",
          "~/work/sif/archive/",
          sub("\\.sif$", "", basename(sif$sif)),
          "-",
          sif$built,
          ".sif (never upload it).\n\n"
        )
      )
    }
    if (identical(sif$kind, "addon") && is.na(sif$digest)) {
      message(
        paste0(
          "\n\nLock(): the sif does not record its public base by digest; ",
          "CI uses ",
          sif$image,
          ":latest. Rebuild the add-on from the public sif with ",
          "Bootstrap: localimage (see inst/plus/plus.def).\n\n"
        )
      )
    }
    extra <- .LockExtra(path = path)
    out <- .LockWrite(
      path = path,
      sha = description[["RemoteSha"]],
      version = description[["Version"]],
      sif = sif,
      r_version = paste(R.version$major, R.version$minor, sep = "."),
      extra_cran = extra$cran,
      extra_github = extra$github,
      sif_sha256 = sif_sha256
    )
  }
  invisible(out)
}
