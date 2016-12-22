## Script for downloading clinical data without DropBox

## Load vector of TCGA cancer codes
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcode <- getDiseaseCodes()

processClinicalFirehose <- function(diseaseCode, force = FALSE) {
    runDate <- "20151101"
    dirList <- dataDirectories()
    basicClinical <- dirList[["basicClinical"]]
    fileName <- file.path(basicClinical, paste0(diseaseCode, ".csv"))
    if (!file.exists(fileName) || force) {
        TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode,
                                                  runDate = runDate,
                                                  Clinic = TRUE,
                                                  destdir =
                                                      dirList[["rawClinical"]])
        TCGAclin <- TCGAclin@Clinical
        stdBarcodes <- .stdIDs(rownames(TCGAclin))
        TCGAclin <- cbind(patientID = stdBarcodes, TCGAclin)
        readr::write_csv(TCGAclin, path = fileName)
        rm(TCGAclin, stdBarcodes)
    } else { message(fileName, " already downloaded and processed") }
}

BiocParallel::bplapply(TCGAcode, processClinicalFirehose)

