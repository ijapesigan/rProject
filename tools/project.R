#' Define project related objects here.
#'
#' | Object Name      | Description                                         |
#' |:-----------------|:----------------------------------------------------|
#' | `project`        | Project name.                                       |
#' | `pkg_cran`       | CRAN packages to install on top of                  |
#' |                  | package dependencies in `DESCRIPTION`.              |
#' | `pkg_github`     | GitHub packages to install.                         |
#' | `pkg_github_ref` | GitHub branch corresponding to packages             |
#' |                  | in `pkg_github`. `if (length(pkg_github_ref) == 0)` |
#' |                  | use the `HEAD` branch.                              |
#' | `pkg_ver`        | Packages with specific version.                     |
#' | `ver`            | Version corresponding to packages in `pkg_ver`.     |
#' | `ignore`         | Items to add to `.Rbuildignore`.                    |
#'

project <- "rProject"

pkg_cran <- c(
  "betaDelta",
  "betaSandwich",
  "betaMC",
  "betaNB",
  "semmcci"
)

pkg_github <- c(
  "jeksterslab/betaDelta",
  "jeksterslab/betaSandwich",
  "jeksterslab/betaMC",
  "jeksterslab/betaNB",
  "jeksterslab/semmcci"
)

pkg_github_ref <- c()

pkg_ver <- c()

ver <- c()

ignore <- NULL

git_user <- "ijapesigan"
