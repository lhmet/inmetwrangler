pkgname <- "inmetwrangler"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('inmetwrangler')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
cleanEx()
nameEx("import_txt_files_inmet")
### * import_txt_files_inmet

flush(stderr()); flush(stdout())

### Name: import_txt_files_inmet
### Title: Import raw data files of automatic stations
### Aliases: import_txt_files_inmet

### ** Examples


library(dplyr); library(purrr); library(stringr); library(readr)
# missing columns problem example
myfile <- system.file("extdata", "A838.txt", package = "inmetwrangler")
myfile
 A838_problems <- import_txt_files_inmet(files = myfile, 
                                         verbose = TRUE, 
                                         only.problems = TRUE)
 A838_data <- import_txt_files_inmet(files = myfile, 
                                     verbose = TRUE, 
                                     only.problems = FALSE)
#looking at rows
for(irow in A838_problems$row) read_lines(myfile, skip = irow-2, n_max = irow+2)
# View(slice(A838_data, A838_problems$row)) #  columns filled with NAs



### * <FOOTER>
###
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
