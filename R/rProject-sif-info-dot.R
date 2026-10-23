.SifInfo <- function(labels = "/.singularity.d/labels.json",
                     deffile = "/.singularity.d/Singularity",
                     sif = Sys.getenv("APPTAINER_CONTAINER")) {
  # the running sif, after the convention in spec 2026-10-23-release-0.0.57
  # (F): a public image `ijapesigan/<name>` (Docker Hub, GHCR) pulled into
  # `<name>.sif`, or a proprietary add-on `<name>-plus.sif` built from it
  # with `Bootstrap: localimage`, which inherits the public base labels
  lines <- character(0)
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
    if (is.na(hit)) {
      NA_character_
    } else {
      sub(pattern = '^.*:\\s*"([^"]*)".*$', replacement = "\\1", x = hit)
    }
  }
  def <- character(0)
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
    if (is.na(hit)) {
      NA_character_
    } else {
      trimws(sub(pattern = "^[^:]*:", replacement = "", x = hit))
    }
  }
  bootstrap <- tolower(header("Bootstrap"))
  from <- header("From")
  base_name <- label("org.opencontainers.image.base.name")
  base_digest <- label("org.opencontainers.image.base.digest")
  source <- label("org.opencontainers.image.source")
  url <- label("org.opencontainers.image.url")
  proprietary <- label("io.github.ijapesigan.proprietary")
  repo_name <- function(x) {
    # https://github.com/ijapesigan/docker-<name>(-<addon>) -> docker-<name>...
    ifelse(is.na(x), NA_character_, basename(sub("/+$", "", x)))
  }
  # the public image: from the base labels when they name an ijapesigan
  # image (a pull, or a localimage build from one), else from the url label
  # (docker-<name>), else from the source label without its -<addon>
  owner <- "^(docker\\.io/|ghcr\\.io/)?ijapesigan/"
  image <- NA_character_
  registry <- "docker.io"
  digest <- NA_character_
  if (!is.na(base_name) && grepl(owner, base_name)) {
    if (grepl("^ghcr\\.io/", base_name)) {
      registry <- "ghcr.io"
    }
    image <- sub("^(docker\\.io/|ghcr\\.io/)", "", base_name)
    image <- sub("[@:].*$", "", image)
    if (!is.na(base_digest) && grepl("^sha256:", base_digest)) {
      digest <- base_digest
    }
  } else if (!is.na(from) && grepl(owner, from)) {
    image <- sub("[@:].*$", "", sub("^(docker\\.io/|ghcr\\.io/)", "", from))
    if (grepl("@sha256:", from)) {
      digest <- sub("^.*@", "", from)
    }
  } else {
    name <- repo_name(url)
    if (is.na(name) || !grepl("^docker-", name)) {
      name <- sub("-(mplus|plus)$", "", repo_name(source))
    }
    if (!is.na(name) && grepl("^docker-", name)) {
      image <- paste0("ijapesigan/", sub("^docker-", "", name))
    }
  }
  # an add-on: the proprietary label, a localimage or docker-daemon build,
  # or a source repository named docker-<name>-<addon>
  named <- !is.na(source) && !is.na(url) &&
    repo_name(source) != repo_name(url) &&
    startsWith(repo_name(source), paste0(repo_name(url), "-"))
  addon <- !is.na(proprietary) ||
    bootstrap %in% c("localimage", "docker-daemon") ||
    named
  kind <- if (length(lines) == 0) {
    "none"
  } else if (is.na(image)) {
    "unknown"
  } else if (addon) {
    "addon"
  } else {
    "public"
  }
  created <- label("org.opencontainers.image.created")
  created <- ifelse(
    !is.na(created) && grepl("^\\d{4}-\\d{2}-\\d{2}", created),
    substr(created, 1, 10),
    NA_character_
  )
  list(
    kind = kind,
    image = ifelse(is.na(image), NA_character_, paste0(registry, "/", image)),
    digest = digest,
    created = created,
    source = source,
    proprietary = ifelse(
      is.na(proprietary) && kind == "addon",
      "unknown",
      proprietary
    ),
    sif = ifelse(nzchar(sif), sif, NA_character_)
  )
}
