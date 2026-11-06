.AIGlobalAgents <- function(path,
                            home) {
  # the agent files (inst/ai/agents) as targets of AIGlobal(); an agent that
  # left rProject is removed, by the list of names written last time, so an
  # agent the user added is kept
  source_dir <- file.path(
    path,
    "inst",
    "ai",
    "agents"
  )
  agents_dir <- file.path(
    home,
    ".claude",
    "agents"
  )
  files <- list.files(
    path = source_dir,
    pattern = "\\.md$",
    full.names = TRUE
  )
  targets <- list()
  if (length(x = files) > 0L) {
    manifest <- file.path(agents_dir, ".rproject-agents")
    previous <- if (file.exists(manifest)) {
      readLines(
        con = manifest,
        warn = FALSE
      )
    } else {
      character(length = 0)
    }
    gone <- setdiff(
      x = previous,
      y = basename(path = files)
    )
    unlink(x = file.path(agents_dir, gone))
    targets <- c(
      lapply(
        X = files,
        FUN = function(file) {
          list(
            file = file.path(agents_dir, basename(path = file)),
            text = readLines(
              con = file,
              warn = FALSE
            )
          )
        }
      ),
      list(
        list(
          file = manifest,
          text = basename(path = files)
        )
      )
    )
  }
  targets
}
