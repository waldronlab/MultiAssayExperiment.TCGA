
pipefolder <-
    file.path(Sys.getenv("HOME"), "github", "MultiAssayExperiment-TCGA")
setwd(pipefolder)

list.files(path = "data/bits", full.names = TRUE,
    pattern = "[A-Za-z]\\.[RrHh][Dd5][AaSs]?$", recursive = TRUE)

