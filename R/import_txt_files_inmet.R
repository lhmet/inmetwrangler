#' Read ASCII data file of INMET's automatic weather stations
#' @importFrom dplyr %>%
#' @importFrom stats setNames 
#' @importFrom utils head
#' @param .file path to file
#' @param .verbose logical value, when it is set to TRUE show warnings 
#' and messages
#' @param .only.problems logical value. Set TRUE to report problems, 
#' FALSE to return meteorological data
#' @param .full.names a logical value. If TRUE, the directory path is prepended 
#' to the file names to give a relative file path. If FALSE, the file names 
#' (rather than paths) are returned.
#' @details When \code{only.problems} is TRUE a data frame with one row for 
#' each problem found for every file. When the files do not have any problem the 
#' data frame is returned empty (0 rows).
#' @return A data frame with one row for each problem and four columns:
#'   \item{row,col}{Row and column of problem}
#'   \item{expected}{What readr expected to find}
#'   \item{actual}{What it actually got}
#'   \item{file}{file name or the path to file (if \code{.full.names} is TRUE)}
#' @export
read_txt_file_inmet <- function(.file, 
                                .verbose = TRUE,
                                .only.problems = FALSE,
                                .full.names = FALSE){
  
  # .file <- "inst/extdata/A805.txt"; .verbose = TRUE; .only.problems = FALSE
  # .file <- "inst/extdata/A838.txt"; .verbose = TRUE; .only.problems = TRUE
  # .file <- "inst/extdata/A803.txt"; .verbose = TRUE; .only.problems = TRUE
  # .file <- "inst/extdata/A852.txt"; .verbose = TRUE; .only.problems = TRUE
  # .file = txt_files[3]; .verbose = FALSE; .only.problems = TRUE
  stopifnot(is.character(.file),
            is.logical(.verbose),
            is.logical(.only.problems),
            file.exists(.file))
  
  # raw data
  all_lines <- readr::read_lines(.file)
  
  # station id used to extract the data from database
  # with SQL command SELECT
  # should match the id column values of dataset
  aws_id_from_sql_cmd <- all_lines %>%
    purrr::keep(., .p = ~stringr::str_detect(.x, "SELECT")) %>%
    #keep(., .p = function(x) str_detect("SELECT"))
    stringr::str_extract(., "[A-Za-z]{1}[0-9]{3,4}") %>%
    stringr::str_to_upper(.)
  
  if (.verbose) {
    message("-------------------------------------------")
    message(.file)
    message('AWS ID from header: ', aws_id_from_sql_cmd)
  }
  stopifnot(aws_id_from_sql_cmd == 
              stringr::str_extract(basename(.file), "[A-Za-z]{1}[0-9]{3,4}") )
  # head(read_lines(.file))
  # tail(read_lines(.file))
  
  # rows limits to extract data
  row_limits <- all_lines %>%
    stringr::str_detect(., pattern = "pre>") %>%
    #str_detect(., "[A-Za-z]{1}[0-9]{3,4}") %>%
    which() # %>%range()
  
  # set file_format (2 cases according to header files pattern)
  if (length(row_limits) == 2) {
    file_format <- 1 
# nolint start
    ## header pattern
    #"<html><head>"                                                           
    #"<meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1252\"></head><body>Sql"
    #" - SELECT * FROM cadRema WHERE RemaEstacao='a807'  and RemaData BETWEEN "
    #"'2010-01-01' AND '2011-12-31' ORDER BY RemaEstacao,RemaData,RemaHora <br><pre>A807 2010 01 01 00 11.6 21 18.1 18.7 18.1 94 94 88 17.1 17.1 16.6 911.4 911.4 910.8 2.9 122 9.5 -2.240 0.0 / //// ///// ///// ="
# nolint end
  } else {
    file_format <- 2
# nolint start
    # header pattern
    #"Sql - SELECT * FROM cadRema WHERE RemaEstacao='A880' and RemaData BETWEEN '2010-01-01' AND '2011-12-31' ORDER BY RemaEstacao,RemaData,RemaHora "
    #""                                                                                                                                               
    #"A880 2010 01 01 00 12.3 17 14.7 16.0 14.7 80 81 76 11.3 12.6 11.3 906.8 906.8 906.5 4.6 106 9.5 -3.538 0.0 / //// ///// ///// ="
# nolint end
  } 
  
  var_names <- c("site", "year", "month", "day", "hour_utc", 
                 "tens_bat", "temp_cpu", 
                 "tair_inst", "tair_max", "tair_min",
                 "rh_inst", "rh_max", "rh_min",
                 "tdew_inst", "tdew_max", "tdew_min",
                 "press_inst", "press_max", "press_min",
                 "ws", "wd", "ws_max",
                 "rg", "prec", "cld_tot", "cld_cod", "cld_base", 
                 "visib", "trash")
  
  #all_lines[row_limits]
# file format 1 ---------------------------------------------------------------
  if (file_format == 1) {
    
    # raw txt file
    rows_inner <- row_limits + c(1,-1)
    #all_lines[row_limits]
    # continuous rows of data
    data_rows <- all_lines[rows_inner[1]:rows_inner[2]]
    # data collapsed to header
    data_1st_row <- all_lines[rows_inner[1] - 1] %>%
      stringr::str_split(., "<pre>") %>%
      unlist() %>%
      magrittr::extract(2)
    
    #a <- fread(txt_files[1], nrows = row_limits[2]-1, skip = row_limits[1]-1)
    data_rows <- c(data_1st_row, data_rows)
    #head(data_rows); 
    #tail(data_rows)
    if (.verbose) {
      hdata <- data_rows %>%
        paste0(., collapse = "\n") %>%
        readr::read_delim(.,
                          delim = " ",
                          skip = 2, 
                          col_names = FALSE,
                          na = c("//////","/////", "////",
                                 "///", "//", "/", "="),
                          guess_max = 16000) %>%
        setNames(var_names) %>%
        dplyr::select(-trash)  
    } else {
      hdata <- data_rows %>%
        paste0(., collapse = "\n")
      hdata <- suppressWarnings(
        readr::read_delim(hdata,
                          delim = " ",
                          skip = 2, 
                          col_names = FALSE,
                          na = c("//////","/////", "////",
                                 "///", "//", "/", "="),
                          guess_max = 16000)
        )
      hdata <- hdata %>%
        setNames(var_names) %>%
        dplyr::select(-trash)  
    }# end if .verbose

    probs <- readr::problems(hdata)
    # because data were read with read_file
    if (nrow(probs) > 0) {
      probs <- dplyr::mutate(probs,
                      row = row + 2,
                      file = ifelse(.full.names, 
                                    .file,
                                    basename(.file)) 
                      )
    } else {
      #probs <- NULL
      probs <- tibble::tibble(
        row = 0,
        row_file = 0,
        col = 0,
        expected = paste(ncol(hdata), "columns"),
        actual = paste(ncol(hdata), "columns"),
        file = ifelse(.full.names, 
                      .file,
                      basename(.file)))
    }
    if (.only.problems) return(probs)

#extract_num <- function(x) as.numeric(gsub("[^0-9.-]+", "", as.character(x)))
    #pn <- parse_number(hdata$tair_max); attr(pn, "problems")
    #hdata$tair_max[is.na(parse_number(hdata$tair_max))]
    hdata <- suppressWarnings(dplyr::mutate_at(hdata,
                                               dplyr::vars(tens_bat:prec), 
                                               readr::parse_number))
    hdata <- dplyr::mutate_at(hdata, 
                              dplyr::vars(site, cld_tot:visib), 
                              readr::parse_character)
    hdata <- dplyr::mutate_at(hdata,
                              dplyr::vars(year:hour_utc), 
                              readr::parse_integer)
    # hdata
    
  } else {
# file format 2 ---------------------------------------------------------------
    
    ## txt file cleaned manualy
    # head(all_lines)
    # tail(all_lines)
    # .file <- "../data-raw/RAW-DATA-8o-DISME/data_piece_A803.txt"
    #.file <- "~/rows_prob_a803.txt"

    # read_delim ignore empty rows (the last) 
    #  and report problems better than data.table
    to_skip <- which(head(all_lines) == "")
    
    # to discover cols type
    # cols_specif <- spec_delim(.file, 
    #            delim = " ",
    #            guess_max=14000, 
    #            col_names = FALSE, 
    #            skip = 2,
    #            #na = c("//////","/////", "////", "///", "//", "/", "=")
    #            )
    if (.verbose) {
      hdata <- readr::read_file(.file) %>%
        #stringi::stri_enc_toutf8(.) %>%
        #stringi::stri_conv(x, to = "UTF-8", from = "latin1")
        #stringr::str_replace_all(., "[/]{1,6}", "NA") %>%
        readr::read_delim(.,
                          delim = " ",
                          # because A804 was send after others
                          # and A803
                          skip = to_skip, 
                          col_names = FALSE,
                          na = c("//////","/////", "////",
                                 "///", "//", "/", "="),
                          guess_max = 20000
        ) %>%
        setNames(var_names) %>%
        dplyr::select(-trash)
    } else {
      hdata <- readr::read_file(.file) 
        #stringi::stri_enc_toutf8(.) %>%
        #stringi::stri_conv(x, to = "UTF-8", from = "latin1")
        #stringr::str_replace_all(., "[/]{1,6}", "NA") %>%
        hdata <- suppressWarnings(
          readr::read_delim(hdata,
                            delim = " ",
                            # because A804 was send after others
                            # and A803
                            skip = to_skip, 
                            col_names = FALSE,
                            na = c("//////","/////", "////",
                                   "///", "//", "/", "="),
                            guess_max = 16000)
        )

        hdata <- hdata %>%
          setNames(var_names) %>%
          dplyr::select(-trash)
    } # end if .verbose
    
    probs <- readr::problems(hdata)
    # View(hdata[probs[["row"]], ])
    # because data were read with read_file
    if (nrow(probs) > 0) {
      probs <- dplyr::mutate(probs,
                      row_file = row + to_skip,
                      file = ifelse(.full.names, 
                                    .file,
                                    basename(.file))
      )
    } else {
      #probs <- NULL
      probs <- tibble::tibble(
                             row = 0,
                             row_file = 0,
                             col = 0,
                             expected = paste(ncol(hdata), "columns"),
                             actual = paste(ncol(hdata), "columns"),
                             file = ifelse(.full.names, 
                                           .file,
                                           basename(.file))
                             )
    }
    if (.only.problems) return(probs)
    
    # r <- probs[, "row"] %>%  t() %>% c()
    # slice(hdata, r) %>% select(-(tair_inst:tdew_min))
    # hdata2 <- data.table::fread(.file,
    #                            stringsAsFactors = FALSE,
    #                            header = FALSE,
    #                            skip = 2,
    #                            #fill = TRUE,
    #          na.strings = c("//////","/////", "////", "///", "//", "/", "=")
    # ) %>%
    #    as_tibble() %>%
    #View(hdata2[probs[["row"]], ])
    #   setNames(var_names) %>%
    #   select(-trash)
    hdata <- suppressWarnings(dplyr::mutate_at(hdata, 
                                               dplyr::vars(tens_bat:prec),
                                               readr::parse_number))
    hdata <- dplyr::mutate_at(hdata, 
                              dplyr::vars(site, cld_tot:visib),
                              readr::parse_character)
    hdata <- dplyr::mutate_at(hdata,
                              dplyr::vars(year:hour_utc),
                              readr::parse_integer)
  }# end else file_format
  
  # tail(hdata)
  hdata <- hdata %>%
    # because data.table::fread read empty
    #filter(site != "")
    dplyr::mutate(.,
           date = paste0(year, "-", month, "-", day, " ", hour_utc, ":00:00"),
           date = as.POSIXct(date, tz = "UTC")) %>%  
    dplyr::select(., site, date, tens_bat:visib) %>%
    dplyr::arrange(date)
  
  return(hdata)
}


#' Import raw data files of automatic stations 
#'
#' @param files character vector with path to files
#' @param verbose logical scalar. If TRUE, print messages and warnings.
#' @param only.problems logical value. Set TRUE to return a tibble 
#' with problems information on file and FALSE to return meteorological data.
#' @param full.names a logical value. If TRUE, the directory path is prepended 
#' to the file names to give a relative file path. If FALSE, the file names 
#' (rather than paths) are returned.
#' @return A data frame with one row for each problem and four columns:
#'   \item{row,col}{Row and column of problem}
#'   \item{expected}{What readr expected to find}
#'   \item{actual}{What it actually got}
#'   \item{file}{file name or the path to file (if \code{full.names} is TRUE)}
#' @export
#' @examples
#' 
#' library(dplyr); library(purrr); library(stringr); library(readr)
#'# missing columns problem example
#'myfile <- system.file("extdata", "A838.txt", package = "inmetwrangler")
#'myfile
#'  A838_problems <- import_txt_files_inmet(files = myfile, 
#'                                          verbose = TRUE, 
#'                                          only.problems = TRUE)
#'  A838_data <- import_txt_files_inmet(files = myfile, 
#'                                      verbose = TRUE, 
#'                                      only.problems = FALSE)
#'#looking at rows
#'for(irow in A838_problems$row) read_lines(myfile, skip = irow-2, n_max = irow+2)
#'# View(slice(A838_data, A838_problems$row)) #  columns filled with NAs
import_txt_files_inmet <- function(files, 
                                   verbose = TRUE, 
                                   only.problems = FALSE,
                                   full.names = FALSE){
  res_tbl <- purrr::map_df(files, 
                           ~read_txt_file_inmet(.x,
                                                .only.problems = only.problems, 
                                                .verbose = verbose,
                                                .full.names = full.names
                           ))
   if (only.problems) {
     res_tbl <- dplyr::filter( res_tbl, 
                               row > 0 #|
         #(readr::parse_number(expected) != readr::parse_number(actual))
     )
   }# end if prob
  return(res_tbl)
}


