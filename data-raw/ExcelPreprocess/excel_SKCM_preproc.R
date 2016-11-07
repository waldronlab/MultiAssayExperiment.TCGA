## Preprocessing of SKCM
library(readxl)
library(dplyr)
library(readr)

source("R/dataDirectories.R")

skcmdata <- read_excel("data-raw/ExcelPreprocess/Patient_Info_barcode_Tab_S1D.xlsx",
                       sheet= "Supplemental Table S1D", skip= 1, na = "-")

stopifnot(!anyDuplicated(names(skcmdata)))

write_csv(skcmdata, path = "inst/extdata/allsubtypes/SKCM.csv")

rdrop2::drop_upload(file = file.path(dataDirectories()[["subtypePath"]], "SKCM.csv"),
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
