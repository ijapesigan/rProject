#' Generate License File
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams LibPaths
#' @param type Character string.
#'   License type.
#'   Available values include `"mit"` and `"gpl3"`.
#' @return Called for its side effects; the value is not meaningful.
#' @examples
#' \dontrun{
#' License(path = getwd())
#' }
#' @export
License <- function(path,
                    type = "mit") {
  if (!is.null(x = type)) {
    if (type == "mit") {
      file.copy(
        from = system.file(
          "MIT",
          "LICENSE",
          package = "rProject"
        ),
        to = path
      )
      file.copy(
        from = system.file(
          "MIT",
          "LICENSE.md",
          package = "rProject"
        ),
        to = path
      )
    }
    if (type == "gpl3") {
      file.copy(
        from = system.file(
          "GPL3",
          "LICENSE.md",
          package = "rProject"
        ),
        to = path
      )
    }
  }
}
