## ---- test-rProject-conform-upload-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    root <- .TestConform(name = "uploadSetPkg")
    template <- .ConformTemplate(path = root)
    testthat::test_that(
      desc = paste(text, "the upload set drops tier 2 files, keeps four"),
      code = {
        files <- c(
          ".github/.gitignore", ".setup/scripts/make-project.R",
          ".setup/scripts/project.R", ".setup/repo/.gitignore",
          ".gitignore", "latexmkrc", "Makefile", "project.Rproj",
          "R/uploadSetPkg-foo.R", ".setup/cpp/.gitignore",
          ".setup/scripts/.gitignore"
        )
        testthat::expect_equal(
          object = .UploadSet(path = root, files = files, template = template),
          expected = c(
            FALSE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE
          )
        )
      }
    )
    folder <- file.path(
      .UploadDest(path = root),
      paste0(.LogDate(), "-", basename(path = root), "-topic")
    )
    for (file in c(".github/.gitignore", "Makefile")) {
      dir.create(
        path = dirname(path = file.path(folder, file)),
        recursive = TRUE,
        showWarnings = FALSE
      )
      writeLines(text = "x", con = file.path(folder, file))
    }
    rows <- .ConformUpload(path = root, template = template)
    testthat::test_that(
      desc = paste(text, "a tier 2 file in an upload folder is a fix"),
      code = {
        testthat::expect_equal(
          object = basename(path = rows$file[rows$rule == "upload-tier2"]),
          expected = ".gitignore"
        )
        testthat::expect_equal(
          object = rows$class[rows$rule == "upload-tier2"],
          expected = "fix"
        )
      }
    )
    unlink(x = folder, recursive = TRUE)
  },
  text = "test-rProject-conform-upload-dot"
)
