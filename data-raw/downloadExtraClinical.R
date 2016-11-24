## Code to create "enhancedClinical" data
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcodes <- getDiseaseCodes()

## Write enhancedData to enhanced folder
writeClinicalData <- function(diseaseCode, force=FALSE) {
    enhancedPath <- dataDirectories()[["enhancedClinical"]]
    fileName <- file.path(enhancedPath, paste0(diseaseCode, ".csv"))
    if (!file.exists(fileName) || force) {
    dataset <- .mergeClinicalData(diseaseCode)
    readr::write_csv(dataset,
              path = file.path(enhancedPath,
                               paste0(diseaseCode, ".csv")))
    message(dataset, " with extra columns created")
    }
    message(fileName, " available")
}

invisible(lapply(TCGAcodes, writeClinicalData))
