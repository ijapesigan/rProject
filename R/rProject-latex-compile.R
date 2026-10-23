#' Compile Output of `LatexKnit`
#'
#' Runs `latexmk` on every `.tex` file, with 10 million extra words of
#' pdfTeX main memory (`extra_mem_bot`), so that a long bibliography
#' compiles.
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
  # the .tex files listed in R, not by a shell glob
  tex_files <- list.files(
    path = tex_folder,
    pattern = "\\.tex$",
    full.names = TRUE
  )
  if (length(tex_files) > 0) {
    try(
      system2(
        command = "latexmk",
        args = c(
          "-f",
          "-pdf",
          "-interaction=nonstopmode",
          paste0("-output-directory=", .ShellQuote(x = pdf_folder)),
          .ShellQuote(x = tex_files)
        ),
        # pdflatex's main memory (5M words) is too small for a long
        # bibliography (lib-apa with biblatex 3.22): add 10M words (~80 MB)
        env = "extra_mem_bot=10000000"
      )
    )
  }
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
      from = bib_dot_bib,
      to = pdf_folder
    )
  }
}
