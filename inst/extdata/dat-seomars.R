# Data files from seomars for use in examples ---------------------------------

ascii_seomars <- list.files("../data-raw/RAW-DATA-8o-DISME", 
           full.names = TRUE, 
           pattern = "\\.txt$", 
           recursive = TRUE
           ) 
# example files used in vignettes
ex_files <- c("A852.txt", "A838.txt", "A805.txt", "A804.txt", "A819.txt")
ascii_seomars_sel <- ascii_seomars[basename(ascii_seomars) %in% ex_files]


#'inst/extdata/inmet-data-ascii-seomars.tar.gz'

# does not work
# tar(tarfile = 'inst/extdata/',
#     files =  ascii_seomars_sel, # external files
#     compression = 'gzip',
#     tar = "tar")

# Function to compress files in a tar.gz file ---------------------------------
tar_gz <- function(archive = "inst/extdata/inmet-data-ascii-seomars.tar.gz",
                   files = ascii_seomars_sel){
  stopifnot(all(file.exists(files)))
  cmd <- paste0("tar -czvf", " ", 
                archive, " ", 
                paste(files, collapse = " "))
  invisible(system(cmd, TRUE))
}

tar_gz("inst/extdata/inmet-data-ascii-seomars.tar.gz", ascii_seomars_sel)








#devtools::use_data_raw()