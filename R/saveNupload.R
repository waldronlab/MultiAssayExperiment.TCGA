.saveMethylHDF5 <- function(objName, foldername) {
    stopifnot(length(foldername) == 1L)
    methylexts <- c("_assays.h5", "_se.rds")
    HDF5Array::saveHDF5SummarizedExperiment(
        x = get(objName, parent.frame()),
        dir = foldername,
        prefix = paste0(objName, "_"), replace = TRUE
    )
    file.path(foldername, paste0(objName, methylexts))
}


#' A function to save serialized objects and upload to ExperimentHub
#'
#' This function requires the user to obtain AWS CLI credentials to
#' ExperimentHub for it to work.
#'
#' @inheritParams updateInfo
#'
#' @inheritParams buildMultiAssayExperiments
#'
#' @param directory The file location for saving serialized data pieces
#'
#' @param upload logical(1) Whether to upload the data to the AWS S3 bucket
#'
#' @param fileExt character(1) The character pattern for matching files in
#' the directory location for upload (excludes 'Methylation' datasets which
#' are handled separately)
#'
#' @return Function saves and uploads data to the ExperimentHub AWS S3 bucket
#'
#' @export
saveNupload <-
    function(
        dataList, cancer, directory, version, upload, fileExt = ".rda"
    )
{
    if (missing(version))
        stop("Provide a valid version folder for current run")

    version <- paste0("v", version)
    directory <- file.path(directory, version)
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
            AnnotationHubData:::upload_to_S3(
                file = fnames,
                remotename = basename(fnames),
                bucket = file.path("experimenthub/curatedTCGAData", version)
            )
    }
}

## TODO:
## compare sync'd resources with created ones and only send off only those
## that are new based on md5sum

