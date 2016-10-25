## Code to subset relevant columns (dflist needs barcode column)
ExtractedColumns <- mapply(function(dfs, annotes) {
    targetColumns <- make.names(annotes[[2]])
    if (!all(targetColumns %in% names(dfs)))
        warning(names(annotes), " don't match")
    return(dfs[, targetColumns])
}, dfs = subtypes, annotes = dflist, SIMPLIFY = FALSE)

## Save each subtype information to its own file
## Create all curated subtype CSV files
invisible(lapply(seq_along(ExtractedColumns), function(i, disease, data) {
    write_csv(x = data[[i]],
              path = file.path("inst", "extdata", "curatedSubtypes",
                               paste0(disease[[i]], "_subtypes.csv")))
}, disease = gsub(".csv", "", names(ExtractedColumns)),
data = ExtractedColumns))

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

