.BIOCONDUCTOR_BLOB_STORE_URL <- "https://bioconductorhubs.blob.core.windows.net"

#' Upload data to Azure Blob Store
#'
#' The function provides a programmatic interface to data upload using the
#' [`AzureStor`](https://cran.r-project.org/package=AzureStor) package.
#'
#' @param sas `character(1)` The SAS token used for authentication provided by
#'   the Bioconductor Core Team
#'
#' @param url `character(1)` The Azure Blob Store URL; by default, the value of
#'   the internal `.BIOCONDUCTOR_BLOB_STORE_URL` constant is used.
#'
#' @param container `character(1)` The name of the container on Azure
#'
#' @param dataFolder `character(1)` The folder where all data versions are held
#'
#' @param version `character(1)` The sub-folder corresponding to a particular
#'   version of the data, e.g., "v2.1.0"
#'
#' @param file_ext `character(1)` The file extension of files to be uploaded
#'   without the leading dot, e.g., "rda"
#'
#' @param package `character(1)` The name of the package for which data is
#'   uploaded for, this will be the sub-folder within the Azure Blob Store
#'   container.
#'
#' @export
uploadAzure <- function(
    sas, url = .BIOCONDUCTOR_BLOB_STORE_URL, container, files, dataFolder,
    version, file_ext, package
) {
    ep <- storage_endpoint(url, sas = sas)
    stor <- storage_container(ep, container)
    if (missing(files)) {
        src_dir <- file.path(dataFolder, version)
        files <- list.files(
            src_dir, recursive=TRUE, full.names = TRUE, pattern = file_ext
        )
    }
    if (!all(startsWith(files, dataFolder)))
        stop("'files' must start with the 'dataFolder' name")

    up_files <- gsub(paste0(dataFolder, .Platform$file.sep), "", files)
    dest <- file.path(package, up_files)

    stopifnot(
        identical(length(files), length(dest)),
        all(startsWith(dest, package))
    )

    storage_multiupload(container, src=src, dest=dest)
}
