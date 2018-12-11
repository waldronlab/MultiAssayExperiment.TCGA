# removing old methylation datasets
pipefolder <-
    file.path(Sys.getenv("HOME"), "github", "MultiAssayExperiment-TCGA")
setwd(pipefolder)
old_methyl_files <- list.files(path = "data/bits", full.names = TRUE,
    pattern = "*_Methylation.*[Rr][Dd][Aa]", recursive = TRUE)
renamed_methyl_files <- file.path(basename(dirname(old_methyl_files)),
    basename(old_methyl_files))

## move files to "data/old" folder
file.rename(
    from = old_methyl_files,
    to = file.path("data/old", renamed_methyl_files)
)

## explore all new methylation datasets
files <- list.files(path = "data/bits", pattern = "Methylation", include.dirs = TRUE,
    recursive = TRUE, full.names = TRUE)
isdirs <- dir.exists(files)
alldirs <- files[isdirs]

unlist(lapply(alldirs, list.files))

