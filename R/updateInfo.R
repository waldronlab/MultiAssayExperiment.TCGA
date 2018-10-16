.getElementMetaData <- function(dataElementList, cancerCode) {
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
                list(cancerCode, assayName, className, numberRow, numberCol),
                .Names = colnames,
                row.names = 1L,
                class = "data.frame"
            )
        }, dataElement = dataElementList)
    do.call(rbind.data.frame, listFrame)
}

## Update metadata from data bits
updateInfo <-
function(dataList, cancerCode, filePath = "MAEOinfo.csv", noRows = TRUE)
{
    MAEOinfo <- .getElementMetaData(dataList, cancerCode)
    if (file.exists(filePath)) {
        storedInfo <- read.csv(filePath, stringsAsFactors = FALSE)

        regLines <- storedInfo[["cancerCode"]] %in% cancerCode &
            storedInfo[["assay"]] %in% names(dataList)

        if (any(regLines))
            storedInfo <- storedInfo[!regLines, ]

        MAEOinfo <- rbind.data.frame(storedInfo, MAEOinfo,
            stringsAsFactors = FALSE)
        noRows <- FALSE
    }
    write.table(MAEOinfo, file = filePath, sep = ",",
        append = !noRows, row.names = FALSE, col.names = noRows)
}
