## Script meant to be run interactively

BiocInstaller::biocLite("karthik/rdrop2")

library(rdrop2)
library(dplyr)

## Authenticate to Dropbox API
drop_auth()

drop_acc() %>% select(uid, display_name, email_verified, quota_info.quota)

BoxSubTypes <- drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]]

lapply(BoxSubTypes, function(archive) {
    drop_get(archive, local_file = file.path("./inst/extdata/allsubtypes/",
                                             basename(archive)))
})
