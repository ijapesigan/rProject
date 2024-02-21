DataAnalysisMLEExponential <- function() {
  rproj <- rprojroot::is_rstudio_project
  x <- read.csv(
    rproj$find_file(
      ".setup",
      "data-raw",
      "exponential.csv"
    )
  )[, "x"]
  constructor <- function(x) {
    # log_pdf <- -n * log(lambda) - sum(x / lambda)
    n <- length(x)
    return(
      function(par) {
        return(
          -(-n * log(par) - sum(x / par))
        )
      }
    )
  }
  neg_log_likelihood <- constructor(x = x)
  opt <- optim(
    par = c(
      lambda = 1
    ),
    fn = neg_log_likelihood,
    method = "L-BFGS-B"
  )
  utils::capture.output(
    opt,
    file = rproj$find_file(
      ".setup",
      "data-analysis",
      "data-analysis-mle-exponential.txt"
    )
  )
  return(opt)
}
DataAnalysisMLEExponential()
rm(DataAnalysisMLEExponential)
