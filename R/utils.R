
. <- .only.problems <- trash <- tens_bat <- prec <- month <- day <- 
  cld_tot <- hour_utc <- site <- visib <- year <- .verbose <- row <- 
  expected <- actual <- NULL

#' Extract files from a tar.gz file.
#'
#'Extract file(s) from a tar.gz file with data. 
#'
#' @param file.txt The filename within the input tar.gz file.
#' @param file.tar.gz The pathname of the tar.gz file
#' @param ex.dir The directory to extract files to 
#'
#'@details Useful for vignettes and examples.
#' @return
#'
#' @examples
#' 
untar_file <- function(file.txt = "A804.txt",
                       file.tar.gz = "RAW-DATA-8o-DISME/extdata.tar.gz",
                       ex.dir = "."){
  stopifnot(file.txt %in% untar(file.tar.gz, list = TRUE))
  untar(file.tar.gz, files = file.txt, exdir = ex.dir)
}
