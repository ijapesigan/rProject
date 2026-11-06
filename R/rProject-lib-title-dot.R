.LibTitle <- function(x) {
  # a sentence-case draft: first words (also after a colon) capitalized,
  # acronyms, mixed-case words, and known names in braces; the user checks
  # proper nouns
  protect <- c(
    "R", "Mplus", "OpenMx", "Stan", "JAGS", "Bayes", "Bayesian", "Gaussian",
    "Markov", "Monte", "Carlo", "Kalman", "Wald", "Fisher", "Pearson",
    "Bernoulli", "Poisson", "Laplace", "Wiener", "Ornstein", "Uhlenbeck",
    "Cholesky", "Hessian", "Jacobian", "Lagrange", "English", "American"
  )
  words <- strsplit(x = trimws(x = x), split = " ", fixed = TRUE)[[1]]
  first <- c(TRUE, grepl(pattern = "[:?.!]$", x = words[-length(x = words)]))
  out <- vapply(
    X = seq_along(along.with = words),
    FUN = function(i) {
      word <- words[i]
      bare <- gsub(pattern = "[^A-Za-z]", replacement = "", x = word)
      mixed <- grepl(pattern = "^.+[A-Z]", x = bare)
      if (grepl(pattern = "^\\{.*\\}$", x = word)) {
        word
      } else if (mixed || bare %in% protect) {
        sub(
          pattern = "^([^A-Za-z]*)(.*?)([^A-Za-z]*)$",
          replacement = "\\1{\\2}\\3",
          x = word,
          perl = TRUE
        )
      } else if (first[i]) {
        paste0(
          toupper(x = substr(x = word, start = 1, stop = 1)),
          tolower(x = substring(text = word, first = 2))
        )
      } else {
        tolower(x = word)
      }
    },
    FUN.VALUE = character(length = 1)
  )
  paste(out, collapse = " ")
}
