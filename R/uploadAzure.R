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
    ep <- AzureStor::storage_endpoint(url, sas = sas)
    stor <- AzureStor::storage_container(ep, container)
    if (missing(files)) {
        src_dir <- file.path(dataFolder, version)
        files <- list.files(
            src_dir, recursive=TRUE, full.names = TRUE, pattern = file_ext
        )
    }
    if (!all(startsWith(files, dataFolder)))
        stop("'files' must start with the 'dataFolder' name")

    dfiles <- basename(files)
    destfiles <- file.path(package, version, dfiles)
    message("Uploading to ", file.path(container, package), " folder")
    old_opt <- options(azure_storage_progress_bar = TRUE)
    on.exit(options(old_opt))

    stopifnot(
        identical(length(files), length(destfiles)),
        all(startsWith(destfiles, package)),
        all(file.exists(files))
    )

    AzureStor::storage_multiupload(
        container = stor, src = files, dest = destfiles
    )
}
