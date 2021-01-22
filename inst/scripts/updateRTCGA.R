# Ensure location
message(getwd())
setwd("..")
stopifnot(identical(getwd(),
    paste0("/home/", Sys.getenv("USER"),
        "/Documents/gh/MultiAssayExperiment-TCGA")))

# Update RTCGAToolbox objects
library(TCGAutils)
data(diseaseCodes)

diseaseCodes <- diseaseCodes[[1L]]

# If subset needs to be run, replace cancer code with last unsuccessful attempt
diseaseCodes <- diseaseCodes[which(diseaseCodes == "LUAD"):length(diseaseCodes)]

foldersCheck <- file.path("data/raw", diseaseCodes)
message("checking in folders:", sprintf("%s, ", foldersCheck))

dataFiles <- list.files(foldersCheck,
    pattern = "*\\.rds$", full.names = TRUE, recursive = FALSE)

dataNames <- vapply(strsplit(basename(dataFiles), "\\."), `[`,
    character(1L), 1L)

names(dataFiles) <- dataNames

folderName <- vapply(strsplit(dataNames, "_"), `[`, character(1L),
    1L)

invisible(lapply(folderName, function(x) {
    folderPath <- file.path("data", "rawold", x)
    if(!dir.exists(folderPath))
    dir.create(file.path("data", "rawold", x))
}))

lapply(seq_along(dataFiles), function(i, file) {
    message("Updating ", names(file[i]))
    dataObj <- RTCGAToolbox::updateObject(readRDS(file[i]))
    readr::write_rds(x = dataObj,
        path = file.path("data/rawold", folderName[i],
            paste0(names(file[i]), ".rds")),
        compress = "bz2")
    rm(dataObj)
}, file = dataFiles)

