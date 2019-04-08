## Load libraries
library(MultiAssayExperiment)
library(MultiAssayExperiment.TCGA)
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

for(code in TCGAcodes)
    saveRTCGAdata(runDate, code, analyzeDate = analyzeDate, directory = directory)
