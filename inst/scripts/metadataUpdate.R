## Load libraries
source("R/loadLibraries.R")
## Get TCGA cancer codes
source("R/getDiseaseCodes.R")
## Source updateInfo function
source("R/updateInfo.R")

TCGAcodes <- getDiseaseCodes()

header <- cbind.data.frame("cancerCode", "assay", "class", "nrow", "ncol")
write.table(header, file = "MAEOinfo.csv", sep = ",",
            row.names = FALSE, col.names = FALSE)

lapply(TCGAcodes, function(cancer) {
    maeoFile <- paste0(tolower(cancer), "MAEO.rds")
    location <- "data/built"
    builtMAEO <- file.path(location, maeoFile)
    MultiAssay <- readRDS(builtMAEO)
    updateInfo(MultiAssay, cancer)
})

