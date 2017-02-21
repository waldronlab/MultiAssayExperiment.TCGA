## Load libraries
library(MultiAssayExperiment)
library(devtools)
library(readr)
library(RTCGAToolbox)
library(TCGAutils)

source("R/getDiseaseCodes.R")
TCGAcodes <- getDiseaseCodes()
runDate <- "20160128"
analyzeDate <- "20160128"
directory <- "data"

lapply(TCGAcodes, saveRTCGAdata, runDate, analyzeDate, directory)
