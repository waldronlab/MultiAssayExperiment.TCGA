## Get function for downloading
source("inst/scripts/downloadDropbox.R")

## Authenticate to Dropbox API at FIRST RUN
# drop_auth()
# drop_acc() %>% select(uid, display_name, email_verified, quota_info.quota)

BoxSubTypes <- rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]]
downloadDropbox(BoxSubTypes, TCGAcode=TCGAcode, dirList=dirList)
