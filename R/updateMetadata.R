## Update metadata from data bits
updateInfo <- function(dataElement, cancerCode) {
    dataObject <- dataElement[[1L]]
    assayName <- names(dataElement)
    className <- class(dataObject)
    numberRow <- dim(dataObject)[[1L]]
    numberCol <- dim(dataObject)[[2L]]
    MAEOinfo <- cbind.data.frame(cancerCode, assayName, className, numberRow,
                                 numberCol)
    write.table(MAEOinfo, file = "MAEOinfo.csv", sep = ",",
                append = TRUE, row.names = FALSE, col.names = FALSE)
}
