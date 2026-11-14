.ConformManifest <- function(path,
                             template) {
  # the manifest: a missing tier 1 file is written from the template (fix);
  # a missing tier 2 file is written by make (info); a tier 1 file that
  # differs from the template is for the user to decide
  files <- template$files
  target <- file.path(path, files$path)
  dots <- startsWith(x = basename(path = files$path), prefix = ".") &
    basename(path = files$path) == ".gitignore" &
    dirname(path = files$path) != "."
  twin <- file.path(
    path,
    dirname(path = files$path),
    sub(pattern = "^\\.", replacement = "", x = basename(path = files$path))
  )
  exists <- file.exists(target)
  has_twin <- !exists & dots & file.exists(twin)
  missing <- !exists & !has_twin
  tier_one <- files$tier == "1" & files$kind == "file"
  own <- identical(x = template$type, y = "rProject")
  compare <- exists & tier_one & !is.na(x = files$source) &
    file.exists(files$source) & !own
  differs <- rep(x = FALSE, times = nrow(x = files))
  differs[compare] <- tools::md5sum(files = target[compare]) !=
    tools::md5sum(files = files$source[compare])
  .ConformBind(
    rows = list(
      .ConformRow(
        rule = "manifest-missing",
        class = "fix",
        file = files$path[missing & tier_one],
        message = "tier 1 template file is missing (kept in Overleaf)",
        fix = "template"
      ),
      .ConformRow(
        rule = "manifest-missing",
        class = "info",
        file = files$path[missing & !tier_one],
        message = "tier 2 template file is missing (make project writes it)"
      ),
      .ConformRow(
        rule = "manifest-differs",
        class = "decide",
        file = files$path[differs],
        message = paste(
          "tier 1 file differs from the template",
          "(upload the template version; make project overwrites it)"
        )
      ),
      .ConformRow(
        rule = "dotless-twin",
        class = "info",
        file = files$path[has_twin],
        message = paste(
          "Overleaf dropped the dot (the dotless twin is accepted);",
          "create the .gitignore by hand in Overleaf"
        )
      )
    )
  )
}
