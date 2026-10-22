## ---- test-rProject-template-files
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    root <- system.file("template", package = "rProject", mustWork = TRUE)
    encode <- function(path) {
      vapply(
        X = strsplit(x = path, split = "/", fixed = TRUE),
        FUN = function(x) {
          paste(
            sub(pattern = "^\\.", replacement = "dot-", x = x),
            collapse = "/"
          )
        },
        FUN.VALUE = character(1)
      )
    }
    manifest <- utils::read.delim(
      file = file.path(root, "manifest.tsv"),
      colClasses = "character"
    )
    testthat::test_that(
      paste(text, "every manifest row has its file and every file its row"),
      {
        sources <- file.path(manifest$set, encode(manifest$path))
        testthat::expect_true(all(file.exists(file.path(root, sources))))
        sets <- unique(unlist(.TemplateSets()))
        on_disk <- unlist(
          lapply(
            X = sets,
            FUN = function(set) {
              file.path(
                set,
                list.files(
                  path = file.path(root, set),
                  all.files = TRUE,
                  recursive = TRUE,
                  no.. = TRUE
                )
              )
            }
          )
        )
        testthat::expect_setequal(on_disk, sources)
        testthat::expect_true(all(manifest$set %in% sets))
      }
    )
    testthat::test_that(
      paste(text, "folders.tsv names valid types"),
      {
        folders <- .TemplateFolders()
        types <- unlist(
          strsplit(x = folders$types, split = ",", fixed = TRUE)
        )
        testthat::expect_true(
          all(types %in% c("all", names(.TemplateSets())))
        )
        testthat::expect_true(all(grepl(pattern = "/$", x = folders$folder)))
        testthat::expect_false(anyNA(folders$private))
        testthat::expect_false(anyNA(folders$create))
        for (type in names(.TemplateSets())) {
          testthat::expect_true(nrow(.TemplateFolders(type = type)) > 0L)
        }
      }
    )
    testthat::test_that(
      paste(text, "the folder skeleton of each type"),
      {
        files <- .TemplateFiles(type = "cran")
        dirs <- files$path[files$kind == "dir"]
        testthat::expect_true(".setup/cpp/.gitignore" %in% dirs)
        testthat::expect_false(".setup/data-raw/.gitignore" %in% dirs)
        testthat::expect_false(
          ".setup/bin/.gitignore" %in% .TemplateFiles(type = "man")$path
        )
        docker <- .TemplateFiles(type = "docker")
        testthat::expect_false(any(docker$kind == "dir"))
      }
    )
    testthat::test_that(
      paste(text, "chosen workflows and the daily file name"),
      {
        files <- .TemplateFiles(
          type = "docker",
          settings = list(
            workflows = c(
              "docker-build-push-multi",
              "docker-build-push-daily-multi"
            ),
            workflow_daily = "docs"
          )
        )
        testthat::expect_true(
          all(
            c(
              ".github/workflows/docker-build-push-multi.yml",
              ".github/workflows/docker-build-push-daily-multi-docs.yml"
            ) %in% files$path
          )
        )
        testthat::expect_equal(
          files$fill[files$set == "workflows"],
          c(FALSE, TRUE)
        )
        plain <- .TemplateFiles(
          type = "docker",
          settings = list(workflows = "docker-build-push-daily-multi")
        )
        testthat::expect_true(
          ".github/workflows/docker-build-push-daily-multi.yml" %in%
            plain$path
        )
      }
    )
    testthat::test_that(
      paste(text, "stops on an unknown workflow"),
      {
        testthat::expect_error(
          .TemplateFiles(
            type = "docker",
            settings = list(workflows = "no-such-workflow")
          ),
          regexp = "Unknown workflows"
        )
      }
    )
    # in the source tree: no workflow outside inst/template/ and the
    # written .github/workflows/
    project <- file.path("..", "..")
    if (file.exists(file.path(project, ".setup", "scripts", "project.R"))) {
      testthat::test_that(
        paste(text, "workflows live only in inst/template"),
        {
          yml <- unlist(
            lapply(
              X = c(".github", ".setup", "inst"),
              FUN = function(x) {
                file.path(
                  x,
                  list.files(
                    path = file.path(project, x),
                    pattern = "\\.ya?ml$",
                    all.files = TRUE,
                    recursive = TRUE
                  )
                )
              }
            )
          )
          workflows <- yml[grepl(pattern = "(^|/)workflows/", x = yml)]
          testthat::expect_true(
            all(
              grepl(
                pattern = "^(inst/template/|\\.github/workflows/)",
                x = workflows
              )
            )
          )
        }
      )
    }
  },
  text = "test-rProject-template-files"
)
