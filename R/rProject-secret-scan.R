#' Scan Project for Secrets
#'
#' Searches text files in the project for strings that look like tokens
#' (GitHub, Docker Hub, Quarto Pub, Overleaf, Codecov, OpenAI, Anthropic).
#' Matches are reported with the value masked.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param max_size Numeric.
#'   Files larger than `max_size` bytes are skipped.
#' @param error Logical.
#'   If `TRUE`, stop with an error when secrets are found.
#' @return Returns a data frame of findings
#'   with the columns `file`, `line`, `type`, and `match` (masked).
#' @export
SecretScan <- function(path,
                       max_size = 5e+06,
                       error = TRUE) {
  patterns <- c(
    github = "gh[pousr]_[A-Za-z0-9]{36}",
    github_fine_grained = "github_pat_[A-Za-z0-9_]{22,}",
    docker_hub = "dckr_pat_[A-Za-z0-9_-]{20,}",
    quarto_pub = "qpa_[A-Za-z0-9]{20,}",
    overleaf = "olp_[A-Za-z0-9]{20,}",
    anthropic = "sk-ant-[A-Za-z0-9_-]{20,}",
    openai = "sk-(proj-)?[A-Za-z0-9_-]{32,}",
    codecov = paste0(
      "CODECOV_TOKEN[^A-Za-z0-9]{1,8}",
      "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    )
  )
  rel <- list.files(
    path = path,
    all.files = TRUE,
    recursive = TRUE,
    no.. = TRUE
  )
  files <- file.path(path, rel)
  skip <- grepl(
    pattern = "^(\\.git|\\.library|renv|packrat)/|(^|/)\\.Renviron$",
    x = rel
  )
  files <- files[!skip]
  rel <- rel[!skip]
  info <- file.info(files)
  keep <- !is.na(info$size) & info$size > 0 & info$size <= max_size
  files <- files[keep]
  rel <- rel[keep]
  findings <- lapply(
    X = seq_along(files),
    FUN = function(i) {
      con <- file(
        description = files[i],
        open = "rb"
      )
      head_bytes <- readBin(
        con = con,
        what = "raw",
        n = 8000
      )
      close(con)
      # skip binary files
      if (!any(head_bytes == as.raw(0))) {
        lines <- suppressWarnings(
          readLines(
            con = files[i],
            warn = FALSE,
            encoding = "UTF-8"
          )
        )
        out <- lapply(
          X = names(patterns),
          FUN = function(type) {
            hit <- regexpr(
              pattern = patterns[[type]],
              text = lines,
              perl = TRUE
            )
            idx <- which(hit > 0)
            if (length(idx) > 0L) {
              match <- substr(
                x = lines[idx],
                start = hit[idx],
                stop = hit[idx] + attr(hit, "match.length")[idx] - 1
              )
              data.frame(
                file = rel[i],
                line = idx,
                type = type,
                match = paste0(
                  substr(
                    x = match,
                    start = 1,
                    stop = 4
                  ),
                  "****"
                ),
                stringsAsFactors = FALSE
              )
            }
          }
        )
        do.call(
          what = "rbind",
          args = out
        )
      }
    }
  )
  findings <- do.call(
    what = "rbind",
    args = findings
  )
  if (is.null(findings)) {
    findings <- data.frame(
      file = character(0),
      line = integer(0),
      type = character(0),
      match = character(0),
      stringsAsFactors = FALSE
    )
  }
  if (nrow(findings) > 0L) {
    report <- paste0(
      findings$file,
      ":",
      findings$line,
      " [",
      findings$type,
      "] ",
      findings$match,
      collapse = "\n"
    )
    msg <- paste0(
      "\n\nPossible secrets found in ",
      path,
      ":\n",
      report,
      "\n\nRemove them and rotate the tokens.\n\n"
    )
    if (error) {
      stop(
        msg,
        call. = FALSE
      )
    } else {
      warning(
        msg,
        call. = FALSE
      )
    }
  } else {
    message(
      paste0(
        "\n\nNo secrets found in ",
        path,
        ".\n\n"
      )
    )
  }
  invisible(findings)
}
