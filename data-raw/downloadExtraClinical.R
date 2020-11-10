## Code to create "enhancedClinical" data
source("R/utils.R")
source("R/getDiseaseCodes.R")
TCGAcodes <- getDiseaseCodes()

## Write enhancedData to enhanced folder
writeClinicalData <- function(diseaseCode, runDate = "20160128", force=FALSE) {
    enhancedPath <- dataDirectories()[["enhancedClinical"]]
    fileName <- file.path(enhancedPath,
                          paste(runDate, paste0(diseaseCode, ".csv"), sep = "-"))
    if (!file.exists(fileName) || force) {
        dataset <- .mergeClinicalData(diseaseCode, runDate = runDate)
        readr::write_csv(dataset, file = fileName)
        message(diseaseCode, " with extra columns created")
        rm(dataset); gc()
    }
    message("\n", fileName, " available")
}

# bpm <- MulticoreParam(workers = 36, stop.on.error = FALSE, progressbar = TRUE)
# writes <- BiocParallel::bplapply(
#     setNames(nm = TCGAcodes), writeClinicalData, force = TRUE, BPPARAM = bpm
# )

for (i in TCGAcodes) {
    writeClinicalData(i, force = TRUE)
    gc()
}
