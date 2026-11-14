.ConformRecord <- function(path,
                           topic,
                           changes,
                           reference,
                           dest) {
  # the records of ConformFix(): the log of the topic (made when missing;
  # a fix-up when it was pushed) gets a "Structure audit additions"
  # section, and the upload folder gets the new files and the log (in place
  # when the log was not pushed, a `-fixup` folder when it was)
  logs <- file.path(path, ".setup", "logs")
  find <- function() {
    sort(
      x = list.files(
        path = logs,
        pattern = paste0("^[0-9]{4}-[0-9]{2}-[0-9]{2}-", topic, "\\.md$")
      ),
      decreasing = TRUE
    )
  }
  project <- .VerifyProject(path = path)
  existing <- find()
  pushed <- FALSE
  index <- FALSE
  if (length(x = existing) == 0L) {
    suppressMessages(
      expr = Log(
        path = path,
        topic = topic,
        summary = paste0("Structure audit (Conform): ", project)
      )
    )
    existing <- find()
    index <- TRUE
  } else if (.ConformPushed(path = path, log = existing[1])) {
    pushed <- TRUE
    index <- TRUE
    suppressMessages(
      expr = FixUp(
        path = path,
        topic = topic,
        summary = "Fix-up: structure audit (Conform)"
      )
    )
  }
  log <- existing[1]
  log_file <- file.path(logs, log)
  dots <- changes$new[
    startsWith(x = basename(path = changes$new), prefix = ".")
  ]
  section <- c(
    "",
    paste0("## Structure audit additions (", .LogDate(), ", Conform)"),
    "",
    paste0(
      "Added by `ConformFix()` after `Conform()` compared the project with ",
      "the template",
      ifelse(
        test = is.null(x = reference),
        yes = "",
        no = paste0(" and ", basename(path = reference))
      ),
      ":"
    ),
    if (length(x = changes$new) > 0L) {
      paste0("- new: ", changes$new)
    },
    if (length(x = changes$overleaf) > 0L) {
      paste0("- delete in Overleaf: ", changes$overleaf)
    },
    if (length(x = changes$local) > 0L) {
      paste0("- local only (removed): ", changes$local)
    },
    if (length(x = dots) > 0L) {
      paste0(
        "- create `",
        dots,
        "` by hand in Overleaf (Overleaf drops dot-files)"
      )
    }
  )
  if (is.null(x = dest)) {
    dest <- .UploadDest(path = path)
  }
  folder <- file.path(
    dest,
    paste0(
      ifelse(
        test = pushed,
        yes = .LogDate(),
        no = substr(x = log, start = 1, stop = 10)
      ),
      "-",
      project,
      "-",
      topic,
      ifelse(test = pushed, yes = "-fixup", no = "")
    )
  )
  copy <- function(files) {
    for (file in files) {
      target <- file.path(folder, file)
      dir.create(
        path = dirname(path = target),
        showWarnings = FALSE,
        recursive = TRUE
      )
      file.copy(
        from = file.path(path, file),
        to = target,
        overwrite = TRUE
      )
    }
  }
  copy(
    files = changes$new[
      !.ConformLinked(file = changes$new) &
        .UploadSet(path = path, files = changes$new)
    ]
  )
  # the log's list comes from the upload folder; linked files are refreshed
  listed <- list.files(path = folder, all.files = TRUE, recursive = TRUE)
  listed <- unique(x = c(listed, file.path(".setup", "logs", log)))
  .ConformLogFill(log_file = log_file, changes = changes, listed = listed)
  drift <- .ConformDrift(
    path = path,
    folder = folder,
    template = .ConformTemplate(path = path)
  )
  section <- c(
    section,
    "",
    "### Files to update in Overleaf (from the upload folder)",
    paste0("- ", listed[!.ConformLinked(file = listed)]),
    if (any(.ConformLinked(file = listed))) {
      paste0("- refresh the link: ", listed[.ConformLinked(file = listed)])
    },
    if (nrow(x = drift) > 0L) {
      c(
        "",
        "### Upload folder drift (not changed)",
        paste0("- ", drift$file, ": ", drift$message)
      )
    }
  )
  cat(
    paste0(paste(section, collapse = "\n"), "\n"),
    file = log_file,
    append = TRUE
  )
  copy(
    files = c(
      file.path(".setup", "logs", log),
      if (index) {
        file.path(".setup", "logs", "index.md")
      }
    )
  )
  list(log = log_file, folder = folder, pushed = pushed, drift = drift)
}
