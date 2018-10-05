.saveMethylHDF5 <- function(objname, filepaths) {
    folder <- unique(dirname(filepaths))
    stopifnot(length(folder) == 1L)
    h5exts <- c("assays.h5", "se.rds")
    HDF5Array::saveHDF5SummarizedExperiment(
        x = get(objname, parent.frame()), dir = folder, replace = TRUE)
    file.rename(file.path(folder, h5exts), filepaths)
    filepaths
}

saveNupload <- function(dataList, cancer, directory = "data/bits",
    upload = TRUE) {
    cancerSubdir <- file.path(directory, cancer)
    if (!dir.exists(cancerSubdir))
        dir.create(cancerSubdir, recursive = TRUE)
    filetype <- ".rda"
    methylext <- c(".h5", ".rds")
    dataNames <- names(dataList)
    stopifnot(!is.null(dataNames))
    for (objname in dataNames) {
        assign(x = objname, value = dataList[[objname]])
        if (grepl("Methyl", objname, ignore.case = TRUE)) {
            mfolder <- file.path(cancerSubdir, objname)
            filenames <- file.path(mfolder, paste0(objname, methylext))
            fnames <- .saveMethylHDF5(objname, filenames)
        } else {
            fnames <- file.path(cancerSubdir, paste0(objname, filetype))
            save(list = objname, file = fnames, compress = "bzip2")
        }
        if (upload)
            AnnotationHubData:::upload_to_S3(file = fnames,
                remotename = basename(fnames),
                bucket = "experimenthub/curatedTCGAData")
    }
}
