.ConformSimMake <- function(path,
                            template) {
  # .sim/make.sh against the template's copy (written once, then the
  # project's): a copy that differs is the author's to decide; a missing one
  # is written by make project
  own <- file.path(path, ".sim", "make.sh")
  source <- file.path(template$root, "once", "sim-make.sh")
  differs <- file.exists(own) && file.exists(source) &&
    !identical(
      x = readLines(con = own, warn = FALSE),
      y = readLines(con = source, warn = FALSE)
    )
  .ConformRow(
    rule = "sim-make",
    class = "decide",
    file = if (differs) {
      file.path(".sim", "make.sh")
    } else {
      character(length = 0L)
    },
    message = paste(
      "differs from the template (inst/template/once/sim-make.sh);",
      "chained jobs go in .sim/make-<name>.sh"
    )
  )
}
