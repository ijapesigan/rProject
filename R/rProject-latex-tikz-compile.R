#' Compile Tikz
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LatexCompile
#' @export
LatexTikzCompile <- function(path,
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
  if (length(tex_files) > 0) {
    detritus <- Detritus(path = path)
    tex_folder <- detritus$tex_folder
    tex_folder <- file.path(
      tex_folder,
      "tikz"
    )
    dir.create(
      tex_folder,
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
        "!.gitignore"
      )
      con <- file(dot_gitignore_file)
      writeLines(
        text = dot_gitignore,
        con = con,
        sep = "\n"
      )
      close(con)
    }
    file.copy(
      from = tex_files,
      to = tex_folder
    )
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
    }
    unlink(
      file.path(
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
      png_folder,
      showWarnings = FALSE,
      recursive = TRUE
    )
    for (i in seq_along(pdf_files)) {
      file_name_png <- tools::file_path_sans_ext(
        basename(pdf_files[i])
      )
      file_name_png <- file.path(
        png_folder,
        file_name_png
      )
      try(
        system(
          paste(
            "pdftoppm -png -singlefile -r 300",
            pdf_files[i],
            file_name_png
          )
        )
      )
    }
  }
}
