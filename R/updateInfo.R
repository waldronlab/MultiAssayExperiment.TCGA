## Update metadata from data bits
updateInfo <- function(dataElement, cancerCode, filePath = "MAEOinfo.csv") {
    colnames <- c("cancerCode", "assay", "class", "nrow", "ncol")
    if (!file.exists(filePath)) {
        MAEOinfo <- structure(
            vector("list", length(colnames)),
            .Names = colnames,
            class = "data.frame"
        )
    } else {
        MAEOinfo <- read.csv(filePath, stringsAsFactors = FALSE)
    }
    dataObject <- dataElement[[1L]]
    assayName <- names(dataElement)
    stopifnot(S4Vectors::isSingleString(assayName))
    className <- class(dataObject)
    numberRow <- dim(dataObject)[[1L]]
    numberCol <- dim(dataObject)[[2L]]
    newRow <- structure(
        list(cancerCode, assayName, className, numberRow, numberCol),
        .Names = colnames, row.names = 1L, class = "data.frame")

    oldRow <- MAEOinfo[["assay"]] == assayName
    if (any(oldRow))
        MAEOinfo[oldRow, ] <- newRow
    else
        MAEOinfo <- rbind.data.frame(MAEOinfo, newRow,
            stringsAsFactors = FALSE)

    write.table(MAEOinfo, file = filePath, sep = ",",
                append = TRUE, row.names = FALSE, col.names = FALSE)
}
