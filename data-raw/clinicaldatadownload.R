# BiocInstaller::biocLite("LiNk-NY/RTCGAToolbox")
library(RTCGAToolbox)
library(readr)
library(BiocInterfaces)

rD <- getFirehoseRunningDates(last = 1)
## 20151101

if (!file.exists("./inst/extdata/Clinical")) {
    dir.create("./inst/extdata/Clinical/", recursive = TRUE)
}

excludeDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP")
diseases <- getFirehoseDatasets()[!(getFirehoseDatasets() %in% excludeDatasets)]

TCGAclin <- lapply(diseases,
                   function(dx) {
                       getFirehoseData(dx,
                                       runDate="20151101",
                                       Clinic = TRUE,
                                       destdir = "./inst/extdata/")
                   })
names(TCGAclin) <- diseases

full_TCGAclin <- lapply(TCGAclin, function(dx) { dx@Clinical })

## prevent loss of rownames in data
full_TCGAclin <- lapply(full_TCGAclin,
                        function(cl) {
                            cbind(patientID = rownames(cl), cl)
                        })

lapply(seq_along(full_TCGAclin),
       function(dx, i) {
           write_csv(dx[[i]],
                     path = file.path("./inst/extdata/Clinical/",
                                      paste0(diseases[i], ".csv")))},
       dx = full_TCGAclin)

clin_files <- dir("./inst/extdata/Clinical/", full.names = TRUE)
