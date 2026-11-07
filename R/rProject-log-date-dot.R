#' The Date of a Change Set
#'
#' Today's date in the user's time zone. The images set the time zone to UTC,
#' where `Sys.Date()` gives tomorrow's date for an evening push.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param time POSIXct.
#'   The time to format.
#' @param tz Character string.
#'   The time zone. By default, the environment variable `RPROJECT_TZ`,
#'   else `America/New_York`.
#' @return Returns the date as a character string, `YYYY-MM-DD`.
#' @examples
#' .LogDate()
#' @noRd
.LogDate <- function(time = Sys.time(),
                     tz = Sys.getenv(
                       x = "RPROJECT_TZ",
                       unset = "America/New_York"
                     )) {
  format(x = time, format = "%Y-%m-%d", tz = tz)
}
