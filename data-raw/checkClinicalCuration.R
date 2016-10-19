## Script for checking clinical data curation for any errors

## Helper function for reading clinical variable curation files
.readClinicalCuration <- function(diseaseCode) {
    clinicalCuration <- "./inst/extdata/TCGA_Clinical_Curation/"
    curatePrefix <- "TCGA_Variable_Curation_"
    stopifnot(S4Vectors::isSingleString(diseaseCode))
    curatedFile <- readxl::read_excel(file.path(clinicalCuration,
                                                paste0(curatePrefix,
                                                       diseaseCode,
                                                       ".xlsx")), na = " ",
                                      sheet = 1L)
    names(curatedFile) <- make.names(names(curatedFile))
    curatedFile
}

## Function to check for curation file errors
curateCuration <- function(diseaseCode) {
    curatedFile <- .readClinicalCuration(diseaseCode = diseaseCode)

    listLines <- split(curatedFile, seq_len(nrow(curatedFile)))
    logiList <- lapply(listLines, function(singleRowDF) {
        priorityIndex <- match("priority", tolower(names(singleRowDF)))
        stopifnot(!is.na(priorityIndex), length(priorityIndex) == 1L,
                  priorityIndex != 0L)
        columnRange1 <- seq_len(priorityIndex-1)
        columnRange2 <- priorityIndex:length(singleRowDF)
        length(singleRowDF[columnRange1]) == length(singleRowDF[columnRange2])
    })
    all(unlist(logiList))
}

## Helper function stipulation:
## * Column lengths must be the same in "Variables" and "Priority"
.rowToDataFrame <- function(singleRowDF) {
    priorityIndex <- match("priority", tolower(names(singleRowDF)))
    stopifnot(!is.na(priorityIndex), length(priorityIndex) == 1L,
              priorityIndex != 0L)
    columnRange1 <- seq_len(priorityIndex-1)
    columnRange2 <- columnRange1 + rev(columnRange1)
    data.frame(variable = as.character(singleRowDF[columnRange1]),
               priority = as.integer(singleRowDF[columnRange2]),
               stringsAsFactors = FALSE)
}

## This function reads in both variable curation and clinical data and checks
## to see what columns in the variable curation are extraneous
checkClinicalCuration <- function(diseaseCode) {
    stopifnot(S4Vectors::isSingleString(diseaseCode))

    clinicalLocation <- "./inst/extdata/Clinical/"
    clinicalData <- readr::read_csv(file.path(clinicalLocation,
                                              paste0(diseaseCode, ".csv")))

    curatedFile <- .readClinicalCuration(diseaseCode = diseaseCode)

    listLines <- split(curatedFile, seq_len(nrow(curatedFile)))

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
