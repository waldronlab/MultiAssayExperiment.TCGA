## Preprocessing of LUAD
library(readxl)
library(dplyr)
library(readr)

source("data-raw/cleanDuplicates.R")
source("data-raw/ExcelPreprocess/excel_position.R")
source("data-raw/cleanDuplicates.R")
source("R/dataDirectories.R")

## Badly formatted excel file
content <- readxl::read_excel("data-raw/ExcelPreprocess/lungCarcinoma_LUAD.xlsx",
                           sheet = "S_Table 7-Clinical&Molec_Summar")[1:3, ]

luad <- readxl::read_excel("data-raw/ExcelPreprocess/lungCarcinoma_LUAD.xlsx",
                           sheet = "S_Table 7-Clinical&Molec_Summar", skip = 3,
                           na = "[Not Available]")

## Excel Cell Ranges (M-AI, AM-BP, BQ-CT)
mutationRange <- seq(excel_position("M"), excel_position("AI"))
CNARange <- seq(excel_position("AM"), excel_position("BP"))
FCNARange <- seq(excel_position("BQ"), excel_position("CT"))

names(luad)[mutationRange] <- paste0("Mutation_", names(luad[mutationRange]))
names(luad)[CNARange] <- paste0("CNA_", names(luad[CNARange]))
names(luad)[FCNARange] <- paste0("FCNA_", names(luad[FCNARange]))

luad <- cleanDuplicates(luad)

readr::write_csv(luad, "inst/extdata/allsubtypes/LUAD.csv")

rdrop2::drop_upload(file = file.path(dataDirectories()[["subtypePath"]],
                                     "LUAD.csv"),
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
