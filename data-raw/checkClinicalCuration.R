## Function to check curation files for errors

## Helper function stipulation:
## * Column lengths must be the same in "Variables" and "Priority"
.rowToDataFrame <- function(singleRowDF) {
    columnIndex1 <- seq_len(match("priority", tolower(names(singleRowDF)))-1)
    columnIndex2 <- columnIndex1 + rev(columnIndex1)
    data.frame(variable = as.character(singleRowDF[columnIndex1]),
               priority = as.integer(singleRowDF[columnIndex2]),
               stringsAsFactors = FALSE)
}

checkClinicalCuration <- function(diseaseCode) {
    clinicalLocation <- "./inst/extdata/Clinical/"
    clinicalCuration <- "./inst/extdata/TCGA_Curation_Cancer_Types/"
    curatePrefix <- "TCGA_Variable_Curation_"

    stopifnot(S4Vectors::isSingleString(diseaseCode))
    readr::read_csv(file.path(clinicalLocation, paste0(diseaseCode, ".csv")))
    curatedFile <- readxl::read_excel(file.path(clinicalCuration,
                                                paste0(curatePrefix,
                                                       diseaseCode,
                                                       ".xlsx")), na = " ",
                                      sheet = 1L)
    names(curatedFile) <- make.names(names(curatedFile))
    listLines <- split(curatedFile, seq_len(nrow(curatedFile)))

    clinicalData <- readr::read_csv(file.path(clinicalLocation,
                                              paste0(diseaseCode, ".csv")))
    message("Working on ", diseaseCode)
    listDF <- lapply(listLines, .rowToDataFrame)

    listDF <- lapply(listDF, na.omit)
    curatedLinesNames <- unlist(lapply(listDF, function(df) {
        df[["variable"]]
    }))
    curatedLinesNames[!curatedLinesNames %in% names(clinicalData)]
}

excludeDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP")
dxCodes <- RTCGAToolbox::getFirehoseDatasets()
includeDatasets <- dxCodes[!(dxCodes %in% excludeDatasets)]
names(includeDatasets) <- includeDatasets

## Check for errors across all datasets
nonMatchingColumns <- lapply(includeDatasets, checkClinicalCuration)
