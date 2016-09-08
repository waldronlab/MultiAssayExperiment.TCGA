## Preprocessing of SKCM

library(readxl)
library(dplyr)
skcmdata <- read_excel("data-raw/ExcelPreprocess/mmc2_skcm.xlsx", sheet= "Supplemental Table S1D", skip= 1)

write.csv(skcmdata, file = "./data-raw/ExcelPreprocess/SKCM.csv")
