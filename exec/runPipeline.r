#!/usr/bin/R

## Script for installing necessary packages
## Use Bioconductor devel and R devel versions
stopifnot(R.Version()$major == 3 && R.Version()$minor >= 3)
source("https://bioconductor.org/biocLite.R")
library(BiocInstaller)
useDevel()
biocLite("vjcitn/MultiAssayExperiment")
biocLite("LiNk-NY/RTCGAToolbox")
biocLite("waldronlab/BiocInterfaces")
biocLite("karthik/rdrop2")

install_packages <- function(packageVector) {
    invisible(lapply(packageVector, function(package) {
        packageAvail <- do.call(require, args = list(package))
        if (!packageAvail)
            do.call(install.packages,
                    args = list(package,
                                repos = BiocInstaller::biocinstallRepos()))
    }))
}

packs <- c("devtools", "readxl", "readr", "dplyr", "AnnotationHubData")
install_packages(packs)
