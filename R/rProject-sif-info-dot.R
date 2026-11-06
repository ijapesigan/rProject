.SifInfo <- function(labels = "/.singularity.d/labels.json",
                     deffile = "/.singularity.d/Singularity",
                     sif = Sys.getenv(x = "APPTAINER_CONTAINER")) {
  # the running sif, after the convention in spec 2026-10-23-release-0.0.57
  # (F): a public image `ijapesigan/<name>` (Docker Hub, GHCR) pulled into
  # `<name>.sif`, or a proprietary add-on `<name>-plus.sif` built from it
  # with `Bootstrap: localimage`, which inherits the public base labels
  lines <- character(length = 0)
  if (file.exists(labels)) {
    lines <- readLines(con = labels, warn = FALSE)
  }
  label <- function(key) {
    hit <- grep(
      pattern = paste0("\"", key, "\""),
      x = lines,
      fixed = TRUE,
      value = TRUE
    )[1]
    if (is.na(x = hit)) {
      NA_character_
    } else {
      sub(pattern = '^.*:\\s*"([^"]*)".*$', replacement = "\\1", x = hit)
    }
  }
  def <- character(length = 0)
  if (file.exists(deffile)) {
    def <- readLines(con = deffile, warn = FALSE)
  }
  header <- function(key) {
    hit <- grep(
      pattern = paste0("^\\s*", key, ":"),
      x = def,
      ignore.case = TRUE,
      value = TRUE
    )[1]
    if (is.na(x = hit)) {
      NA_character_
    } else {
      trimws(x = sub(pattern = "^[^:]*:", replacement = "", x = hit))
    }
  }
  bootstrap <- tolower(x = header("Bootstrap"))
  from <- header("From")
  base_name <- label("org.opencontainers.image.base.name")
  base_digest <- label("org.opencontainers.image.base.digest")
  source <- label("org.opencontainers.image.source")
  url <- label("org.opencontainers.image.url")
  proprietary <- label("io.github.ijapesigan.proprietary")
  repo_name <- function(x) {
    # https://github.com/ijapesigan/docker-<name>(-<addon>) -> docker-<name>...
    ifelse(
      test = is.na(x = x),
      yes = NA_character_,
      no = basename(path = sub(pattern = "/+$", replacement = "", x = x))
    )
  }
  # the public image: from the base labels when they name an ijapesigan
  # image (a pull, or a localimage build from one), else from the url label
  # (docker-<name>), else from the source label without its -<addon>
  owner <- "^(docker\\.io/|ghcr\\.io/)?ijapesigan/"
  image <- NA_character_
  registry <- "docker.io"
  digest <- NA_character_
  if (!is.na(x = base_name) && grepl(pattern = owner, x = base_name)) {
    if (grepl(pattern = "^ghcr\\.io/", x = base_name)) {
      registry <- "ghcr.io"
    }
    image <- sub(
      pattern = "^(docker\\.io/|ghcr\\.io/)",
      replacement = "",
      x = base_name
    )
    image <- sub(pattern = "[@:].*$", replacement = "", x = image)
    if (!is.na(
      x = base_digest
    ) && grepl(pattern = "^sha256:", x = base_digest)) {
      digest <- base_digest
    }
  } else if (!is.na(x = from) && grepl(pattern = owner, x = from)) {
    image <- sub(
      pattern = "[@:].*$",
      replacement = "",
      x = sub(
        pattern = "^(docker\\.io/|ghcr\\.io/)",
        replacement = "",
        x = from
      )
    )
    if (grepl(pattern = "@sha256:", x = from)) {
      digest <- sub(pattern = "^.*@", replacement = "", x = from)
    }
  } else {
    name <- repo_name(url)
    if (is.na(x = name) || !grepl(pattern = "^docker-", x = name)) {
      name <- sub(
        pattern = "-(mplus|plus)$",
        replacement = "",
        x = repo_name(source)
      )
    }
    if (!is.na(x = name) && grepl(pattern = "^docker-", x = name)) {
      image <- paste0(
        "ijapesigan/",
        sub(pattern = "^docker-", replacement = "", x = name)
      )
    }
  }
  # an add-on: the proprietary label, a localimage or docker-daemon build,
  # or a source repository named docker-<name>-<addon>
  named <- !is.na(x = source) && !is.na(x = url) &&
    repo_name(source) != repo_name(url) &&
    startsWith(x = repo_name(source), prefix = paste0(repo_name(url), "-"))
  addon <- !is.na(x = proprietary) ||
    bootstrap %in% c("localimage", "docker-daemon") ||
    named
  kind <- if (length(x = lines) == 0) {
    "none"
  } else if (is.na(x = image)) {
    "unknown"
  } else if (addon) {
    "addon"
  } else {
    "public"
  }
  created <- label("org.opencontainers.image.created")
  created <- ifelse(
    test = !is.na(
      x = created
    ) && grepl(pattern = "^\\d{4}-\\d{2}-\\d{2}", x = created),
    yes = substr(x = created, start = 1, stop = 10),
    no = NA_character_
  )
  list(
    kind = kind,
    image = ifelse(
      test = is.na(x = image),
      yes = NA_character_,
      no = paste0(registry, "/", image)
    ),
    digest = digest,
    created = created,
    source = source,
    proprietary = ifelse(
      test = is.na(x = proprietary) && kind == "addon",
      yes = "unknown",
      no = proprietary
    ),
    sif = ifelse(test = nzchar(x = sif), yes = sif, no = NA_character_)
  )
}
