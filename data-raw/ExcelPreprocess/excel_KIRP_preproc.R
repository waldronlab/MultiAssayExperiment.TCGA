## Preprocessing of kirp

library(readxl)
library(dplyr)
library(readr)

source("data-raw/cleanDuplicates.R")

kirpdata <- read_excel("data-raw/ExcelPreprocess/nejmoa1505917_appendix_3.xlsx",
                       sheet= "KIRP Compiled Clin. & Mol. Data", skip= 2,
                        na = "[Not Applicable]")

anyDuplicated(names(kirpdata))

cleanDuplicates(kirpdata)

write_csv(kirpdata, file = "./data-raw/ExcelPreprocess/KIRP.csv")

rdrop2::drop_upload("data-raw/ExcelPreprocess/BLCA.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
