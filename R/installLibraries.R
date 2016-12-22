## --Interactive--
## Script for installing necessary packages
## Use Bioconductor devel and R devel versions

stopifnot(R.Version()$major == 3 && R.Version()$minor >= 4)

source("https://bioconductor.org/biocLite.R")

useDevel()

library(BiocInstaller)
biocLite(c("devtools", "readxl", "readr", "dplyr",
		"AnnotationHubData", "MultiAssayExperiment", "BiocParallel"))
biocLite("LiNk-NY/RTCGAToolbox")
biocLite("waldronlab/BiocInterfaces")
biocLite("karthik/rdrop2")

