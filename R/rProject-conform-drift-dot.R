.ConformDrift <- function(path,
                          folder,
                          template) {
  # an upload folder against its project: files that differ from the
  # project, files missing in the project, and files that are not in the
  # manifest (generated files and root dot-files that are not template
  # files); names and the manifest decide, no file is opened for content
  files <- list.files(path = folder, all.files = TRUE, recursive = TRUE)
  files <- files[!grepl(pattern = "^\\.setup/logs/", x = files)]
  files <- files[!.ConformLinked(file = files)]
  root_dot <- startsWith(x = files, prefix = ".") & !grepl(
    pattern = "/",
    x = files
  )
  generated <- files %in% c(
    "NAMESPACE", "README.md", "CITATION.cff", "LICENSE", "LICENSE.md",
    ".Rbuildignore", "project.Rproj", "AGENTS.md", "CLAUDE.md"
  ) | startsWith(x = files, prefix = "man/") |
    startsWith(x = files, prefix = ".setup/build/") |
    startsWith(x = files, prefix = ".setup/latex/pdf/") |
    startsWith(x = files, prefix = ".setup/latex/figures/")
  not_manifest <- (root_dot & !(files %in% template$files$path)) | generated
  here <- file.path(path, files)
  missing <- !file.exists(here) & !not_manifest
  differs <- file.exists(here) & !not_manifest
  mine <- tools::md5sum(files = file.path(folder, files[differs]))
  differs[differs] <- mine != tools::md5sum(files = here[differs])
  .ConformBind(
    rows = list(
      .ConformRow(
        rule = "upload-drift",
        class = "decide",
        file = files[differs],
        message = "differs from the project"
      ),
      .ConformRow(
        rule = "upload-drift",
        class = "decide",
        file = files[missing],
        message = "missing in the project"
      ),
      .ConformRow(
        rule = "upload-drift",
        class = "decide",
        file = files[not_manifest],
        message = "not in the manifest (generated; not for upload)"
      )
    )
  )
}
