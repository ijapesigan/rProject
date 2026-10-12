## ---- test-rProject-style
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed("styler")
    state <- .TestState()
    root <- .TestProject()
    writeLines("x<-c( 1,2 )", file.path(root, "R", "a.R"))
    testthat::test_that(
      paste(text, "styles R code"),
      {
        suppressMessages(Style(path = root))
        testthat::expect_equal(
          readLines(file.path(root, "R", "a.R")),
          "x <- c(1, 2)"
        )
      }
    )
    testthat::test_that(
      paste(text, "formats C++ with clang-format (Google style)"),
      {
        testthat::skip_if(Sys.which("clang-format") == "")
        dir.create(file.path(root, "src"))
        writeLines(
          "int  f( int x ){return x;}",
          file.path(root, "src", "a.cpp")
        )
        writeLines("int  keep( ){}", file.path(root, "src", "RcppExports.cpp"))
        suppressMessages(Style(path = root))
        testthat::expect_equal(
          readLines(file.path(root, "src", "a.cpp")),
          "int f(int x) { return x; }"
        )
        testthat::expect_equal(
          readLines(file.path(root, "src", "RcppExports.cpp")),
          "int  keep( ){}"
        )
      }
    )
    .TestRestore(state)
    unlink(dirname(root), recursive = TRUE)
  },
  text = "test-rProject-style"
)
