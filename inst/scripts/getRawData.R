## Load libraries
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(TCGAutils)
library(devtools)
library(readr)

setwd("../")
stopifnot(identical(basename(getwd()), "MultiAssayExperiment-TCGA"))
source("R/getDiseaseCodes.R")
source("R/saveRTCGAdata.R")

TCGAcodes <- getDiseaseCodes()
runDate <- "20160128"
analyzeDate <- "20160128"
directory <- "data/raw"

for(code in TCGAcodes)
    saveRTCGAdata(runDate, code, analyzeDate = analyzeDate, directory = directory)
