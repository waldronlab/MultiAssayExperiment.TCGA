## Script for removing NA from merged data
source("R/getDiseaseCodes.R")
source("data-raw/helpers.R")

TCGAcodes <- getDiseaseCodes()

cleanMerged <- function(diseaseCode, runDate = "20160128", force = FALSE) {
    mergedLoc <- dataDirectories()[["mergedClinical"]]
    fileName <- file.path(mergedLoc,
        paste(runDate, paste0(diseaseCode, "_reduced.csv"), sep = "-"))

    droppedFile <- file.path(mergedLoc,
        paste(runDate, paste0(diseaseCode, "_dropped.rds"), sep = "-"))

    if (!file.exists(fileName) || force) {
        fullClinical <- readr::read_csv(
            file.path(mergedLoc, paste(runDate, paste0(diseaseCode,
                "_merged.csv"), sep = "-")))

        NACols <- .findNAColumns(fullClinical)
        droppedCols <- names(fullClinical)[NACols]

    if (!file.exists(droppedFile) || force) {
        saveRDS(droppedCols, file = file.path(mergedLoc,
            paste(runDate, paste0(diseaseCode, "_dropped.rds"), sep = "-")))
    }
        write_csv(fullClinical[, !NACols], path = fileName)
        message(diseaseCode, " saved at ", fileName)
    } else message(diseaseCode, "_reduced.csv already available!")
}

BiocParallel::bplapply(TCGAcodes, cleanMerged)

