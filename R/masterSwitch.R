# Script to run to build all clinical datasets in several folders
packs <- c("readxl", "readr", "dplyr", "rdrop2", "RTCGAToolbox", "BiocInterfaces")
sapply(packs, library, character.only = TRUE)

# Allocate all directories in repository
source("R/dataDirectories.R")
dataDirectories(create = TRUE)

## Download all available resources
source("data-raw/downloadClinicalData.R")
source("data-raw/downloadExtraClinical.R")

## Download SubType data from DropBox
source("data-raw/downloadSubtypeDrop.R")
## ALTERNATIVELY: Download files manually and put in "inst/extdata/allsubtypes"

## Merge curated data to clinical data
source("data-raw/mergeSubtypeCuration.R")

## Clean merged data files
source("data-raw/cleanMerged.R")
