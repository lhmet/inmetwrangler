# utils::globalVariables(c(".", ".only.problems", "trash", 
#                          "tens_bat","prec", "month",
#                          "day", "cld_tot", "hour_utc",
#                          "site", "visib", "year"))

. <- .only.problems <- trash <- tens_bat <- prec <- month <- day <- 
  cld_tot <- hour_utc <- site <- visib <- year <- NULL

#' Pipe operator
#'
#' See \code{\link[dplyr]{\%>\%}} for more details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
NULL