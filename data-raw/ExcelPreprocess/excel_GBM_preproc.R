## Preprocessing of GBM

library(readxl)
library(dplyr)
library(readr)

gbmxl <- read_excel("data-raw/ExcelPreprocess/mmc2_GBM.xlsx", skip = 1)
gbmxl <- split(gbmxl, gbmxl$Study)

lggdata <- gbmxl[["Brain Lower Grade Glioma"]]

gbmdata <- gbmxl[["Glioblastoma multiforme"]]

stopifnot(nrow(gbmxl) == sum(nrow(lggdata), nrow(gbmdata)))

write_csv(lggdata, path = "data-raw/ExcelPreprocess/LGG.csv")

write_csv(gbmdata, path = "data-raw/ExcelPreprocess/GBM.csv")

rdrop2::drop_upload("data-raw/ExcelPreprocess/GBM.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
