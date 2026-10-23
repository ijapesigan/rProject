## ---- test-rProject-tags
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- .TestProject()
    dir.create(file.path(root, ".setup", "quarto", "bib"), recursive = TRUE)
    writeLines(
      text = c(
        "@comment{jabref-meta: databaseType:biblatex;}",
        "",
        "@article{Zeta-2020,",
        "  author = {Zeta, A.},",
        "  title = {A {Title}},",
        "  keywords = {k1, k2},",
        "  annotation = {mediation}",
        "}",
        "@book{Alpha-2019,",
        "  author = {Alpha, B.},",
        "  title = {Book}",
        "}",
        "  @misc{Mid-2021,",
        "  annotation = {sem},",
        "}"
      ),
      con = file.path(root, ".setup", "quarto", "bib", "quarto.bib")
    )
    testthat::test_that(
      paste(text, "lists keys, annotations, and keywords"),
      {
        out <- Tags(path = root)
        testthat::expect_equal(
          out$key,
          c("Alpha-2019", "Mid-2021", "Zeta-2020")
        )
        testthat::expect_equal(out$annotation, c(NA, "sem", "mediation"))
        testthat::expect_equal(out$keywords, c(NA, NA, "k1, k2"))
      }
    )
    testthat::test_that(
      paste(text, "is empty without the bibliography"),
      {
        other <- .TestProject(name = "noBib")
        out <- testthat::expect_message(Tags(path = other), regexp = "no ")
        testthat::expect_equal(nrow(out), 0L)
        testthat::expect_named(out, c("key", "annotation", "keywords"))
      }
    )
    testthat::test_that(
      paste(text, ".LibSplit drops comments and strings"),
      {
        testthat::expect_length(
          .LibSplit(text = c("@string{a = {b}}", "@article{K,", "}")),
          1L
        )
        testthat::expect_length(.LibSplit(text = "no entries"), 0L)
      }
    )
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-tags"
)
