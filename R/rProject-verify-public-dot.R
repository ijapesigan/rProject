.VerifyPublic <- function(private,
                          max_size = 50 * 1024^2) {
  exported <- .PublicExport(root = private)
  private_paths <- paste(
    c(
      "^\\.setup/ai/",
      "^\\.setup/logs/",
      "^\\.setup/data-private/",
      "^\\.setup/data-external/",
      "^\\.setup/data-cache/",
      "^\\.setup/repo/",
      "^\\.setup/todo/",
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
