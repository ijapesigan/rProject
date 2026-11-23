# Compare the roxygen of the parallel functions of the five cran-beta*
# packages (spec .setup/ai/specs/2026-11-19-beta-chain.md, goal 4).
# Read-only. Usage (in the container):
#   Rscript .setup/scripts/beta-harmony.R [work folder] [out.md]
# For each role (DeltaRSq, DiffBeta, FSq, PCor, RSq, SCor, SCorSq), each tag
# is reduced to a skeleton (the method's name and the package names replaced
# by {method} and {pkg}) and the packages whose skeleton differs from
# betaSandwich (the reference) are listed.
args <- commandArgs(trailingOnly = TRUE)
work <- if (length(x = args) > 0) {
  args[1]
} else {
  dirname(path = getwd())
}
out_file <- if (length(x = args) > 1) {
  args[2]
} else {
  ""
}
pkgs <- c(
  betaSandwich = "Sandwich",
  betaDelta = "Delta",
  betaNB = "NB",
  betaLB = "LB",
  betaMC = "MC"
)
roles <- c("DeltaRSq", "DiffBeta", "FSq", "PCor", "RSq", "SCor", "SCorSq")
Roxygen <- function(file, fun) {
  lines <- readLines(con = file, warn = FALSE)
  start <- grep(
    pattern = paste0("^", fun, " <- function"),
    x = lines
  )
  if (length(x = start) == 0) {
    NULL
  } else {
    i <- start[1] - 1
    while (i > 0 && grepl(pattern = "^#'", x = lines[i])) {
      i <- i - 1
    }
    block <- sub(
      pattern = "^#' ?",
      replacement = "",
      x = lines[seq(from = i + 1, to = start[1] - 1)]
    )
    tag <- "title"
    tags <- character(length = length(x = block))
    for (j in seq_along(along.with = block)) {
      if (grepl(pattern = "^@", x = block[j])) {
        tag <- sub(pattern = "^@(\\S+).*", replacement = "\\1", x = block[j])
        if (tag == "param") {
          tag <- paste0(
            "param:",
            sub(pattern = "^@param (\\S+).*", replacement = "\\1", x = block[j])
          )
        }
      } else if (tag == "title" && block[j] == "" && j > 1) {
        tag <- "description"
      }
      tags[j] <- tag
    }
    split(x = block, f = tags)
  }
}
Skeleton <- function(text, pkg, method) {
  text <- paste(text, collapse = " ")
  text <- gsub(pattern = pkg, replacement = "{pkg}", x = text, fixed = TRUE)
  text <- gsub(pattern = method, replacement = "{method}", x = text)
  text <- gsub(pattern = "\\s+", replacement = " ", x = text)
  trimws(x = text)
}
report <- c(
  "# Documentation harmony of the cran-beta* packages",
  "",
  paste("Reference: betaSandwich. Generated", format(x = Sys.Date())),
  ""
)
for (role in roles) {
  docs <- lapply(
    X = names(x = pkgs),
    FUN = function(pkg) {
      fun <- paste0(role, pkgs[[pkg]])
      files <- list.files(
        path = file.path(work, paste0("cran-", pkg), "R"),
        pattern = paste0("^", pkg, "-.*\\.R$"),
        full.names = TRUE
      )
      hit <- NULL
      for (f in files) {
        if (is.null(x = hit)) {
          hit <- Roxygen(file = f, fun = fun)
        }
      }
      hit
    }
  )
  names(x = docs) <- names(x = pkgs)
  report <- c(report, paste0("## ", role, "{method}"), "")
  tags <- unique(x = unlist(x = lapply(X = docs, FUN = names)))
  for (tag in tags) {
    sk <- vapply(
      X = names(x = pkgs),
      FUN = function(pkg) {
        if (is.null(x = docs[[pkg]][[tag]])) {
          "(missing)"
        } else {
          Skeleton(
            text = docs[[pkg]][[tag]],
            pkg = pkg,
            method = pkgs[[pkg]]
          )
        }
      },
      FUN.VALUE = character(length = 1)
    )
    differ <- names(x = sk)[sk != sk[["betaSandwich"]]]
    if (length(x = differ) > 0) {
      report <- c(
        report,
        paste0("- `", tag, "`: differs in ", paste(differ, collapse = ", ")),
        paste0(
          "  - betaSandwich: ",
          substr(x = sk[["betaSandwich"]], start = 1, stop = 160)
        ),
        vapply(
          X = differ,
          FUN = function(pkg) {
            paste0(
              "  - ", pkg, ": ",
              substr(x = sk[[pkg]], start = 1, stop = 160)
            )
          },
          FUN.VALUE = character(length = 1)
        )
      )
    }
  }
  report <- c(report, "")
}
if (nzchar(x = out_file)) {
  writeLines(text = report, con = out_file)
} else {
  writeLines(text = report)
}
