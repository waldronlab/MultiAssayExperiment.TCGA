## Get function for downloading
source("R/downloadDropbox.R")

## Authenticate to Dropbox API at FIRST RUN
# drop_auth()
# drop_acc() %>% select(uid, display_name, email_verified, quota_info.quota)

BoxClinicalData <- rdrop2::drop_dir("The Cancer Genome Atlas/Clinical/data")[["path"]]
downloadDropbox(BoxClinicalData, TCGAcode=TCGAcode, dirList=dirList)
