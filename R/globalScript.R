# Script to run to build all clinical datasets in several folders
## Make sure libraries are installed
source("R/installLibraries.R")

# Allocate all directories in repository
source("R/dataDirectories.R")
dataDirectories(create = TRUE)

## Download all available resources
source("data-raw/downloadClinicalData.R")
source("data-raw/downloadExtraClinical.R")

## Download SubType data from DropBox
source("data-raw/downloadSubtypeDrop.R")
## ALTERNATIVELY: Download files manually and put them in "inst/extdata/allsubtypes"

## Merge curated data to clinical data
source("data-raw/mergeSubtypeCuration.R")

## Clean merged data files
source("data-raw/cleanMerged.R")
