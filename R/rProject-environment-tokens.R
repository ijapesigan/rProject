#' Set Tokens
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param tokens Named vector of tokens.
#' @return Returns vector of secret tokens.
#' @examples
#' \dontrun{
#' EnvironmentTokens(tokens = c(GITHUB_PAT = Sys.getenv(x = "GITHUB_PAT")))
#' }
#' @export
EnvironmentTokens <- function(tokens) {
  key <- names(x = tokens)
  value <- unname(obj = tokens)
  for (i in seq_along(along.with = key)) {
    eval(
      expr = parse(
        text = paste0(
          "Sys.setenv",
          "(",
          key[i],
          "=",
          "\"",
          value[i],
          "\"",
          ")"
        )
      )
    )
  }
  tokens
}
