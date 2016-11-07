## Preprocessing of kich

library(readxl)
library(dplyr)
library(readr)

kichdata <- read_excel("data-raw/ExcelPreprocess/mmc2_KICH.xlsx",
                       sheet= "by Patient", skip= 1)

anyDuplicated(names(kichdata))

write_csv(kichdata, path = "inst/extdata/allsubtypes/KICH.csv")

rdrop2::drop_upload("inst/extdata/allsubtypes/KICH.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
