## ------------------------------------------------------------------------
library(devtools)

## ---- eval = FALSE-------------------------------------------------------
#  install_github("lhmet/inmetwrangler")

## ------------------------------------------------------------------------
library(inmetwrangler)

## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(comment = "#>")

## ---- message=FALSE, warning=FALSE---------------------------------------
library(knitr)
library(tidyverse)
library(stringr)

## ------------------------------------------------------------------------
#.libPaths()
# arquivos disponíveis
list.files(system.file("extdata", package = "inmetwrangler"))
                       #, full.names = TRUE)


## ---- eval = FALSE-------------------------------------------------------
#  system.file("extdata", "A838.txt", package = "inmetwrangler")

## ---- echo = FALSE, message=FALSE, warning=FALSE-------------------------
system.file("extdata", "A838.txt", package = "inmetwrangler") %>%
  stringr::str_replace_all(.libPaths()[1], "~/.R")

## ------------------------------------------------------------------------
ex_file_h4 <- system.file("extdata", "A819.txt", package = "inmetwrangler")
head(read_lines(ex_file_h4))

## ------------------------------------------------------------------------
ex_file_h3 <- system.file("extdata", "A804.txt", package = "inmetwrangler")
head(read_lines(ex_file_h3))

## ------------------------------------------------------------------------
ex_file_h2 <- system.file("extdata", "A852.txt", package = "inmetwrangler")
head(read_lines(ex_file_h2))

## ------------------------------------------------------------------------
myfile <- system.file("extdata", "A838.txt", package = "inmetwrangler")
A838_problems <- import_txt_files_inmet(files = myfile, 
                                        verbose = FALSE,
                                        only.problems = TRUE, 
                                        full.names = TRUE)
kable(A838_problems)

## ------------------------------------------------------------------------
for (i in seq_along(A838_problems$row)) {
  cat(" ------------", "Problem ", i, " ------------", "\n")
  ir <- A838_problems$row_file[i]
  print(read_lines(file = myfile)[(ir - 1):(ir + 1)])
}

## ------------------------------------------------------------------------
myfile <- system.file("extdata", "A852.txt", package = "inmetwrangler")
myfile
A852_problems <- import_txt_files_inmet(files = myfile, 
                                        verbose = FALSE,
                                        only.problems = TRUE)
kable(A852_problems)

## ------------------------------------------------------------------------
txt_files <- list.files(system.file("extdata", 
                                package = "inmetwrangler"),
                    full.names = TRUE) 
txt_files_no_prob <- discard(txt_files, ~str_detect(.x, "A852|A838"))
# somente arquivos sem problemas estruturais
basename(txt_files_no_prob)
probs <- import_txt_files_inmet(txt_files_no_prob, 
                       verbose = FALSE, 
                       only.problems = TRUE, 
                       full.names = FALSE)
probs
str(probs)

## ------------------------------------------------------------------------
# merge data files
hdata <- import_txt_files_inmet(files = txt_files, verbose = FALSE)
kable(head(hdata[, 1:10]))
kable(tail(hdata[, 1:10]))

## ------------------------------------------------------------------------
session_info()

