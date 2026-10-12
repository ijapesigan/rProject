.LogTemplate <- function(path,
                         log,
                         topic,
                         summary,
                         section) {
  date <- substr(log, start = 1, stop = 10)
  specs <- list.files(
    path = file.path(path, ".setup", "ai", "specs"),
    pattern = paste0("-", topic, "\\.md$")
  )
  spec <- ifelse(
    length(specs) > 0L,
    paste0("Spec: .setup/ai/specs/", sort(specs, decreasing = TRUE)[1]),
    "Spec: TODO"
  )
  c(
    paste0("# ", date, ": ", topic),
    "",
    spec,
    "",
    "## Commit message (paste only the block below into Overleaf's push)",
    "",
    "```",
    summary,
    "",
    "- TODO",
    "",
    paste0("Log: .setup/logs/", log),
    "```",
    "",
    "## Pushes",
    "",
    "| Commit | Date | Result |",
    "|---|---|---|",
    "| (pending) | | |",
    "",
    section,
    "## Make commands run",
    "",
    .LogImage(),
    "- TODO",
    "",
    "## Needs compute node",
    "",
    "- (none)"
  )
}
