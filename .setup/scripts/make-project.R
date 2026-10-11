#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
path <- as.character(args[1])
source(
  file.path(
    path,
    ".setup",
    "scripts",
    "project.R"
  )
)
# Secrets are read from the local machine, never from the project.
# The first file that defines `tokens` wins:
#   1. Sys.getenv("RPROJECT_SECRETS")
#   2. ~/.config/rproject/<project>.R
#   3. ~/.config/rproject/secrets.R
#   4. .setup/scripts/secrets.R (legacy; prints a warning)
secrets_legacy <- file.path(
  path,
  ".setup",
  "scripts",
  "secrets.R"
)
secrets_candidates <- c(
  Sys.getenv("RPROJECT_SECRETS"),
  file.path(
    "~",
    ".config",
    "rproject",
    paste0(project, ".R")
  ),
  file.path(
    "~",
    ".config",
    "rproject",
    "secrets.R"
  ),
  secrets_legacy
)
secrets_candidates <- secrets_candidates[
  nzchar(secrets_candidates) & file.exists(secrets_candidates)
]
tokens <- NULL
secrets_path <- NULL
for (secrets_candidate in secrets_candidates) {
  secrets_env <- new.env(parent = globalenv())
  sys.source(
    file = secrets_candidate,
    envir = secrets_env
  )
  tokens <- get0(
    x = "tokens",
    envir = secrets_env,
    inherits = FALSE
  )
  if (length(tokens) > 0) {
    secrets_path <- secrets_candidate
    break
  }
}
rm(list = ls(pattern = "^secrets_(env|candidate|candidates)$"))
if (!is.null(secrets_path)) {
  if (secrets_path == secrets_legacy) {
    warning(
      paste0(
        "\n\nSecrets were read from ",
        secrets_legacy,
        ".\nMove them to ~/.config/rproject/secrets.R (chmod 600)",
        " and remove the tokens from Overleaf.\n\n"
      ),
      call. = FALSE
    )
  } else {
    secrets_mode <- file.info(secrets_path)$mode
    if (bitwAnd(as.integer(secrets_mode), strtoi("077", base = 8L)) != 0L) {
      Sys.chmod(
        paths = secrets_path,
        mode = "600"
      )
      message(
        paste0(
          "\n\nPermissions of ",
          secrets_path,
          " changed from ",
          format(secrets_mode),
          " to 600.\n\n"
        )
      )
    }
  }
  message(
    paste0(
      "\n\nSecrets read from ",
      secrets_path,
      ": ",
      paste(names(tokens), collapse = ", "),
      "\n\n"
    )
  )
  keys <- names(tokens)
  env <- rep(x = "", times = length(keys))
  for (i in seq_along(tokens)) {
    env[i] <- paste0(
      "export",
      " ",
      keys[i],
      "=",
      tokens[i]
    )
  }
  writeLines(env, "~/.bash-secrets")
  Sys.setenv(
    GITHUB_PAT = tokens["GITHUB_PAT"]
  )
} else {
  message(
    paste0(
      "\n\n",
      "No secrets found.",
      " Put tokens in ~/.config/rproject/secrets.R",
      " (not needed in GitHub Actions).",
      "\n\n"
    )
  )
  tokens <- NULL
}
dot_library_folder <- file.path(
  path,
  ".library"
)
dir.create(
  dot_library_folder,
  showWarnings = FALSE,
  recursive = TRUE
)
dot_gitignore_file <- file.path(
  dot_library_folder,
  ".gitignore"
)
if (!file.exists(dot_gitignore_file)) {
  dot_gitignore <- c(
    "*",
    "*/"
  )
  con <- file(dot_gitignore_file)
  writeLines(
    text = dot_gitignore,
    con = con,
    sep = "\n"
  )
  close(con)
}
.libPaths(
  dot_library_folder
)
Sys.setenv(
  R_LIBS_USER = dot_library_folder
)
installed <- installed.packages()
pkg_installed <- installed[, "Package"]
if (!("pak" %in% pkg_installed)) {
  install.packages(
    "pak",
    repos = c(REPO_NAME = "https://packagemanager.rstudio.com/all/latest"),
    lib = dot_library_folder,
    quiet = TRUE
  )
}
if (project == "rProject") {
  if (!("rProject" %in% pkg_installed)) {
    pak::pkg_install(
      pkg = "ijapesigan/rProject",
      lib = dot_library_folder
    )
  }
} else {
  if (is.null(rproject_ver)) {
    pak::pkg_install(
      pkg = "ijapesigan/rProject",
      lib = dot_library_folder
    )
  } else {
    pak::pkg_install(
      pkg = paste0(
        "ijapesigan/rProject",
        "@",
        rproject_ver
      ),
      lib = dot_library_folder
    )
  }
}
rProject::Project(
  path = path
)
rProject::Profile(
  path = path,
  project = project
)
rProject::Environment(
  path = path,
  project = project,
  tokens = tokens
)
rProject::BuildIgnore(
  path = path,
  project = project,
  add = ignore
)
rProject::Binary(
  path = path
)
rProject::License(
  path = path,
  type = license
)
warnings()
