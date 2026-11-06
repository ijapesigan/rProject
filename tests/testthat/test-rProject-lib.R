## ---- test-rProject-lib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        path = dirname(path = file.path(root, file)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      writeLines(text = text, con = file.path(root, file))
    }
    entry <- c(
      "@Article{Baron-Kenny-1986,",
      "  author = {Reuben M. Baron and David A. Kenny},",
      "  date = {1986},",
      "  journaltitle = {Journal of Personality and Social Psychology},",
      "  title = {The moderator-mediator variable distinction},",
      "  doi = {10.1037/0022-3514.51.6.1173},",
      "  number = {6},",
      "  pages = {1173--1182},",
      "  volume = {51},",
      "  abstract = {About 3\\% of {\\'e}tudes.},",
      "  publisher = {American Psychological Association ({APA})},",
      "}"
    )
    testthat::test_that(
      desc = paste(text, "parses an entry, nested braces included"),
      code = {
        x <- .LibParse(text = entry)
        testthat::expect_true(object = x$ok)
        testthat::expect_equal(object = x$n, expected = 1L)
        testthat::expect_equal(object = x$type, expected = "Article")
        testthat::expect_equal(object = x$key, expected = "Baron-Kenny-1986")
        testthat::expect_equal(
          object = unname(obj = x$fields["publisher"]),
          expected = "American Psychological Association ({APA})"
        )
        testthat::expect_equal(
          object = unname(obj = x$fields["volume"]),
          expected = "51"
        )
        bad <- .LibParse(
          text = c("@Article{Key-2020,", "  title = {a {b},", "}")
        )
        testthat::expect_false(object = bad$ok)
        two <- .LibParse(text = c(entry, entry))
        testthat::expect_equal(object = two$n, expected = 2L)
      }
    )
    testthat::test_that(
      desc = paste(text, "formats in the house layout and order"),
      code = {
        x <- .LibParse(text = entry)
        shuffled <- rev(x = x$fields)
        testthat::expect_equal(
          object = .LibFormat(type = "article", key = x$key, fields = shuffled),
          expected = entry
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "keeps Collection and types not in the list"),
      code = {
        fields <- c(
          editor = "A A and B B",
          date = "1991",
          title = "T",
          publisher = "P"
        )
        testthat::expect_equal(
          object = .LibFormat(
            type = "collection",
            key = "A-B-1991",
            fields = fields
          )[1],
          expected = "@Collection{A-B-1991,"
        )
        testthat::expect_equal(
          object = .LibFormat(
            type = "Patent",
            key = "A-B-1991",
            fields = fields
          )[1],
          expected = "@Patent{A-B-1991,"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "splits names outside braces"),
      code = {
        testthat::expect_equal(
          object = .LibNames(x = "A B and {Smith and Sons} and C D"),
          expected = c("A B", "{Smith and Sons}", "C D")
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "writes LaTeX for non-ASCII text and escapes % and &"),
      code = {
        testthat::expect_equal(
          object = .LibLatex(x = "Muth\u00e9n: 3% & 4%, 1\u20132"),
          expected = "Muth{\\'e}n: 3\\% \\& 4\\%, 1--2"
        )
        testthat::expect_equal(
          object = .LibLatex(x = "3\\%"),
          expected = "3\\%"
        )
        testthat::expect_equal(
          object = .LibLatex(x = "a%b", escape = FALSE),
          expected = "a%b"
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "builds keys: accents dropped, particles joined, etal"
      ),
      code = {
        testthat::expect_equal(
          object = .LibKey(
            families = c("Muth\u00e9n", "Le Bourdonnec"),
            year = "2020"
          ),
          expected = "Muthen-LeBourdonnec-2020"
        )
        testthat::expect_equal(
          object = .LibKey(families = c("A", "B", "C", "D"), year = "2021"),
          expected = "A-B-C-etal-2021"
        )
        testthat::expect_equal(
          object = .LibKey(families = "Kisbu-Sakarya", year = "2014"),
          expected = "KisbuSakarya-2014"
        )
      }
    )
    testthat::test_that(
      desc = paste(text, "drafts sentence-case titles with protected words"),
      code = {
        testthat::expect_equal(
          object = .LibTitle(x = "Bayesian Estimation Of SEM: A Tutorial In R"),
          expected = "{Bayesian} estimation of {SEM}: A tutorial in {R}"
        )
      }
    )
    record <- list(
      type = "journal-article",
      DOI = "10.1000/test.1",
      title = list("Using Simulation Studies"),
      `container-title` = list("Statistics in Medicine"),
      author = list(
        list(given = "Tim P.", family = "Morris"),
        list(given = "C.", family = "Gouri\u00e9roux")
      ),
      `published-print` = list(`date-parts` = list(list(2019L, 5L))),
      `published-online` = list(`date-parts` = list(list(2019L, 1L))),
      volume = "38",
      issue = "11",
      page = "2074-2102",
      ISSN = list("0277-6715", "1097-0258"),
      publisher = "Wiley",
      abstract = "<jats:p>About 3% of studies.</jats:p>"
    )
    testthat::test_that(
      desc = paste(text, "drafts an entry from a Crossref record"),
      code = {
        x <- .LibEntry(record = record)
        testthat::expect_equal(
          object = x$key,
          expected = "Morris-Gourieroux-2019"
        )
        testthat::expect_equal(
          object = x$repo,
          expected = "lib-2010-2019-article"
        )
        testthat::expect_equal(
          object = unname(obj = x$fields["date"]),
          expected = "2019-05"
        )
        testthat::expect_equal(
          object = unname(obj = x$fields["pages"]),
          expected = "2074--2102"
        )
        testthat::expect_equal(
          object = unname(obj = x$fields["author"]),
          expected = "Tim P. Morris and C. Gouri{\\'e}roux"
        )
        testthat::expect_equal(
          object = unname(obj = x$fields["abstract"]),
          expected = "About 3\\% of studies."
        )
        testthat::expect_true(
          object = any(grepl(pattern = "initials only", x = x$questions))
        )
      }
    )
    # a library of two repositories
    root <- tempfile(pattern = "lib")
    repo <- file.path(root, "lib-1980-1989-article")
    other <- file.path(root, "lib-2010-2019-article")
    for (dir in c(repo, other)) {
      write(
        root = dir,
        file = ".setup/scripts/project.R",
        text = paste0("project <- \"", basename(path = dir), "\"")
      )
    }
    bib <- function(dir, key) {
      file.path(
        ".setup/latex/bib",
        paste0(basename(path = dir), "-", key, ".bib")
      )
    }
    write(root = repo, file = bib(repo, "Baron-Kenny-1986"), text = entry)
    # five authors without etal, a year outside the decade, a raw %
    write(
      root = repo,
      file = bib(repo, "A-B-C-D-E-1995"),
      text = c(
        "@Article{A-B-C-D-E-1995,",
        "  author = {A A and B B and C C and D D and E E},",
        "  date = {1995},",
        "  journaltitle = {J},",
        "  title = {About 3% of it},",
        "}"
      )
    )
    # a misnamed file with the same DOI as another repository's entry
    write(
      root = repo,
      file = ".setup/latex/bib/wrong-name.bib",
      text = sub(
        pattern = "Baron-Kenny-1986",
        replacement = "Baron-Kenny-1986b",
        x = entry
      )
    )
    write(
      root = other,
      file = bib(other, "Other-2015"),
      text = c(
        "@Article{Other-2015,",
        "  author = {O O},",
        "  date = {2015},",
        "  journaltitle = {J},",
        "  title = {Other},",
        "  doi = {10.1037/0022-3514.51.6.1173},",
        "}"
      )
    )
    checks <- suppressMessages(expr = LibCheck(path = repo, root = root))
    found <- function(key, check) {
      any(checks$key == key & checks$check == check)
    }
    testthat::test_that(
      desc = paste(
        text,
        "LibCheck finds key, year, file, percent, duplicate errors"
      ),
      code = {
        testthat::expect_true(object = found("A-B-C-D-E-1995", "key"))
        testthat::expect_true(object = found("A-B-C-D-E-1995", "decade"))
        testthat::expect_true(object = found("A-B-C-D-E-1995", "percent"))
        testthat::expect_true(object = found("Baron-Kenny-1986b", "file name"))
        testthat::expect_true(
          object = found("Baron-Kenny-1986", "duplicate DOI")
        )
        testthat::expect_true(object = found("Baron-Kenny-1986b", "suffix"))
        testthat::expect_false(
          object = any(
            checks$key == "Baron-Kenny-1986" & checks$check == "layout"
          )
        )
        testthat::expect_error(
          object = suppressMessages(expr = LibCheck(path = repo, error = TRUE)),
          regexp = "A-B-C-D-E-1995"
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "LibFormat writes the layout, accents, pages, and DOIs"
      ),
      code = {
        messy <- c(
          "@article{Doe-1985,",
          "  title = {T},",
          "  author = {Jane Doe and Lee M{\\a'e}n},",
          "  pages = {1-25},",
          "  doi = {https://doi.org/10.1/x},",
          "  date = {1985},",
          "  journaltitle = {J}}"
        )
        write(root = repo, file = bib(repo, "Doe-1985"), text = messy)
        changed <- suppressMessages(expr = LibFormat(path = repo, write = TRUE))
        testthat::expect_true(
          object = "lib-1980-1989-article-Doe-1985.bib" %in% changed
        )
        testthat::expect_false(
          object = "lib-1980-1989-article-Baron-Kenny-1986.bib" %in% changed
        )
        testthat::expect_equal(
          object = readLines(con = file.path(repo, bib(repo, "Doe-1985"))),
          expected = c(
            "@Article{Doe-1985,",
            "  author = {Jane Doe and Lee M{\\'e}n},",
            "  date = {1985},",
            "  journaltitle = {J},",
            "  title = {T},",
            "  doi = {10.1/x},",
            "  pages = {1--25},",
            "}"
          )
        )
        raw <- readBin(
          con = file.path(repo, bib(repo, "Doe-1985")),
          what = "raw",
          n = 1000
        )
        testthat::expect_false(object = as.raw(x = 13L) %in% raw)
      }
    )
    testthat::test_that(
      desc = paste(text, "LibCheck and LibFormat accept CRLF line endings"),
      code = {
        # as writeLines() writes on Windows
        writeBin(
          object = charToRaw(
            x = paste0(paste(entry, collapse = "\r\n"), "\r\n")
          ),
          con = file.path(repo, bib(repo, "Baron-Kenny-1986"))
        )
        checks <- suppressMessages(expr = LibCheck(path = repo))
        testthat::expect_false(
          object = any(
            checks$key == "Baron-Kenny-1986" & checks$check == "layout"
          )
        )
        changed <- suppressMessages(expr = LibFormat(path = repo))
        testthat::expect_false(
          object = "lib-1980-1989-article-Baron-Kenny-1986.bib" %in% changed
        )
      }
    )
    testthat::test_that(
      desc = paste(
        text,
        "LibAdd drafts from Crossref, refuses a DOI in the library"
      ),
      code = {
        x <- testthat::with_mocked_bindings(
          code = suppressMessages(
            expr = LibAdd(doi = "10.1000/test.1", root = root)
          ),
          .LibCrossref = function(doi) {
            record
          },
          .package = "rProject"
        )
        testthat::expect_match(
          object = x$file,
          regexp = "lib-2010-2019-article-Morris-Gourieroux-2019.bib",
          fixed = TRUE
        )
        testthat::expect_false(object = file.exists(x$file))
        dup <- record
        dup$DOI <- "10.1037/0022-3514.51.6.1173"
        testthat::expect_error(
          object = testthat::with_mocked_bindings(
            code = suppressMessages(expr = LibAdd(doi = dup$DOI, root = root)),
            .LibCrossref = function(doi) {
              dup
            },
            .package = "rProject"
          ),
          regexp = "already in the library"
        )
      }
    )
    unlink(x = root, recursive = TRUE)
  },
  text = "test-rProject-lib"
)
