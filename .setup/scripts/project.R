#' Define project related objects here.
#'
#' | Object Name        | Description                                         |
#' |:-------------------|:----------------------------------------------------|
#' | `project`          | Project name.                                       |
#' | `pkg_cran`         | CRAN packages to install on top of                  |
#' |                    | package dependencies in `DESCRIPTION`.              |
#' | `pkg_github`       | GitHub packages to install.                         |
#' | `pkg_github_ref`   | GitHub branch corresponding to packages             |
#' |                    | in `pkg_github`. `if (length(pkg_github_ref) == 0)` |
#' |                    | use the `HEAD` branch.                              |
#' | `pkg_ver`          | Packages with specific version.                     |
#' | `ver`              | Version corresponding to packages in `pkg_ver`.     |
#' | `pkg_bioconductor` | Bioconductor packages to install.                   |
#' | `ignore`           | Items to add to `.Rbuildignore`.                    |
#' | `license`          | Options are `"mit"`, `"gpl3"`, or `NULL`            |
#' | `ai`               | Optional. Project type(s) for the AI instructions   |
#' |                    | written by `rProject::AI()`, e.g.,                  |
#' |                    | `list(type = c("manuscript", "simulation"))`.       |
#' |                    | Types are detected when omitted.                    |
#' | `type`             | Template type for `rProject::Template()`: one of    |
#' |                    | `"rProject"`, `"cran"`, `"man"`, `"lib"`,           |
#' |                    | `"talk"`, `"docker"`.                               |
#' | `workflows`        | Optional. Workflows from the catalog               |
#' |                    | (`inst/template/workflows/`), e.g.,                 |
#' |                    | `c("docker-build-push-multi")`.                     |
#' | `workflow_daily`   | Docker: suffix of the daily workflow file.          |
#' | `workflow_title`   | Docker: title of the daily workflow.                |
#' | `workflow_cron`    | Docker: schedule of the first image in the chain.   |
#' | `workflow_next`    | Docker: next image in the chain (`owner/repo`).     |
#'

project <- "rProject"

type <- "rProject"


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

pkg_bioconductor <- c()

ignore <- "^vignettes$"

license <- "mit"

git_user <- "ijapesigan"
git_email <- "learn.ijapesigan@gmail.com"
r_email <- "r.ijapesigan@gmail.com"
