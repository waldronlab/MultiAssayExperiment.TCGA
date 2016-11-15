## Script for removing NA from merged data
source("data-raw/diseaseCodes.R")
source("data-raw/helpers.R")

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

checkDims <- lapply(includeDatasets, function(dx) {
    mergedLoc <- dataDirectories()[["mergedClinical"]]
    Clinical <- readr::read_csv(file.path(mergedLoc, paste0(dx,
                                                                "_reduced.csv")))
    return(dim(Clinical))
})

