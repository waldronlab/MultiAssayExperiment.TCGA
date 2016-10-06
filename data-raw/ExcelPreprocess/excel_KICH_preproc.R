## Preprocessing of kich

library(readxl)
library(dplyr)
library(readr)

kichdata <- read_excel("data-raw/ExcelPreprocess/mmc2_kich.xlsx", sheet= "by Patient", skip= 1)

write_csv(kichdata, file = "./data-raw/ExcelPreprocess/KICH.csv")
