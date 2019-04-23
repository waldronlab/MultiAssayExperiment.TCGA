library(DelayedArray)
library(HDF5Array)

pipefolder <-
    file.path(Sys.getenv("HOME"), "github", "MultiAssayExperiment-TCGA")

setwd(pipefolder)

local_rds <- list.files(path = "data/bits", full.names = TRUE,
    pattern = "*_Methylation.*[Rr][Dd][Ss]$", recursive = TRUE)[-c(1, 2)]
local_h5 <- list.files(path = "data/bits", full.names = TRUE,
    pattern = "*_Methylation.*[Hh]5$", recursive = TRUE)[-c(1, 2)]


for (j in seq_along(local_rds)) {
    se <- readRDS(seFile[j])
    assays <- assays(se)
    nassay <- length(assays)
    for (i in seq_len(nassay)) {
        assays[[i]] <- modify_seeds(assays[[i]], function(x) {
            x@filepath <- local_h5[j]
            x
        })
    }
    assays(se) <- assays
    message("Working on : ", seFile)
    HDF5Array::saveHDF5SummarizedExperiment(
        x = se,
        dir = dirname(seFile[j]),
        prefix = paste0(basename(dirname(seFile[j])), "_"),
        replace = TRUE
    )
}
