## Function for updating metadata from MultiAssayExperiment objects
updateMetaMAE <- function(MAEObject, cancerCode) {
    cancerCodes <- rep(cancerCode, length(experiments(MAEObject)))
    assays <- names(MAEObject)
    classes <- vapply(experiments(MAEObject), class, character(1L))
    nrows <- vapply(experiments(MAEObject), function(exp) dim(exp)[[1L]],
                    integer(1L))
    ncols <- vapply(experiments(MAEObject), function(exp) dim(exp)[[2L]],
                    integer(1L))
    MAEOinfo <- cbind.data.frame(cancerCodes, assays, classes, nrows,
                                 ncols)
    write.table(MAEOinfo, file = "MAEOinfo.csv", sep = ",",
                append = TRUE, row.names = FALSE, col.names = FALSE)
}

