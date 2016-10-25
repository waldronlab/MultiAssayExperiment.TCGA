## Code to subset relevant columns (dflist needs barcode column)
source("data-raw/checkSubtypeCuration.R")

.extractCurationColumns <- function(diseaseCode) {
    subtypeMap <- .readSubtypeMap(diseaseCode)
    subtypeData <- .readSubtypeData(diseaseCode)
    targetColumns <- make.names(subtypeMap[[2L]])
    stopifnot(all(targetColumns %in% names(subtypeData)))
    subtypeData[, targetColumns, drop = FALSE]
}

## Save each subtype information to its own file
## Create all curated subtype CSV files
writeSubtypeCuration <- function(diseaseCode) {
    extractedCols <- .extractCurationColumns(diseaseCode)
    write_csv(x = extractedCols,
              path = file.path(dataDirectories()$curatedSubtypes,
                               paste0(diseaseCode, "_subtypes.csv")))
}

.findBarcodeCol <- function(DF) {
    apply(DF, 2, function(column) {
        logicBCode <- grepl("^TCGA", column)
        logicBCode
    }) %>% apply(., 2, all) %>% Filter(isTRUE, .) %>% names
}

ExtractedColumns <- lapply(ExtractedColumns, function(disease) {
    bcode <- .findBarcodeCol(disease)
    if (length(bcode)) {
        disease[[bcode]] <- .stdIDs(disease[[bcode]])
    }
    disease
})

## See what files have corrupt barcodes
lapply(ExtractedColumns, .findBarcodeCol) %>% Filter(function(x) !length(x), .) %>%
    names()

ExtractedColumns$COAD.csv$patient
ExtractedColumns$BLCA.csv$tcgaBarcode
ExtractedColumns$LUSC.csv$Tumor.ID

