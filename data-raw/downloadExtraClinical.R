## Code to create "enhancedClinical" data
source("data-raw/helpers.R")

## Write enhancedData to enhanced folder
writeClinicalData <- function(diseaseCode) {
    dataset <- .mergeClinicalData(diseaseCode)
    enhancedPath <- dataDirectories()[["enhancedClinical"]]
    if (!file.exists(enhancedPath))
        dataDirectories(TRUE)
    write_csv(dataset,
              path = file.path(enhancedPath,
                               paste0(diseaseCode, ".csv")))

}
