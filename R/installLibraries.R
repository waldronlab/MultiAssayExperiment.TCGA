## --Interactive--
## Script for installing necessary packages
## Use Bioconductor devel and R devel versions

stopifnot(R.Version()$major == 3 && R.Version()$minor >= 4)

if (!requireNamespace("BiocManager"))
    install.packages("BiocManager")

library(BiocManager)

install(version = "devel")

install(c("devtools", "readxl", "readr", "dplyr", "TCGAutils",
    "AnnotationHubData", "MultiAssayExperiment", "BiocParallel",
    "Biobase", "GenomeInfoDb", "RaggedExperiment"))
install("LiNk-NY/RTCGAToolbox")
install("waldronlab/TCGAutils")
install("karthik/rdrop2")

