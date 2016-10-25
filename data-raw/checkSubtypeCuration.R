## Script to check subtype data against the maps

.readSubtypeMap <- function(diseaseCode) {
    subtypeMapFile <- file.path(dataDirectories()$curatedMaps,
                                paste0(diseaseCode, "_SubtypeMap.csv"))
    readr::read_csv(subtypeMapFile)
}

.readSubtypeData <- function(diseaseCode) {
    subtypeDataFile <- file.path(dataDirectories()$curatedSubtypes,
                                 paste0(diseaseCode, "_subtypes.csv"))
    readr::read_csv(subtypeDataFile)
}

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
