install.packages("devtools", repos = "http://cran.r-project.org")

source("https://bioconductor.org/biocLite.R")
biocLite()

BiocInstaller::biocLite("vjcitn/MultiAssayExperiment", type = "source")
library(MultiAssayExperiment)

BiocInstaller::biocLite("LiNk-NY/RTCGAToolbox")
library(RTCGAToolbox)

BiocInstaller::biocLite("waldronlab/BiocInterfaces")
library(BiocInterfaces)

install.packages("readr", repos = "http://cran.r-project.org")
library(readr)
