## Load libraries
library(MultiAssayExperiment)
devtools::load_all()
# library(MultiAssayExperiment.TCGA)
library(RTCGAToolbox)
library(TCGAutils)
library(devtools)
library(readr)

setwd("../")
stopifnot(identical(basename(getwd()), "MultiAssayExperiment.TCGA"))

TCGAcodes <- getDiseaseCodes()
runDate <- "20160128"
analyzeDate <- "20160128"
directory <- "data/raw"

library(BiocParallel)
registered()
params <- MulticoreParam(
    workers = 17, stop.on.error = FALSE, progressbar = TRUE
)
bplapply(X = TCGAcodes, FUN = function(x) {
    saveRTCGAdata(runDate, x, analyzeDate = analyzeDate, directory = directory, force = TRUE)
}, BPPARAM = params)
