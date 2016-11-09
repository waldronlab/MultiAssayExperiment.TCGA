library(readr)
library(readxl)

source("data-raw/cleanDuplicates.R")

blcaxl <- read_excel("data-raw/ExcelPreprocess/Copy of BLCA_Clinical_Data_Table_updated_supplement_2013-09-24.xlsx",
                     sheet = 1L)

## Authors created averages in the last row of the data, removing it
blcaxl <- blcaxl[seq_len(nrow(blcaxl)-1), ]

anyDuplicated(names(blcaxl))

processedBLCA <- cleanDuplicates(blcaxl)

## save as csv file for upload
write_csv(processedBLCA, path = "inst/extdata/allsubtypes/BLCA.csv")

rdrop2::drop_upload("inst/extdata/allsubtypes/BLCA.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
