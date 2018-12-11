.saveMethylHDF5 <- function(objName, foldername) {
    stopifnot(length(foldername) == 1L)
    methylexts <- c("_assays.h5", "_se.rds")
    HDF5Array::saveHDF5SummarizedExperiment(
        x = get(objName, parent.frame()),
        dir = file.path(foldername, objName),
        prefix = paste0(objName, "_"), replace = TRUE
    )
    file.path(foldername, objName, methylexts)
}

saveNupload <- function(dataList, cancer, directory = "data/bits",
    upload = TRUE, fileExt = ".rda") {
    cancerSubdir <- file.path(directory, cancer)
    if (!dir.exists(cancerSubdir))
        dir.create(cancerSubdir, recursive = TRUE)
    dataNames <- names(dataList)
    stopifnot(!is.null(dataNames))
    for (objname in dataNames) {
        assign(x = objname, value = dataList[[objname]])
        if (grepl("Methyl", objname, ignore.case = TRUE)) {
            mfolder <- file.path(cancerSubdir, objname)
            fnames <- .saveMethylHDF5(objname, mfolder)
        } else {
            fnames <- file.path(cancerSubdir, paste0(objname, fileExt))
            save(list = objname, file = fnames, compress = "bzip2")
        }
        if (upload)
            AnnotationHubData:::upload_to_S3(file = fnames,
                remotename = basename(fnames),
                bucket = "experimenthub/curatedTCGAData")
    }
}
