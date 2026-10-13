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
  words <- strsplit(x = trimws(x), split = " ", fixed = TRUE)[[1]]
  first <- c(TRUE, grepl(pattern = "[:?.!]$", x = words[-length(words)]))
  out <- vapply(
    X = seq_along(words),
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
        paste0(toupper(substr(word, 1, 1)), tolower(substring(word, 2)))
      } else {
        tolower(word)
      }
    },
    FUN.VALUE = character(1)
  )
  paste(out, collapse = " ")
}
