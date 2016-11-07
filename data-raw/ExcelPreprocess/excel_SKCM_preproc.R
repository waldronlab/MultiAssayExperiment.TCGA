## Preprocessing of SKCM

library(readxl)
library(dplyr)
library(readr)

skcmdata <- read_excel("data-raw/ExcelPreprocess/mmc2_skcm.xlsx",
                       sheet= "Supplemental Table S1D", skip= 1)

write_csv(skcmdata, file = "inst/extdata/allsubtypes/SKCM.csv")
