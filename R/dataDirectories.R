#' Create necessary folders for pipeline
#'
#' This convenience function automatically creates directories needed
#' for file processing in the pipeline.
#'
#' @param create logical (default FALSE) Whether to create folders in
#' current package directory
#'
#' @return A character vector of created directories
#' @export
dataDirectories <- function(create=FALSE) {
    extData <- "inst/extdata/"
    clinicalData <- file.path(extData, "Clinical")
    directories <- IRanges::CharacterList(
        extData = extData,
        clinicalData = clinicalData,
        curatedSubtypes =
            file.path(extData, "curatedSubtypes"),
        curatedMaps = file.path(extData, "curatedSubtypes",
                                "curatedMaps"),
        subtypePath = file.path(extData, "allsubtypes"),
        clinicalCurationPath =
            file.path(extData, "TCGA_Clinical_Curation"),
        rawClinical = file.path(clinicalData, "raw"),
        basicClinical = file.path(clinicalData, "basic"), enhancedClinical = file.path(clinicalData, "enhanced"),
        mergedClinical = file.path(clinicalData, "merged")
    )
    if (create) {
    message("Creating 'inst' directory in ", getwd())
        invisible(lapply(directories,
            function(folder) {
                if (!file.exists(folder))
                    dir.create(folder, recursive = TRUE)
            }
        ))
    }
    return(directories)
}
