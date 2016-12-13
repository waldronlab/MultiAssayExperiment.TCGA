# Script to run to build all clinical datasets in several folders
## Make sure libraries are installed
## Running from EXEC folder, use .. to go to project dir
setwd("..")

stopifnot(file.exists("R/installLibraries.R"))
source("R/installLibraries.R")

# Allocate all directories in repository
# source("R/dataDirectories.R")
# dataDirectories(create = TRUE)

## Download all available resources
source("data-raw/getClinicalData.R")
source("data-raw/downloadExtraClinical.R")

## Download SubType data from DropBox
# source("data-raw/downloadSubtypeDrop.R")
## ALTERNATIVELY: Download files manually and put them in "inst/extdata/allsubtypes"

## Merge curated data to clinical data
source("data-raw/mergeSubtypeCuration.R")

## Clean merged data files
source("data-raw/cleanMerged.R")

## Build and upload MultiAssayExperiment data
source("R/runPipeline.R")

