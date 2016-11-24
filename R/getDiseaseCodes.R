## Function for getting useable barcodes (no RTCGAToolbox dep)
getDiseaseCodes <- function() {
    data("diseaseCodes", package = "BiocInterfaces")
    excludedCodes <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL",
                       "LCML", "MISC")
    logicalSub <- !diseaseCodes[[1L]] %in% excludedCodes
    unname(unlist(diseaseCodes[logicalSub, 1L]))
}
