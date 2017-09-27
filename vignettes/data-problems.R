## ---- eval = FALSE-------------------------------------------------------
#  library(devtools)
#  install_github("lhmet/inmetwrangler")

## ------------------------------------------------------------------------
library(inmetwrangler)

## ------------------------------------------------------------------------
library(knitr)
library(readr)
library(openair)

## ------------------------------------------------------------------------
#.libPaths()
# arquivos disponíveis
list.files(system.file("extdata", package = "inmetwrangler"
                       #, full.names = TRUE)
))

## ---- eval = FALSE-------------------------------------------------------
#  system.file("extdata", "A838.txt", package = "inmetwrangler")

## ---- echo = FALSE, message=FALSE, warning=FALSE-------------------------
library(dplyr)
system.file("extdata", "A838.txt", package = "inmetwrangler") %>%
  stringr::str_replace_all(.libPaths()[1], "~/.R")
detach(package:dplyr)

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
for (i in 1:nrow(A838_problems)) {
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
txt_files
# merge data files
hdata <- import_txt_files_inmet(files = txt_files, verbose = FALSE)
kable(head(hdata[, 1:10]))
kable(tail(hdata[, 1:10]))

## ---- fig.align='center', fig.height=9, fig.width=6, fig.cap = "Séries horárias de Precipitação.", include = FALSE----
## Gráficos
#The figure sizes have been customised so that you can easily put two images side-by-side. 
nsites <- length(unique(hdata$site))
timePlot(hdata, 
         "prec", 
         type = "site", 
         plot.type = "h", 
         layout = c(1, nsites),
         date.format = "%b\n%Y")

