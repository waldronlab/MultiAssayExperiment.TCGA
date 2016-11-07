## Curating LUSC original subtype file
library(readxl)

source("data-raw/ExcelPreprocess/excel_position.R")

## Read both files in LUSC
studyData <- read_excel("data-raw/ExcelPreprocess/data.file.S7.1.p16.alterations.xls")
subtypeData <- read_excel("data-raw/ExcelPreprocess/data.file.S7.5.clinical.and.genomic.data.table.xls", skip=3)

tumorID <- subtypeData[["Tumor ID"]]
patientID <- studyData[["TCGA Patient ID"]]

tumorID <- gsub("LUSC", "TCGA", tumorID)

## Check to see if tumorIDs are identical to patientIDs
stopifnot(identical(sort(tumorID), sort(patientID)))

## name last column (original file has missing name)
names(subtypeData) <- c(names(subtypeData)[seq(ncol(subtypeData)-1)], "Expression Subtype")

## 57th Column or "BE" column
## Create sequence denoting mutation results
## Excel Range N-BE
mutationRange <- seq(excel_position("N"),
                     excel_position("BE"))
names(subtypeData)[mutationRange] <- paste0("Mutation_",
                                            names(subtypeData[mutationRange]))

## 58th column or "BF" column
## Create sequence denoting CNA results
## Excel Range BF-CV
CNArange <- seq(excel_position("BF"), excel_position("CV"))
names(subtypeData)[CNArange] <- paste0("CNA_", names(subtypeData[CNArange]))

## Based on results from above
subtypeData$`Tumor ID` <- gsub("LUSC", "TCGA", subtypeData$`Tumor ID`)

readr::write_csv(subtypeData, path = file.path(dataDirectories()[["subtypePath"]], "LUSC.csv"))

rdrop2::drop_upload(file = file.path(dataDirectories()[["subtypePath"]], "LUSC.csv"),
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
