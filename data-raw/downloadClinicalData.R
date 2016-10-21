# BiocInstaller::biocLite("LiNk-NY/RTCGAToolbox")
library(RTCGAToolbox)
library(readr)
library(BiocInterfaces)

rD <- getFirehoseRunningDates(last = 1)
## 20151101
excludeDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP")
diseases <- getFirehoseDatasets()[!(getFirehoseDatasets() %in% excludeDatasets)]

extData <- "inst/extdata"
clinicalData <- file.path(extData, "Clinical")
rawClinical <- file.path(clinicalData, "raw")
basicClinical <- file.path(clinicalData, "basic")

invisible(lapply(list(clinicalData, rawClinical, basicClinical), function(folder) {
    if (!file.exists(folder))
        dir.create(folder, recursive = TRUE)
}))

getClinicalFirehose <- function(diseaseCode, force = FALSE) {
    runDate <- "20151101"
    extData <- "inst/extdata"
    clinicalData <- file.path(extData, "Clinical")
    rawClinical <- file.path(clinicalData, "raw")
    ClinicalFileName <- paste0(runDate, "-", diseaseCode, "-", "Clinical.txt")
    if (file.exists(file.path(rawClinical, ClinicalFileName)) & !force) {
        message(sQuote(ClinicalFileName), " already exists")
    } else {
        TCGAclin <- getFirehoseData(diseaseCode, runDate=runDate, Clinic = TRUE,
                                    destdir = rawClinical)
    }
}

saveClinicalFirehose <- function(diseaseCode) {
    runDate <- "20151101"
    TCGAclin <- getFirehoseData(diseaseCode, runDate = runDate, Clinic = TRUE,
                                destdir = rawClinical)
    full_TCGAclin <- TCGAclin@Clinical
    full_TCGAclin <- cbind(patientID = rownames(full_TCGAclin), full_TCGAclin)
    write_csv(full_TCGAclin, path=file.path(basicClinical, paste0(diseaseCode, ".csv")))
}
