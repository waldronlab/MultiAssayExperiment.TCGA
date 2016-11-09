### Merging subtype files with clinical data
library(dplyr)

source("R/dataDirectories.R")
source("data-raw/checkSubtypeCuration.R")
source("data-raw/helpers.R")
## Load available cancer codes
source("data-raw/diseaseCodes.R")

curateBarcodes <- function(diseaseCode) {
    subtypeData <- .readSubtypeData(diseaseCode)
    bcode <- .findBarcodeCol(subtypeData)
    if (length(bcode)) {
        subtypeData[[bcode]] <- .stdIDs(subtypeData[[bcode]])
    }
    subtypeData
}

## See what files have corrupt barcodes
findCorruptBarcodes <- function(diseaseCode) {
    subtypeData <- .readSubtypeData(diseaseCode)
    bcode <- .findBarcodeCol(subtypeData)
    if (!length(bcode)) {
        message("No barcode column found")
        return(head(subtypeData, 3))
    } else {
        message(diseaseCode, " barcodes OK")
    }
    return(dplyr::data_frame())
}


bcodeRes <- vapply(curationAvailable, FUN = function(dx) {
    identical(c(0L, 0L), dim(findCorruptBarcodes(dx)))
}, FUN.VALUE = logical(1L))

which(!bcodeRes)
stopifnot(all(bcodeRes))

## Save final merged datasets
writeMergedClinical <- function(diseaseCode, curationAvailable) {
    mergedData <- .mergeSubtypeClinical(diseaseCode, curationAvailable)
    mergedLocation <- "inst/extdata/Clinical/merged"
    write_csv(x = mergedData,
        path = file.path(mergedLocation, paste0(diseaseCode, "_merged.csv")))
}

lapply(includeDatasets, writeMergedClinical,
       curationAvailable=curationAvailable)
