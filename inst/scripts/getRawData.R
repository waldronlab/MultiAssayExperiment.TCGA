## Load libraries
library(MultiAssayExperiment)
library(devtools)
library(readr)
library(RTCGAToolbox)
library(TCGAutils)

setwd("../")
stopifnot(identical(basename(getwd()), "MultiAssayExperiment-TCGA"))
source("R/getDiseaseCodes.R")
source("R/saveRTCGAdata.R")

TCGAcodes <- getDiseaseCodes()
runDate <- "20160128"
analyzeDate <- "20160128"
directory <- "data/raw"

lapply(TCGAcodes, saveRTCGAdata, runDate, analyzeDate, directory)

