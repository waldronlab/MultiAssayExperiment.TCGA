## Script for downloading clinical data without DropBox

## Load vector of TCGA cancer codes
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcode <- getDiseaseCodes()

processClinicalFirehose <- function(diseaseCode) {
    runDate <- "20151101"
    dirList <- dataDirectories()
    rawRDSdata <- file.path("data", paste0(diseaseCode, ".rds"))
    if (file.exists(rawRDSdata)) {
        TCGAdata <- readRDS(rawRDSdata)
        TCGAclin <- TCGAdata@Clinical
        rm(TCGAdata)
        gc()
    } else {
        TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode, runDate=runDate,
                                                  Clinic = TRUE,
                                                  destdir =
                                                      dirList[["rawClinical"]])
    }
    stdBarcodes <- .stdIDs(rownames(TCGAclin))
    TCGAclin <- cbind(patientID = stdBarcodes, TCGAclin)
    readr::write_csv(TCGAclin, path=file.path(dirList[["basicClinical"]],
                                              paste0(diseaseCode, ".csv")))
}

lapply(TCGAcode, processClinicalFirehose)

