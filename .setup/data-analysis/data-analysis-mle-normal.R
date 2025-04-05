DataAnalysisMLENormal <- function() {
  rproj <- rprojroot::is_rstudio_project
  x <- read.csv(
    rproj$find_file(
      ".setup",
      "data-raw",
      "normal.csv"
    )
  )[, "x"]
  constructor <- function(x) {
    # log_pdf <- -(n / 2) * log(2 * pi * sigmasq) - sum((x - mu)^2 / (2 * sigmasq))
    n <- length(x)
    return(
      function(par) {
        return(
          -(-(n / 2) * log(2 * pi * par[2]) - sum((x - par[1])^2 / (2 * par[2])))
        )
      }
    )
  }
  neg_log_likelihood <- constructor(x = x)
  opt <- optim(
    par = c(
      mu = 0,
      sigmasq = 1
    ),
    fn = neg_log_likelihood,
    method = "L-BFGS-B",
    lower = c(-Inf, 0),
    upper = c(Inf, Inf),
  )
  utils::capture.output(
    opt,
    file = rproj$find_file(
      ".setup",
      "data-analysis",
      "data-analysis-mle-normal.txt"
    )
  )
  return(opt)
}
DataAnalysisMLENormal()
rm(DataAnalysisMLENormal)
