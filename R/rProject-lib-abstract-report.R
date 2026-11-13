#' Report the Articles Missing an Abstract in the lib-* Library
#'
#' For each `lib-<decade>-<type>` project in `root`, lists the `@Article`
#' entries (`.setup/latex/bib/lib-*.bib`) that have no `abstract` field.
#' Many entries have none on purpose (for example, JSTOR articles); the report
#' is information, not a check.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param root Character string.
#'   The folder with local clones of the `lib-*` projects.
#' @return Returns a data frame, invisibly, with the columns `repo` and `key`.
#' @examples
#' \dontrun{
#' LibAbstractReport(root = dirname(getwd()))
#' }
#' @export
LibAbstractReport <- function(root) {
  repos <- list.files(
    path = root,
    pattern = "^lib-[0-9]{4}-[0-9]{4}-[a-z]+$"
  )
  found <- lapply(
    X = repos,
    FUN = function(repo) {
      dir <- file.path(root, repo, ".setup", "latex", "bib")
      files <- list.files(path = dir, pattern = "^lib-.*\\.bib$")
      keys <- vapply(
        X = files,
        FUN = function(file) {
          text <- readLines(con = file.path(dir, file), warn = FALSE)
          is_article <- any(grepl(pattern = "^@Article\\{", x = text))
          has_abstract <- any(
            grepl(pattern = "^[[:space:]]*abstract[[:space:]]*=", x = text)
          )
          ifelse(
            test = is_article && !has_abstract,
            yes = sub(pattern = "\\.bib$", replacement = "", x = file),
            no = NA_character_
          )
        },
        FUN.VALUE = character(length = 1),
        USE.NAMES = FALSE
      )
      keys <- keys[!is.na(x = keys)]
      data.frame(
        repo = rep(x = repo, times = length(x = keys)),
        key = sub(
          pattern = paste0("^", repo, "-"),
          replacement = "",
          x = keys
        ),
        stringsAsFactors = FALSE
      )
    }
  )
  out <- do.call(
    what = "rbind",
    args = c(
      list(
        data.frame(
          repo = character(length = 0),
          key = character(length = 0)
        )
      ),
      found
    )
  )
  rownames(x = out) <- NULL
  message(
    paste0(
      "\n\n",
      nrow(x = out),
      " articles have no abstract in ",
      length(x = unique(x = out$repo)),
      " of ",
      length(x = repos),
      " projects.\n\n"
    )
  )
  invisible(x = out)
}
