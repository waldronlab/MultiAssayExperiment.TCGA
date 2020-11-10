.getElementMetaData <- function(dataElementList, cancer) {
    colnames <- c("cancerCode", "assay", "class", "nrow", "ncol")
    mustNames <- c("colData", "sampleMap", "metadata")
    dataNames <- names(dataElementList)
    mustLogic <- apply(vapply(mustNames, function(x)
        grepl(x, dataNames), logical(length(dataNames))), 1, any)
    dataNames <- dataNames[!mustLogic]
    listFrame <- lapply(dataNames,
        function(elementName, dataElement) {
            dataObject <- dataElement[[elementName]]
            assayName <- elementName
            className <- class(dataObject)
            numberRow <- dim(dataObject)[[1L]]
            numberCol <- dim(dataObject)[[2L]]
            structure(
                list(cancer, assayName, className, numberRow, numberCol),
                .Names = colnames,
                row.names = 1L,
                class = "data.frame"
            )
        }, dataElement = dataElementList)
    do.call(rbind.data.frame, listFrame)
}

#' Update metadata from data bits
#'
#' This functoin takes a list of data objects, cancer code, and a file path
#' to document the metadata in 'filePath'
#'
#' @param dataList A List of experiment data for a MultiAssayExperiment
#' @param cancer A single string indicating the TCGA cancer code
#' @param folderPath A single string pointing to the folder where metadata
#' information for each cancer is to be saved
#'
#' @return Function saves a file in filePath
#'
#' @export
updateInfo <-
    function(dataList, cancer, folderPath)
{
    metafile <- file.path(folderPath, cancer, "metadata.csv")
    MAEOinfo <- .getElementMetaData(dataList, cancer)

    if (file.exists(metafile))
        file.remove(metafile)

    message("Writing to : ", metafile)
    readr::write_csv(MAEOinfo, file = metafile)
}
