# Locate Clinical datasets for each cancer
source("data-raw/helpers.R")
library(TCGAutils)
data(diseaseCodes)

TCGAcodes <- RTCGAToolbox::getFirehoseDatasets()
excludedCodes <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL",
    "LCML", "MISC")
TCGAcodes <- TCGAcodes[-which(TCGAcodes %in% excludedCodes)]

myDataDir <- "data/Clinical"

if (!dir.exists(myDataDir))
    dir.create(myDataDir, recursive = TRUE)

lapply(TCGAcodes, function(cancer) {
    if (!file.exists(file.path(myDataDir, cancer, "clinical.csv"))) {
        clinDat <- RTCGAToolbox::getFirehoseData(dataset = cancer,
            destdir = tempfile())
        clinFrame <- getData(clinDat, "clinical")
        rownames(clinFrame) <- .stdIDs(rownames(clinFrame))

        dir.create(file.path(myDataDir, cancer))

        write.csv(clinFrame, file.path(myDataDir, cancer, "clinical.csv"))
        message(cancer, " clinical data saved.")
    } else {
    message(cancer, " clinical data already exists!")
    }
})

names(TCGAcodes) <- TCGAcodes

clinicalNames <- IRanges::CharacterList(lapply(TCGAcodes, function(cancer) {
    clindat <- read.csv(file.path(myDataDir, cancer, "clinical.csv"),
        row.names = 1L, nrows = 2L)
    names(clindat)
}))

saveRDS(clinicalNames,
    file = "inst/extdata/clinicalColnames.rds", compress = "bzip2")

