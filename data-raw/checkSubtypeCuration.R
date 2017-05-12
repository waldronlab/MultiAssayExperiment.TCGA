## Script to check subtype data against the maps
library(dplyr)
source("data-raw/helpers.R")
load("data/curationAvailable.rda")

## How to figure out which datasets don't have matching columns
## List of lists (each inner list has names in dataset and names that were
## supposed to match)
checkSubtypeCuration <- function(diseaseCode) {
    subtypeMap <- .readSubtypeMap(diseaseCode)
    subtypeData <- .readSubtypeData(diseaseCode)
    targetColumns <- subtypeMap[[2L]]
    if (!all(make.names(targetColumns) %in% colnames(subtypeData))) {
        list(df_names = sort(names(subtypeData)), target_names = sort(
            targetColumns[!targetColumns %in% names(subtypeData)]
        ))
    } else {
        print("Subtype check passed")
    }
}

## See what TCGA disease codes have corrupt barcodes
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

## Find what curated disease don't pass the check
bcodeRes <- vapply(curationAvailable, FUN = function(dx) {
    identical(c(0L, 0L), dim(findCorruptBarcodes(dx)))
}, FUN.VALUE = logical(1L))

which(!bcodeRes)
stopifnot(all(bcodeRes))

