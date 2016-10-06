## Script meant to be run interactively

# BiocInstaller::biocLite("karthik/rdrop2")

library(rdrop2)
library(dplyr)

## Authenticate to Dropbox API
drop_auth()

drop_acc() %>% select(uid, display_name, email_verified, quota_info.quota)

BoxSubTypes <- drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]]

if (!file.exists("./inst/extdata/allsubtypes/")) {
    dir.create("./inst/extdata/allsubtypes/", recursive = TRUE)
}

## Download all subtype files
invisible(lapply(BoxSubTypes, function(archive) {
    drop_get(archive, local_file = file.path("./inst/extdata/allsubtypes/",
                                             basename(archive)),
             overwrite = TRUE)
}))

## Run brcaMerge to merge BRCA2 to BRCA and remove BRCA2
souce("data-raw/brcaMerge.R")
