source("data-raw/helpers.R")

subsk <- .readSubtypeData("SKCM")
subsk <- as.data.frame(subsk)
splitFac <- TCGAbarcode(subsk[["Name"]], participant = FALSE, sample = TRUE)
dats <- split(subsk, splitFac)

## keep metastatic samples in metadata
metastats <- dats[["06"]]
dropFile <- file.path(dirList[["mergedClinical"]], paste0(runDate,
    "-SKCM_dropped.rds"))
droppedCols <- readRDS(dropFile)
droppedObj <- list(dropCols = droppedCols, metastatic = metastats)
saveRDS(droppedObj, dropFile)


keepSubtypes <- dats[["01"]]

subtypeFile <- file.path(dirList[["subtypePath"]], "SKCM.csv")
readr::write_csv(keepSubtypes, subtypeFile)
