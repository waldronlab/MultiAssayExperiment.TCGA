## Script meant to be run interactively

# BiocInstaller::biocLite("karthik/rdrop2")

library(rdrop2)
library(dplyr)

## Authenticate to Dropbox API
drop_auth()

drop_acc() %>% select(uid, display_name, email_verified, quota_info.quota)

BoxSubTypes <- rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]]
BoxClinicalData <- rdrop2::drop_dir("The Cancer Genome Atlas/Clinical/data")[["path"]]
BoxClinicalCuration <- rdrop2::drop_dir("The Cancer Genome Atlas/TCGA_Clinical_Curation")[["path"]]

extData <- "./inst/extdata/"
subtypePath <- "allsubtypes"
# clinicalDataPath <- "Clinical" ## download using downloadClinicalData.R file
clinicalCurationPath <- "TCGA_Clinical_Curation"

## Build folders
invisible(lapply(list(subtypePath, clinicalDataPath, clinicalCurationPath),
                 function(folder, basefolder) {
                     if (!file.exists(file.path(basefolder, folder))) {
                         dir.create(file.path(basefolder, folder),
                                    recursive = TRUE)
                     }
                 }, basefolder = extData))

## Download all subtype files
invisible(lapply(BoxSubTypes, function(archive) {
    drop_get(archive, local_file = file.path(subtypePath, basename(archive)),
             overwrite = TRUE)
}))

invisible(lapply(BoxClinicalCuration, function(archive) {
    drop_get(archive, local_file = file.path(clinicalPath,
                                             basename(archive)),
             overwrite = TRUE)
}))

## Individual diseaseCode function
getSubtypeFile <- function(diseaseCode, overwrite=TRUE) {
    invisible(BoxSubTypes <-
        rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]])
    subtypePath <- file.path(".", "inst", "extdata", "allsubtypes")
    subtypeFile <- BoxSubTypes[grepl(paste0(diseaseCode, ".csv"),
                                     basename(BoxSubTypes), fixed = TRUE)]
    if (rdrop2::drop_get(subtypeFile, local_file =
                         file.path(subtypePath, basename(subtypeFile)),
                     overwrite = overwrite))
        message("download successful")
}

## Individual diseaseCode function
getClinicalFile <- function(diseaseCode, overwrite=TRUE) {
    invisible(BoxClinicalCuration <-
        drop_dir("The Cancer Genome Atlas/TCGA_Clinical_Curation")[["path"]])
    clinicalPath <- file.path(".", "inst", "extdata", "TCGA_Clinical_Curation")
    clinicalFile <-
        BoxClinicalCuration[grepl(paste0("TCGA_Variable_Curation_",
                                         diseaseCode, ".xlsx"),
                                  basename(BoxClinicalCuration))]
    if (rdrop2::drop_get(clinicalFile,
                         local_file = file.path(clinicalPath,
                                                basename(clinicalFile)),
                         overwrite = overwrite))
        message("download successful")
}

## Run brcaMerge to merge BRCA2 to BRCA and remove BRCA2
source("data-raw/brcaMerge.R")
