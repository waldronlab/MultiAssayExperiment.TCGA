## Update metadata from data bits
updateInfo <- function(dataElement, cancerCode, filePath = "MAEOinfo.csv") {
    if (!file.exists(filePath)) {
    header <- cbind.data.frame("cancerCode", "assay", "class", "nrow", "ncol")
    write.table(header, file = filePath, sep = ",",
                row.names = FALSE, col.names = FALSE)
    }
    dataObject <- dataElement[[1L]]
    assayName <- names(dataElement)
    stopifnot(S4Vectors::isSingleString(assayName))
    className <- class(dataObject)
    numberRow <- dim(dataObject)[[1L]]
    numberCol <- dim(dataObject)[[2L]]
    MAEOinfo <- cbind.data.frame(cancerCode, assayName, className, numberRow,
                                 numberCol)
    write.table(MAEOinfo, file = filePath, sep = ",",
                append = TRUE, row.names = FALSE, col.names = FALSE)
}
