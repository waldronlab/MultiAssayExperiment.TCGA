## Script for loading installed packages
## See installLibraries.R for necessary packages
stopifnot(R.Version()$major == 3 && R.Version()$minor >= 4)

install_packages <- function(packageVector) {
    invisible(lapply(packageVector, function(package) {
        packageAvail <- do.call(require, args = list(package))
        if (!packageAvail)
            do.call(install.packages,
                    args = list(package,
                                repos = BiocInstaller::biocinstallRepos()))
    }))
}

packs <- c("readxl", "readr", "dplyr", "devtools", "AnnotationHubData",
           "MultiAssayExperiment", "RTCGAToolbox", "TCGAutils",
           "BiocParallel", "Biobase", "GenomeInfoDb", "RaggedExperiment")

install_packages(packs)
