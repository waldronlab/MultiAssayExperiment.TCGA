message(getwd())
repodir <- file.path(Sys.getenv("HOME"), "gh/MultiAssayExperiment.TCGA")
setwd(repodir)

stopifnot(identical(getwd(), repodir))

metas <- list.files(
    "data/bits/v2.0.1", pattern = "metadata.csv", recursive = TRUE, full.names = TRUE
)

do.call(rbind, lapply(metas, read.csv))
