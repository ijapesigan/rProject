.VerifyPublic <- function(private,
                          max_size = 50 * 1024^2) {
  exported <- .PublicExport(root = private)
  # the private folders come from inst/template/folders.tsv
  folders <- .TemplateFolders()
  private_paths <- paste(
    c(
      paste0(
        "^",
        gsub(
          pattern = ".",
          replacement = "\\.",
          x = folders$folder[folders$private],
          fixed = TRUE
        )
      ),
      "(^|/)AGENTS\\.md$",
      "(^|/)CLAUDE(\\.local)?\\.md$",
      "(^|/)GEMINI\\.md$",
      "^\\.claude/",
      "^\\.codex/",
      "^\\.gemini/",
      "^\\.mcp\\.json$",
      "^\\.github/copilot-instructions\\.md$",
      "^\\.verify/",
      "secrets",
      "(^|/)\\.Renviron$"
    ),
    collapse = "|"
  )
  is_private <- grepl(pattern = private_paths, x = exported)
  size <- file.info(file.path(private, exported))$size
  is_large <- !is.na(size) & size > max_size
  c(
    paste(exported[is_private], "(private)")[seq_len(sum(is_private))],
    paste(exported[is_large], "(over 50 MB)")[seq_len(sum(is_large))]
  )
}
