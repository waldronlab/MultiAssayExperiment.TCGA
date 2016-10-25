### Merging subtype files with clinical data

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
        head(subtypeData, 3)
    } else {
        message(diseaseCode, "barcodes OK")
    }
}

curationAvailable <- gsub(".csv", "", names(dflist), fixed = TRUE)

lapply(curationAvailable, findCorruptBarcodes)

ExtractedColumns$COAD.csv$patient
ExtractedColumns$BLCA.csv$tcgaBarcode
ExtractedColumns$LUSC.csv$Tumor.ID
