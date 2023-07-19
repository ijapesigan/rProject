#' Set Tokens
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param tokens Named vector of tokens.
#' @return Returns vector of secret tokens.
#' @export
EnvironmentTokens <- function(tokens) {
  key <- names(tokens)
  value <- unname(tokens)
  for (i in seq_along(key)) {
    eval(
      parse(
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
  return(tokens)
}
