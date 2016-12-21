## Script for downloading clinical data without DropBox

## Load vector of TCGA cancer codes
source("data-raw/helpers.R")
source("R/getDiseaseCodes.R")
TCGAcode <- getDiseaseCodes()

processClinicalFirehose <- function(diseaseCode) {
    runDate <- "20151101"
    dirList <- dataDirectories()
# rawRDSdata <- file.path("data", paste0(diseaseCode, ".rds"))
#    basicClinical <- file.path(dirList[["basicClinical"]],
#            paste0(diseaseCode, ".csv"))
#    if (file.exists(rawRDSdata)) {
#        if (file.exists(basicClinical))
#            return(NULL)
#                TCGAdata <- readRDS(rawRDSdata)
#                TCGAclin <- TCGAdata@Clinical
#                rm(TCGAdata)
#    } else {
TCGAclin <- RTCGAToolbox::getFirehoseData(diseaseCode, runDate = runDate,
                                          Clinic = TRUE,
                                          destdir =
                                              dirList[["rawClinical"]])
TCGAclin <- TCGAclin@Clinical
#    }
    stdBarcodes <- .stdIDs(rownames(TCGAclin))
    TCGAclin <- cbind(patientID = stdBarcodes, TCGAclin)
    readr::write_csv(TCGAclin, path=file.path(dirList[["basicClinical"]],
                                              paste0(diseaseCode, ".csv")))
    rm(TCGAclin, stdBarcodes)
}

for (cancer in TCGAcode) {
    processClinicalFirehose(cancer)
}
