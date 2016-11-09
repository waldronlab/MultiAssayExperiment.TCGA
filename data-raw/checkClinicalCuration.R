## Script for checking clinical data curation for any errors
library(BiocInterfaces)
source("R/dataDirectories.R")
source("data-raw/helpers.R")


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

## This function reads in both variable curation and clinical data and checks
## to see what columns in the variable curation are extraneous
checkClinicalCuration <- function(diseaseCode) {
    stopifnot(S4Vectors::isSingleString(diseaseCode))
    message("Working on ", diseaseCode)

    clinicalData <- .readClinical(diseaseCode)
    curatedFile <- .readClinicalCuration(diseaseCode)
    listLines <- split(curatedFile, seq_len(nrow(curatedFile)))

    listDF <- lapply(listLines, .rowToDataFrame)

    listDF <- lapply(listDF, na.omit)
    curatedLinesNames <- unlist(lapply(listDF, function(df) {
        df[["variable"]]
    }))
    curatedLinesNames[!curatedLinesNames %in% names(clinicalData)]
}

data("diseaseCodes")
dxCodes <- diseaseCodes[["Study.Abbreviation"]]
tbxCodes <- getFirehoseDatasets()

dput(setdiff(diseaseCodes[[1L]], tbxCodes))
codesNotInTbx <- c("CNTL", "LCML", "MISC")

dput(setdiff(tbxCodes, diseaseCodes[[1L]]))
codesNotInDxCodes <- c("COADREAD", "GBMLGG", "KIPAN", "STES")

excludeDatasets <- c(codesNotInTbx, codesNotInDxCodes, "FPPP")

includeDatasets <- dxCodes[!(dxCodes %in% excludeDatasets)]
names(includeDatasets) <- includeDatasets

## Check for errors across all datasets
nonMatchingColumns <- lapply(includeDatasets, checkClinicalCuration)

## Check all clinical data names

allPatientIDs <- vapply(includeDatasets, function(disease) {
                            dxData <- .readClinical(disease)
                            "patientID" %in% names(dxData)
               }, FUN.VALUE = logical(1L))

stopifnot(all(allPatientIDs))

