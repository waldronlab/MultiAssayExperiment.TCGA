## Script for removing NA from merged data
source("R/getDiseaseCodes.R")
source("data-raw/helpers.R")

TCGAcodes <- getDiseaseCodes()

cleanMerged <- function(diseaseCode) {
    mergedLoc <- dataDirectories()[["mergedClinical"]]
    fullClinical <- readr::read_csv(file.path(mergedLoc, paste0(diseaseCode,
                                                                "_merged.csv")))
    NACols <- .findNAColumns(fullClinical)
    droppedCols <- names(fullClinical)[NACols]
    saveRDS(droppedCols, file = file.path(mergedLoc,
                                          paste0(diseaseCode, "_dropped.rds")))
    write_csv(fullClinical[, NACols], path = file.path(mergedLoc,
    paste0(diseaseCode, "_reduced.csv")))
    message(diseaseCode, " completed!")
}

lapply(TCGAcodes, cleanMerged)
