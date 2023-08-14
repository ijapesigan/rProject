#' Compile Output of `LatexKnit`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param clean Logical.
#'   Clean `latexmk` output except `*.pdf`
#' @export
LatexCompile <- function(path,
                         clean = FALSE) {
  if (!tinytex::check_installed("latexmk")) {
    tinytex::tlmgr_install("latexmk")
  }
  latexmkrc <- system.file(
    "latexmk",
    "latexmkrc",
    package = "rProject"
  )
  file.copy(
    from = latexmkrc,
    to = path
  )
  detritus <- Detritus(path = path)
  tex_folder <- detritus$tex_folder
  pdf_folder <- file.path(
    path,
    ".setup",
    "latex",
    "pdf"
  )
  dir.create(
    pdf_folder,
    showWarnings = FALSE,
    recursive = TRUE
  )
  dot_gitignore_file <- file.path(
    pdf_folder,
    ".gitignore"
  )
  if (!file.exists(dot_gitignore_file)) {
    dot_gitignore <- c(
      "*",
      "*/",
      "!*.pdf",
      "!.gitignore",
      "!bib.bib"
    )
    con <- file(dot_gitignore_file)
    writeLines(
      text = dot_gitignore,
      con = con,
      sep = "\n"
    )
    close(con)
  }
  try(
    system(
      paste0(
        "latexmk -f -pdf -interaction=nonstopmode -output-directory=",
        pdf_folder,
        " ",
        paste0(
          tex_folder,
          "/*.tex"
        )
      )
    )
  )
  if (clean) {
    invisible(
      lapply(
        X = c(
          "\\.tex$",
          "\\.xml$",
          "\\.out$",
          "\\.log$",
          "\\.fls$",
          "\\.fdb_latexmk$",
          "\\.ent$",
          "\\.blg$",
          "\\.bcf$",
          "\\.bbl$",
          "\\.aux$"
        ),
        FUN = function(x) {
          invisible(
            lapply(
              X = list.files(
                pdf_folder,
                pattern = x,
                full.names = TRUE,
                all.files = TRUE
              ),
              FUN = unlink
            )
          )
        }
      )
    )
    unlink(
      paste0(
        tex_folder,
        "/tex-fig-*"
      ),
      recursive = TRUE
    )
  }
  unlink(
    file.path(
      path,
      "latexmkrc"
    )
  )
  bib_dot_bib <- file.path(
    path,
    ".setup",
    "latex",
    "bib",
    "bib.bib"
  )
  if (file.exists(bib_dot_bib)) {
    file.copy(
      from = latex_bib,
      to = output_dir
    )
  }
}
