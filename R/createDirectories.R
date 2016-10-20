createDirectories <- function() {
    directories <- list(
        extData = "inst/extdata/",
        curatedSubtypes = file.path(extData, "curatedSubtypes"),
        subtypePath = file.path(extData, "allsubtypes"),
        clinicalData = file.path(extData, "Clinical"),
        clinicalCurationPath <- file.path(extData, "TCGA_Clinical_Curation"),
        rawClinical = file.path(clinicalData, "raw"),
        basicClinical = file.path(clinicalData, "basic")
    )
    invisible(lapply(list(directories), function(folder) {
        if (!file.exists(folder))
            dir.create(folder, recursive = TRUE)
    }))
    return(directories)
}
