### Merging subtype files with clinical data
source("R/dataDirectories.R")
library(dplyr)

## Helper for finding barcode column
.findBarcodeCol <- function(DF) {
    apply(DF, 2, function(column) {
        logicBCode <- grepl("^TCGA", column)
        logicBCode
    }) %>% apply(., 2, all) %>% Filter(isTRUE, .) %>% names
}

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

source("data-raw/readDFList.R")

curationAvailable <- gsub(".csv", "", names(dflist), fixed = TRUE)
curationAvailable <- curationAvailable[!curationAvailable == "BRCA2"]

names(curationAvailable) <- curationAvailable

bcodeRes <- vapply(curationAvailable, FUN = function(dx) {
    identical(c(0L, 0L), dim(findCorruptBarcodes(dx)))
}, FUN.VALUE = logical(1L))

which(!bcodeRes)

stopifnot(all(bcodeRes))

mergeSubtypeClinical <- function(diseaseCode) {
clinicalData <- readr::read_csv(file.path(dataDirectories()[["clinicalData"]],
                                              paste0(diseaseCode, ".csv")))
}
