## ---- test-rProject-lib
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    write <- function(root, file, text) {
      dir.create(
        dirname(file.path(root, file)),
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
      paste(text, "parses an entry, nested braces included"),
      {
        x <- .LibParse(text = entry)
        testthat::expect_true(x$ok)
        testthat::expect_equal(x$n, 1L)
        testthat::expect_equal(x$type, "Article")
        testthat::expect_equal(x$key, "Baron-Kenny-1986")
        testthat::expect_equal(
          unname(x$fields["publisher"]),
          "American Psychological Association ({APA})"
        )
        testthat::expect_equal(unname(x$fields["volume"]), "51")
        bad <- .LibParse(
          text = c("@Article{Key-2020,", "  title = {a {b},", "}")
        )
        testthat::expect_false(bad$ok)
        two <- .LibParse(text = c(entry, entry))
        testthat::expect_equal(two$n, 2L)
      }
    )
    testthat::test_that(
      paste(text, "formats in the house layout and order"),
      {
        x <- .LibParse(text = entry)
        shuffled <- rev(x$fields)
        testthat::expect_equal(
          .LibFormat(type = "article", key = x$key, fields = shuffled),
          entry
        )
      }
    )
    testthat::test_that(
      paste(text, "splits names outside braces"),
      {
        testthat::expect_equal(
          .LibNames(x = "A B and {Smith and Sons} and C D"),
          c("A B", "{Smith and Sons}", "C D")
        )
      }
    )
    testthat::test_that(
      paste(text, "writes LaTeX for non-ASCII text and escapes % and &"),
      {
        testthat::expect_equal(
          .LibLatex(x = "Muth\u00e9n: 3% & 4%, 1\u20132"),
          "Muth{\\'e}n: 3\\% \\& 4\\%, 1--2"
        )
        testthat::expect_equal(.LibLatex(x = "3\\%"), "3\\%")
        testthat::expect_equal(.LibLatex(x = "a%b", escape = FALSE), "a%b")
      }
    )
    testthat::test_that(
      paste(text, "builds keys: accents dropped, particles joined, etal"),
      {
        testthat::expect_equal(
          .LibKey(families = c("Muth\u00e9n", "Le Bourdonnec"), year = "2020"),
          "Muthen-LeBourdonnec-2020"
        )
        testthat::expect_equal(
          .LibKey(families = c("A", "B", "C", "D"), year = "2021"),
          "A-B-C-etal-2021"
        )
        testthat::expect_equal(
          .LibKey(families = "Kisbu-Sakarya", year = "2014"),
          "KisbuSakarya-2014"
        )
      }
    )
    testthat::test_that(
      paste(text, "drafts sentence-case titles with protected words"),
      {
        testthat::expect_equal(
          .LibTitle(x = "Bayesian Estimation Of SEM: A Tutorial In R"),
          "{Bayesian} estimation of {SEM}: A tutorial in {R}"
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
      paste(text, "drafts an entry from a Crossref record"),
      {
        x <- .LibEntry(record = record)
        testthat::expect_equal(x$key, "Morris-Gourieroux-2019")
        testthat::expect_equal(x$repo, "lib-2010-2019-article")
        testthat::expect_equal(unname(x$fields["date"]), "2019-05")
        testthat::expect_equal(unname(x$fields["pages"]), "2074--2102")
        testthat::expect_equal(
          unname(x$fields["author"]),
          "Tim P. Morris and C. Gouri{\\'e}roux"
        )
        testthat::expect_equal(
          unname(x$fields["abstract"]),
          "About 3\\% of studies."
        )
        testthat::expect_true(any(grepl("initials only", x$questions)))
      }
    )
    # a library of two repositories
    root <- tempfile(pattern = "lib")
    repo <- file.path(root, "lib-1980-1989-article")
    other <- file.path(root, "lib-2010-2019-article")
    for (dir in c(repo, other)) {
      write(
        dir,
        ".setup/scripts/project.R",
        paste0("project <- \"", basename(dir), "\"")
      )
    }
    bib <- function(dir, key) {
      file.path(".setup/latex/bib", paste0(basename(dir), "-", key, ".bib"))
    }
    write(repo, bib(repo, "Baron-Kenny-1986"), entry)
    # five authors without etal, a year outside the decade, a raw %
    write(
      repo,
      bib(repo, "A-B-C-D-E-1995"),
      c(
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
      repo,
      ".setup/latex/bib/wrong-name.bib",
      sub("Baron-Kenny-1986", "Baron-Kenny-1986b", entry)
    )
    write(
      other,
      bib(other, "Other-2015"),
      c(
        "@Article{Other-2015,",
        "  author = {O O},",
        "  date = {2015},",
        "  journaltitle = {J},",
        "  title = {Other},",
        "  doi = {10.1037/0022-3514.51.6.1173},",
        "}"
      )
    )
    checks <- suppressMessages(LibCheck(path = repo, root = root))
    found <- function(key, check) {
      any(checks$key == key & checks$check == check)
    }
    testthat::test_that(
      paste(text, "LibCheck finds key, year, file, percent, duplicate errors"),
      {
        testthat::expect_true(found("A-B-C-D-E-1995", "key"))
        testthat::expect_true(found("A-B-C-D-E-1995", "decade"))
        testthat::expect_true(found("A-B-C-D-E-1995", "percent"))
        testthat::expect_true(found("Baron-Kenny-1986b", "file name"))
        testthat::expect_true(found("Baron-Kenny-1986", "duplicate DOI"))
        testthat::expect_true(found("Baron-Kenny-1986b", "suffix"))
        testthat::expect_false(
          any(checks$key == "Baron-Kenny-1986" & checks$check == "layout")
        )
        testthat::expect_error(
          suppressMessages(LibCheck(path = repo, error = TRUE)),
          "A-B-C-D-E-1995"
        )
      }
    )
    testthat::test_that(
      paste(text, "LibFormat writes the layout, accents, pages, and DOIs"),
      {
        messy <- c(
          "@article{Doe-1985,",
          "  title = {T},",
          "  author = {Jane Doe and Lee M{\\a'e}n},",
          "  pages = {1-25},",
          "  doi = {https://doi.org/10.1/x},",
          "  date = {1985},",
          "  journaltitle = {J}}"
        )
        write(repo, bib(repo, "Doe-1985"), messy)
        changed <- suppressMessages(LibFormat(path = repo, write = TRUE))
        testthat::expect_true("lib-1980-1989-article-Doe-1985.bib" %in% changed)
        testthat::expect_false(
          "lib-1980-1989-article-Baron-Kenny-1986.bib" %in% changed
        )
        testthat::expect_equal(
          readLines(file.path(repo, bib(repo, "Doe-1985"))),
          c(
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
        testthat::expect_false(as.raw(13L) %in% raw)
      }
    )
    testthat::test_that(
      paste(text, "LibCheck and LibFormat accept CRLF line endings"),
      {
        # as writeLines() writes on Windows
        writeBin(
          object = charToRaw(paste0(paste(entry, collapse = "\r\n"), "\r\n")),
          con = file.path(repo, bib(repo, "Baron-Kenny-1986"))
        )
        checks <- suppressMessages(LibCheck(path = repo))
        testthat::expect_false(
          any(checks$key == "Baron-Kenny-1986" & checks$check == "layout")
        )
        changed <- suppressMessages(LibFormat(path = repo))
        testthat::expect_false(
          "lib-1980-1989-article-Baron-Kenny-1986.bib" %in% changed
        )
      }
    )
    testthat::test_that(
      paste(text, "LibAdd drafts from Crossref, refuses a DOI in the library"),
      {
        x <- testthat::with_mocked_bindings(
          code = suppressMessages(LibAdd(doi = "10.1000/test.1", root = root)),
          .LibCrossref = function(doi) record,
          .package = "rProject"
        )
        testthat::expect_match(
          x$file,
          "lib-2010-2019-article-Morris-Gourieroux-2019.bib",
          fixed = TRUE
        )
        testthat::expect_false(file.exists(x$file))
        dup <- record
        dup$DOI <- "10.1037/0022-3514.51.6.1173"
        testthat::expect_error(
          testthat::with_mocked_bindings(
            code = suppressMessages(LibAdd(doi = dup$DOI, root = root)),
            .LibCrossref = function(doi) dup,
            .package = "rProject"
          ),
          "already in the library"
        )
      }
    )
    unlink(root, recursive = TRUE)
  },
  text = "test-rProject-lib"
)
