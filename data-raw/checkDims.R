## Code to check dimensions of files are good
source("R/getDiseaseCodes.R")
source("R/dataDirectories.R")
TCGAcodes <- getDiseaseCodes()
dirList <- dataDirectories()

checkDims <- function(diseaseCode) {
    listDirs <- dirList[c("basicClinical", "enhancedClinical", "mergedClinical")]
    resolvePaths <- lapply(listDirs, function(directory) {
        hits <- list.files(directory, full.names = TRUE, pattern = paste0("^", diseaseCode))
        hits[!grepl("dropped.rds$", basename(hits))]
    })
    locations <- unlist(resolvePaths)
    dimensions <- lapply(locations, function(fileLocation) {
        dataFile <- readr::read_csv(fileLocation)
        cbind.data.frame(rows = dim(dataFile)[[1]], columns = dim(dataFile)[[2]])
    })
    cbind.data.frame(file.location = locations, do.call(rbind, dimensions))
}

allDims <- lapply(TCGAcodes, checkDims)
allDims
