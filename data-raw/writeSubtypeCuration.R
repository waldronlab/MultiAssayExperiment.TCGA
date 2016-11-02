## Code to subset relevant columns (dflist needs barcode column)
source("data-raw/checkSubtypeCuration.R")
source("R/dataDirectories.R")

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
              path = file.path(dataDirectories()[["curatedSubtypes"]],
                               paste0(diseaseCode, "_subtypes.csv")))
}
