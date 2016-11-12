## Preprocessing of kirp

library(readxl)
library(dplyr)
library(readr)

source("data-raw/cleanDuplicates.R")

kirpdata <- read_excel("data-raw/ExcelPreprocess/nejmoa1505917_appendix_3.xlsx",
                       sheet= "KIRP Compiled Clin. & Mol. Data", skip= 2,
                        na = "[Not Applicable]")

anyDuplicated(names(kirpdata))

kirpdata <- cleanDuplicates(kirpdata)
names(kirpdata) <- gsub("\r|\n", " ", names(kirpdata))

write_csv(kirpdata, path = "inst/extdata/allsubtypes/KIRP.csv")

rdrop2::drop_upload("inst/extdata/allsubtypes/KIRP.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)

