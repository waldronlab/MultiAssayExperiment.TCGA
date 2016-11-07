## Preprocessing of GBM

library(readxl)
library(dplyr)
library(readr)

gbmxl <- read_excel("data-raw/ExcelPreprocess/mmc2_LGGGBM.xlsx",
                    skip = 1, na = "NA")
gbmxl <- split(gbmxl, gbmxl$Study)

lggdata <- gbmxl[["Brain Lower Grade Glioma"]]

gbmdata <- gbmxl[["Glioblastoma multiforme"]]

stopifnot(nrow(gbmxl) == sum(nrow(lggdata), nrow(gbmdata)))

write_csv(lggdata, path = "inst/extdata/allsubtypes/LGG.csv")

write_csv(gbmdata, path = "inst/extdata/allsubtypes/GBM.csv")

rdrop2::drop_upload("inst/extdata/allsubtypes/LGG.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)

rdrop2::drop_upload("inst/extdata/allsubtypes/GBM.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
