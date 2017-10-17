## Script for downloading clinical data without DropBox

## Load vector of TCGA cancer codes
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcode <- getDiseaseCodes()

processClinicalFirehose <- function(diseaseCode, runDate = "20160128", force = FALSE) {
    dirList <- dataDirectories()
    rawClinical <- dirList[["rawClinical"]]
    file.path(rawClinical, paste(runDate, diseaseCode, "Clinical.txt", sep = "-"))
    fileName <- file.path(rawClinical, paste0(diseaseCode, ".csv"))
    if (!file.exists(fileName) || force) {
        TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode,
                                                  runDate = runDate,
                                                  clinical = TRUE,
                                                  destdir =
                                                      dirList[["rawClinical"]])
        TCGAclin <- selectType(TCGAclin, "clinical")
        stdBarcodes <- .stdIDs(rownames(TCGAclin))
        TCGAclin <- cbind(patientID = stdBarcodes, TCGAclin)
        newFile <- file.path(dirList[["basicClinical"]],
                             paste(runDate, paste0(diseaseCode, ".csv"), sep = "-"))
        readr::write_csv(TCGAclin, path = newFile)
        rm(TCGAclin, stdBarcodes)
    } else { message(fileName, " already downloaded and processed") }
}

BiocParallel::bplapply(TCGAcode, processClinicalFirehose)

