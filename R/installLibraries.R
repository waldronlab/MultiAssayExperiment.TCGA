## Script for installing necessary packages
## Use Bioconductor devel and R devel versions

stopifnot(R.Version()$major == 3 && R.Version()$minor >= 4)
# source("https://bioconductor.org/biocLite.R")
# useDevel()
# BiocInstaller::biocLite("devtools")
# BiocInstaller::biocLite("LiNk-NY/RTCGAToolbox")
# BiocInstaller::biocLite("waldronlab/BiocInterfaces")
# BiocInstaller::biocLite("karthik/rdrop2")

install_packages <- function(packageVector) {
    invisible(lapply(packageVector, function(package) {
        packageAvail <- do.call(require, args = list(package))
        if (!packageAvail)
            do.call(install.packages,
                    args = list(package,
                                repos = BiocInstaller::biocinstallRepos()))
    }))
}

packs <- c("readxl", "readr", "dplyr", "AnnotationHubData",
    "MultiAssayExperiment", "RTCGAToolbox", "BiocInterfaces")
install_packages(packs)

