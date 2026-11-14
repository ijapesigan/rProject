.UploadSet <- function(path,
                       files,
                       template = .ConformTemplate(path = path)) {
  # TRUE for the files an upload folder may hold: everything except the
  # manifest's tier 2 files (make writes them), with four tier 2 root files
  # kept for safety
  kept <- c(".gitignore", "latexmkrc", "Makefile", "project.Rproj")
  tier_two <- template$files$path[template$files$tier == "2"]
  # a nested .gitignore is made by hand in Overleaf: it may be uploaded,
  # except in the folders make writes (.github, .setup/repo, .setup/scripts)
  made <- c(".github", ".setup/repo", ".setup/scripts")
  nested <- tier_two[
    basename(path = tier_two) == ".gitignore" &
      dirname(path = tier_two) != "." &
      !dirname(path = tier_two) %in% made
  ]
  !(files %in% setdiff(x = tier_two, y = c(kept, nested)))
}
