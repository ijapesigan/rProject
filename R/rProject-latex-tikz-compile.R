#' Compile Tikz
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' LatexTikzCompile(path = getwd())
#' }
#' @export
LatexTikzCompile <- function(path,
                             clean = FALSE) {
  if (!tinytex::check_installed(pkgs = "latexmk")) {
    tinytex::tlmgr_install(pkgs = "latexmk")
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
  tikz_folder <- file.path(
    path,
    ".setup",
    "latex",
    "tikz"
  )
  tex_files <- list.files(
    path = tikz_folder,
    pattern = "\\.tex$",
    full.names = TRUE,
    all.files = TRUE
  )
  if (length(x = tex_files) > 0) {
    detritus <- Detritus(path = path)
    tex_folder <- detritus$tex_folder
    tex_folder <- file.path(
      tex_folder,
      "tikz"
    )
    dir.create(
      path = tex_folder,
      showWarnings = FALSE,
      recursive = TRUE
    )
    pdf_folder <- file.path(
      path,
      ".setup",
      "latex",
      "figures",
      "pdf"
    )
    dir.create(
      path = pdf_folder,
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
        "!.gitignore"
      )
      con <- file(description = dot_gitignore_file)
      writeLines(
        text = dot_gitignore,
        con = con,
        sep = "\n"
      )
      close(con = con)
    }
    file.copy(
      from = tex_files,
      to = tex_folder
    )
    try(
      expr = system2(
        command = "latexmk",
        args = c(
          "-f",
          "-pdf",
          "-interaction=nonstopmode",
          paste0("-output-directory=", .ShellQuote(x = pdf_folder)),
          .ShellQuote(
            x = list.files(
              path = tex_folder,
              pattern = "\\.tex$",
              full.names = TRUE
            )
          )
        )
      )
    )
    .LatexTikzPng(pdf_folder = pdf_folder)
    if (clean) {
      invisible(
        x = lapply(
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
              x = lapply(
                X = list.files(
                  path = pdf_folder,
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
    }
    unlink(
      x = file.path(
        path,
        "latexmkrc"
      )
    )
    pdf_files <- list.files(
      path = pdf_folder,
      pattern = "\\.pdf$",
      full.names = TRUE,
      all.files = TRUE
    )
    png_folder <- file.path(
      path,
      ".setup",
      "latex",
      "figures",
      "png"
    )
    dir.create(
      path = png_folder,
      showWarnings = FALSE,
      recursive = TRUE
    )
    for (i in seq_along(along.with = pdf_files)) {
      file_name_png <- tools::file_path_sans_ext(
        x = basename(path = pdf_files[i])
      )
      file_name_png <- file.path(
        png_folder,
        file_name_png
      )
      try(
        expr = system2(
          command = "pdftoppm",
          args = c(
            "-png",
            "-singlefile",
            "-r",
            "300",
            .ShellQuote(x = c(pdf_files[i], file_name_png))
          )
        )
      )
    }
  }
}
