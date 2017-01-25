## --Interactive--
## Script for installing necessary packages
## Use Bioconductor devel and R devel versions

stopifnot(R.Version()$major == 3 && R.Version()$minor >= 4)

source("https://bioconductor.org/biocLite.R")

useDevel()

library(BiocInstaller)
biocLite(c("devtools", "readxl", "readr", "dplyr",
		"AnnotationHubData", "MultiAssayExperiment", "BiocParallel",
        "Biobase", "GenomeInfoDb"))
biocLite("LiNk-NY/RTCGAToolbox")
biocLite("waldronlab/TCGAutils")
biocLite("karthik/rdrop2")

stopifnot(!package_version(Biobase::package.version("TCGAutils")) >=
                            package_version("0.1.3"))

