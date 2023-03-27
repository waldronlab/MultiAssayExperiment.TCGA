message(getwd())
repodir <- file.path(Sys.getenv("HOME"), "gh/MultiAssayExperiment.TCGA")
setwd(repodir)

stopifnot(identical(getwd(), repodir))

version <- "2.1.0"
metas <- list.files(
    paste0("data/bits/v", version),
    pattern = "metadata.csv",
    recursive = TRUE, full.names = TRUE
)

do.call(rbind, lapply(metas, read.csv))
