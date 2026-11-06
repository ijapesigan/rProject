## ---- test-rProject-style
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed(pkg = "styler")
    .SkipUnlessSiteLibrary(pkgs = c("styler", "distro"))
    state <- .TestState()
    root <- .TestProject(pattern = "project with space ")
    writeLines(text = "x<-c( 1,2 )", con = file.path(root, "R", "a.R"))
    testthat::test_that(
      paste(text, "styles R code"),
      {
        suppressMessages(expr = Style(path = root))
        testthat::expect_equal(
          object = readLines(con = file.path(root, "R", "a.R")),
          expected = "x <- c(1, 2)"
        )
      }
    )
    testthat::test_that(
      paste(text, "formats C++ with clang-format (Google style)"),
      {
        testthat::skip_on_os(os = "windows")
        testthat::skip_if(condition = Sys.which(names = "clang-format") == "")
        dir.create(path = file.path(root, "src"))
        writeLines(
          text = "int  f( int x ){return x;}",
          con = file.path(root, "src", "a.cpp")
        )
        writeLines(
          text = "int  keep( ){}",
          con = file.path(root, "src", "RcppExports.cpp")
        )
        suppressMessages(expr = Style(path = root))
        testthat::expect_equal(
          object = readLines(con = file.path(root, "src", "a.cpp")),
          expected = "int f(int x) { return x; }"
        )
        testthat::expect_equal(
          object = readLines(con = file.path(root, "src", "RcppExports.cpp")),
          expected = "int  keep( ){}"
        )
      }
    )
    .TestRestore(state = state)
    unlink(x = dirname(path = root), recursive = TRUE)
  },
  text = "test-rProject-style"
)
