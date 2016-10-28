# BiocInstaller::biocLite("LiNk-NY/RTCGAToolbox")
library(RTCGAToolbox)
library(readr)
library(BiocInterfaces)

rD <- getFirehoseRunningDates(last = 1)
## 20151101
excludeDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP")
diseases <- getFirehoseDatasets()[!(getFirehoseDatasets() %in% excludeDatasets)]


getClinicalFirehose <- function(diseaseCode, force = FALSE) {
    runDate <- "20151101"
    dirList <- dataDirectories()
    ClinicalFileName <- paste0(runDate, "-", diseaseCode, "-", "Clinical.txt")
    if (file.exists(file.path(dirList[["rawClinical"]], ClinicalFileName)) &
        !force) {
        message(sQuote(ClinicalFileName), " already exists")
    } else {
        TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode, runDate=runDate,
                                                  Clinic = TRUE,
                                                  destdir =
                                                      dirList[["rawClinical"]])
    }
}

saveClinicalFirehose <- function(diseaseCode) {
    runDate <- "20151101"
    dirList <- dataDirectories()
    TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode, runDate = runDate, Clinic = TRUE,
                                              destdir = dirList[["rawClinical"]])
    full_TCGAclin <- TCGAclin@Clinical
    stdBarcodes <- .stdIDs(rownames(full_TCGAclin))
    full_TCGAclin <- cbind(patientID = stdBarcodes, full_TCGAclin)
    readr::write_csv(full_TCGAclin, path=file.path(dirList[["basicClinical"]],
                                                   paste0(diseaseCode, ".csv")))
}
