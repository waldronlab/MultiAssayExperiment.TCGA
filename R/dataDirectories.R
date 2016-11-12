dataDirectories <- function(create=FALSE) {
    extData <- "inst/extdata/"
    clinicalData <- file.path(extData, "Clinical")
    directories <- list(
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
                        basicClinical = file.path(clinicalData, "basic"),
                        enhancedClinical = file.path(clinicalData, "enhanced"),
                        mergedClinical = file.path(clinicalData, "merged")
                        )
    if (create) {
        invisible(lapply(directories,
                         function(folder) {
                             if (!file.exists(folder))
                                 dir.create(folder, recursive = TRUE)
                         }))
    }
    return(directories)
}
