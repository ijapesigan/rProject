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
        FUN.VALUE = character(length = 1)
      )
    }
    manifest <- utils::read.delim(
      file = file.path(root, "manifest.tsv"),
      colClasses = "character"
    )
    testthat::test_that(
      desc = paste(
        text,
        "every manifest row has its file and every file its row"
      ),
      code = {
        sources <- file.path(manifest$set, encode(manifest$path))
        testthat::expect_true(
          object = all(file.exists(file.path(root, sources)))
        )
        sets <- unique(x = unlist(x = .TemplateSets()))
        on_disk <- unlist(
          x = lapply(
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
        testthat::expect_setequal(object = on_disk, expected = sources)
        testthat::expect_true(object = all(manifest$set %in% sets))
      }
    )
    testthat::test_that(
      desc = paste(text, "shared files are the same in every set"),
      code = {
        same <- function(files) {
          length(
            x = unique(x = tools::md5sum(files = file.path(root, files)))
          ) == 1
        }
        testthat::expect_true(
          object = same(c("package/Makefile", "talk/Makefile"))
        )
        for (f in c("make-project.R", "make-install.R", "make-packages.R")) {
          testthat::expect_true(
            object = same(
              paste0(c("common", "docker"), "/dot-setup/scripts/", f)
            )
          )
        }
        for (f in c("make-config.R", "verify.sh")) {
          testthat::expect_true(
            object = same(
              paste0(c("package", "talk"), "/dot-setup/scripts/", f)
            )
          )
        }
      }
    )
    testthat::test_that(
      desc = paste(text, "folders.tsv names valid types"),
      code = {
        folders <- .TemplateFolders()
        types <- unlist(
          x = strsplit(x = folders$types, split = ",", fixed = TRUE)
        )
        testthat::expect_true(
          object = all(types %in% c("all", names(x = .TemplateSets())))
        )
        testthat::expect_true(
          object = all(grepl(pattern = "/$", x = folders$folder))
        )
        testthat::expect_false(object = anyNA(x = folders$private))
        testthat::expect_false(object = anyNA(x = folders$create))
        for (type in names(x = .TemplateSets())) {
          testthat::expect_true(
            object = nrow(x = .TemplateFolders(type = type)) > 0L
          )
        }
      }
    )
    testthat::test_that(
      desc = paste(text, "the folder skeleton of each type"),
      code = {
        files <- .TemplateFiles(type = "cran")
        dirs <- files$path[files$kind == "dir"]
        testthat::expect_true(object = ".setup/cpp/.gitignore" %in% dirs)
        testthat::expect_false(object = ".setup/data-raw/.gitignore" %in% dirs)
        testthat::expect_false(
          object = ".setup/bin/.gitignore" %in% .TemplateFiles(
            type = "man"
          )$path
        )
        docker <- .TemplateFiles(type = "docker")
        testthat::expect_false(object = any(docker$kind == "dir"))
      }
    )
    testthat::test_that(
      desc = paste(text, "chosen workflows and the daily file name"),
      code = {
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
          object = all(
            c(
              ".github/workflows/docker-build-push-multi.yml",
              ".github/workflows/docker-build-push-daily-multi-docs.yml"
            ) %in% files$path
          )
        )
        testthat::expect_equal(
          object = files$fill[files$set == "workflows"],
          expected = c(FALSE, TRUE)
        )
        plain <- .TemplateFiles(
          type = "docker",
          settings = list(workflows = "docker-build-push-daily-multi")
        )
        testthat::expect_true(
          object = ".github/workflows/docker-build-push-daily-multi.yml" %in%
            plain$path
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "stops on an unknown workflow"),
      code = {
        testthat::expect_error(
          object = .TemplateFiles(
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
        desc = paste(text, "workflows live only in inst/template"),
        code = {
          yml <- unlist(
            x = lapply(
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
            object = all(
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
