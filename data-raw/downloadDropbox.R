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

source("R/dataDirectories.R")

dirList <- dataDirectories()

## Download all subtype files
invisible(lapply(BoxSubTypes, function(archive) {
    drop_get(archive, local_file = file.path(dirList[["subtypePath"]],
                                             basename(archive)),
             overwrite = TRUE)
}))

invisible(lapply(BoxClinicalCuration, function(archive) {
    drop_get(archive, local_file = file.path(dirList[["clinicalCurationPath"]],
                                             basename(archive)),
             overwrite = TRUE)
}))

## Individual diseaseCode function
getSubtypeFile <- function(diseaseCode, overwrite=TRUE) {
    invisible(BoxSubTypes <-
        rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]])
    subtypePath <- dataDirectories()[["subtypePath"]]
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
    clinicalCurationPath <- dataDirectories()[["clinicalCurationPath"]]
    clinicalFile <-
        BoxClinicalCuration[grepl(paste0("TCGA_Variable_Curation_",
                                         diseaseCode, ".xlsx"),
                                  basename(BoxClinicalCuration))]
    if (rdrop2::drop_get(clinicalFile,
                         local_file = file.path(clinicalCurationPath,
                                                basename(clinicalFile)),
                         overwrite = overwrite))
        message("download successful")
}

## Run brcaMerge to merge BRCA2 to BRCA and remove BRCA2
# source("data-raw/brcaMerge.R")
