## Code to check file metadata
## (including dimensions and proportion of cells missing)
TCGAcodes <- getDiseaseCodes()
dirList <- dataDirectories()

checkMeta <- function(diseaseCode) {
    listDirs <-
        dirList[c("basicClinical", "enhancedClinical", "mergedClinical")]
    resolvePaths <- lapply(listDirs, function(directory) {
        hits <-
            list.files(directory, full.names = TRUE, pattern = diseaseCode)
        hits[!grepl("dropped.rds$", basename(hits))]
    })
    locations <- unlist(resolvePaths)
    names(locations) <- c("basic", "enhanced", "merged", "reduced")
    metadata <- lapply(locations, function(fileLocation) {
                           dataFile <- readr::read_csv(fileLocation)
                           cellMissing <- sum(rapply(dataFile, is.na))
                           datDims <- dim(dataFile)
                           totalCell <- datDims[[1L]]*datDims[[2L]]
                           cbind.data.frame(rows = datDims[[1L]],
                                            columns = datDims[[2L]],
                                            prop.missing = cellMissing/totalCell)
                          })
    cbind.data.frame(file.location = locations, do.call(rbind, metadata))
}

mdata <- lapply(TCGAcodes, checkMeta)

saveRDS(mdata, "metadataChecks.Rds")

