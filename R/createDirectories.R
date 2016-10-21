createDirectories <- function() {
        extData <- "inst/extdata/"
        clinicalData <- file.path(extData, "Clinical")
    directories <- list(
        curatedSubtypes = file.path(extData, "curatedSubtypes"),
        subtypePath = file.path(extData, "allsubtypes"),
        clinicalCurationPath = file.path(extData, "TCGA_Clinical_Curation"),
        rawClinical = file.path(clinicalData, "raw"),
        basicClinical = file.path(clinicalData, "basic")
    )
    directories <- c(extData = extData,
                       clinicalData = clinicalData,
                       directories)
    invisible(lapply(directories,
                     function(folder) {
                         if (!file.exists(folder))
                             dir.create(folder, recursive = TRUE)
                     }))
    return(directories)
}

