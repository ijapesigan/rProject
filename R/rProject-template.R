#' Write the Template Files
#'
#' Writes the template files of the project's type from rProject
#' (`inst/template/`), so that a template change reaches a project with
#' `make` and no Overleaf refresh.
#'
#' The type comes from a line in `.setup/scripts/project.R`,
#' `type <- "cran"`; one of `"rProject"`, `"cran"`, `"man"`, `"lib"`,
#' `"talk"`, and `"docker"`. Each type uses a few sets of files
#' (`inst/template/manifest.tsv`). Each file has a tier:
#'
#' - Tier 1, links: the files Overleaf needs to compile the PDFs (the
#'   LaTeX preamble, `.setup/latex/r-scripts/`, `.setup/load/load.R`,
#'   style files, the lib documents; `latexmkrc` is linked to
#'   `inst/latexmk/latexmkrc`). They stay Overleaf links that the user
#'   refreshes.
#'   `Template()` never writes them; it lists the ones that differ
#'   from rProject as links to refresh.
#' - Tier 2, written by make: everything else (workflows, scripts, ...).
#'   A file is written when it is missing or differs; an overwritten
#'   file is named (the template wins; change it in rProject).
#'   These files are not in Overleaf or the private repository.
#'
#' Besides the files of its sets, a project gets:
#'
#' - The workflows it chooses from the catalog
#'   (`inst/template/workflows/`), named in `project.R`:
#'   for example `workflows <- c("docker-build-push-multi")`.
#'   The daily docker workflow (the one with `{{title}}`) is written as
#'   `<workflow>-<workflow_daily>.yml`, titled `workflow_title`. The daily
#'   builds run as a chain: an image with `workflow_cron` runs on that
#'   schedule; every image also starts when the image before it sends a
#'   `base-image-built` event; and an image with `workflow_next`
#'   (`"owner/repository"`) sends that event to the next image when its
#'   build succeeds (with the `PAT` secret).
#' - The folder skeleton of its type: an empty `.gitignore` in each
#'   standard folder marked `create` in `inst/template/folders.tsv`, if
#'   the folder has none.
#'
#' Files the template no longer has (`inst/template/removed.tsv`) are
#' deleted and named, so that they can be deleted in Overleaf too. A
#' folder on that list is deleted only when nothing but `.gitignore`
#' files is left in it; otherwise it is named and kept. Nothing in a
#' private folder is deleted.
#'
#' In rProject itself, the tier 1 files are copied into `inst/template/`
#' first, and the tier 2 files are written from `inst/template/` in the
#' project folder, not from the installed package.
#'
#' Nothing is written or deleted in GitHub Actions (`GITHUB_ACTIONS` is
#' `"true"`): CI uses the files already in the public repository.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param type Character string.
#'   Project type. If `NULL`, it is read from `.setup/scripts/project.R`.
#' @param check Logical.
#'   If `TRUE`, write nothing and report what would change.
#' @return Returns the paths of the tier 2 files that were written
#'   (with `check = TRUE`, that would be written), invisibly, with the
#'   deleted files (or those that would be deleted) in the attribute
#'   `removed`.
#' @export
Template <- function(path,
                     type = NULL,
                     check = FALSE) {
  written <- character(0)
  if (identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
    message("\n\nTemplate(): nothing written in GitHub Actions.\n\n")
  } else {
    if (is.null(type)) {
      type <- .TemplateType(path = path)
    }
    if (is.null(type)) {
      message(
        paste0(
          "\n\nTemplate(): no type in .setup/scripts/project.R;",
          " nothing written.\n",
          "Add a line such as type <- \"cran\".\n\n"
        )
      )
    } else {
      written <- .TemplateWrite(
        path = path,
        type = type,
        check = check
      )
    }
  }
  invisible(written)
}
