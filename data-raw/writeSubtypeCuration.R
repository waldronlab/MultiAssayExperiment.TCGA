## Code to subset relevant columns (dflist needs barcode column)
source("data-raw/checkSubtypeCuration.R")
source("data-raw/helpers.R")


## Save each subtype information to its own file
## Create all curated subtype CSV files
writeSubtypeCuration <- function(diseaseCode) {
    extractedCols <- .extractCurationColumns(diseaseCode)
    write_csv(x = extractedCols,
              path = file.path(dataDirectories()[["curatedSubtypes"]],
                               paste0(diseaseCode, "_subtypes.csv")))
}
