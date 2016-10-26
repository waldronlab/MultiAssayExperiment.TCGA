## Read both files in LUSC
library(readxl)
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
mutationRange <- seq(which(letters == "n"),
                     length(rep(letters, 2))+which(letters=="e"))
names(subtypeData)[mutationRange] <- paste0("Mutation_",
                                            names(subtypeData[mutationRange]))

## 58th column or "BF" column
## Create sequence denoting CNA results
CNArange <- seq(length(rep(letters, 2))+which(letters=="f"), length(rep(letters, 3))+which(letters=="v"))
names(subtypeData)[CNArange] <- paste0("CNA_", names(subtypeData[CNArange]))

readr::write_csv(subtypeData, path = file.path(dataDirectories()[["subtypePath"]], "LUSC.csv"))

rdrop2::drop_upload(file = file.path(dataDirectories()[["subtypePath"]], "LUSC.csv"),
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
