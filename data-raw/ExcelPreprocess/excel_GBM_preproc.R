## Preprocessing of GBM

library(readxl)
library(dplyr)
library(readr)

gbmxl <- read_excel("data-raw/ExcelPreprocess/mmc2_GBM.xlsx", skip = 1)

lggdata <- dplyr::slice(gbmxl, Study == "Brain Lower Grade Glioma" )

gbmdata <- dplyr::slice(gbmxl, Study == "Glioblastoma multiforme")

write_csv(lggdata, file = "data-raw/ExcelPreprocess/LGG.csv")
write_csv(gbmdata, file = "data-raw/ExcelPreprocess/GBM.csv")
