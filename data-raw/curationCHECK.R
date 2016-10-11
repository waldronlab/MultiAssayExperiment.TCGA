## Function to check curation files for errors

checkClinicalCuration <- function(diseaseCode) {
    clinicalLocation <- "./inst/extdata/Clinical/"
    clinicalCuration <- "./inst/extdata/TCGA_Curation_Cancer_Types/"
    curatePrefix <- "TCGA_Variable_Curation_"

    stopifnot(S4Vectors::isSingleString(diseaseCode))
    readr::read_csv(file.path(clinicalLocation, paste0(diseaseCode, ".csv")))
    curatedFile <- readxl::read_excel(file.path(clinicalCuration, paste0(curatePrefix,
                                                                         diseaseCode,
                                                                         ".xlsx")), na = " ",
                                      sheet = 1L)
    names(curatedFile) <- make.names(names(curatedFile))

    clinicalData <- readr::read_csv(file.path(clinicalLocation, paste0(diseaseCode, ".csv")))

    rowToDataFrame <- function(DataFrame) {
        columnIndex <- seq_len(which(names(DataFrame) == "Priority")-1)
        dplyr::data_frame(variable = as.character(DataFrame[columnIndex]),
                          priority = as.character(DataFrame[-columnIndex]))
    }

    listDF <- apply(curatedFile, 1, rowToDataFrame)

    listDF <- lapply(listDF, na.omit)
    curatedLinesNames <- unlist(lapply(listDF, function(df) {
        df[["variable"]]
    }))

    curatedLinesNames[!curatedLinesNames %in% names(clinicalData)]
}
