setwd("../..")
devtools::load_all()
TCGAcodes <- getDiseaseCodes()


lapply(TCGAcodes, function(cancer) {
    maeoFile <- paste0(tolower(cancer), "MAEO.rds")
    location <- "data/built"
    builtMAEO <- file.path(location, maeoFile)
    MultiAssay <- readRDS(builtMAEO)
    updateInfo(MultiAssay, cancer)
})

