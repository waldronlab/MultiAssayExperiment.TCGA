## Code to create "enhancedClinical" data
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcodes <- getDiseaseCodes()

## Write enhancedData to enhanced folder
writeClinicalData <- function(diseaseCode, runDate = "20160128", force=FALSE) {
    enhancedPath <- dataDirectories()[["enhancedClinical"]]
    fileName <- file.path(enhancedPath,
                          paste(runDate, paste0(diseaseCode, ".csv"), sep = "-"))
    if (!file.exists(fileName) || force) {
    dataset <- .mergeClinicalData(diseaseCode, runDate = runDate)
    readr::write_csv(dataset, path = fileName)
    message(dataset, " with extra columns created")
    rm(dataset)
    }
    message(fileName, " available")
}

BiocParallel::bplapply(TCGAcodes, writeClinicalData)
