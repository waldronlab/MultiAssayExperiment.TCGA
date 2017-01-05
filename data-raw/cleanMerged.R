## Script for removing NA from merged data
source("R/getDiseaseCodes.R")
source("data-raw/helpers.R")

TCGAcodes <- getDiseaseCodes()

cleanMerged <- function(diseaseCode) {
    mergedLoc <- dataDirectories()[["mergedClinical"]]
    fileName <- file.path(mergedLoc, paste0(diseaseCode, "_reduced.csv"))
    if (!file.exists(fileName)) {
        fullClinical <- readr::read_csv(
                                        file.path(mergedLoc,
                                                  paste0(diseaseCode,
                                                         "_merged.csv")))
        NACols <- .findNAColumns(fullClinical)
        droppedCols <- names(fullClinical)[NACols]
        saveRDS(droppedCols, file = file.path(
                                              mergedLoc,
                                              paste0(diseaseCode,
                                                     "_dropped.rds")))
        write_csv(fullClinical[, !NACols], path = fileName)
        message(diseaseCode, " completed!")
        return()
    }
    message(diseaseCode, "_reduced.csv already available!")
}

BiocParallel::bplapply(TCGAcodes, cleanMerged)

