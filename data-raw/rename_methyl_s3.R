library(aws.s3)
## make sure valid token exists
## system("aws sts get-session-token")
ehub <- get_bucket_df("experimenthub", max = 2000)
allMethyls <- grep("curatedTCGAData.*Methylation.*\\.[RrHh][Dd5][Ss]?$",
    ehub[["Key"]], ignore.case = TRUE, value = TRUE)
newMethyls <- gsub("(curatedTCGAData.*Methylation.*)(\\.[Hh][5])$",
    "\\1_assays\\2", allMethyls)
newMethyls <- gsub("(curatedTCGAData.*Methylation.*)(\\.[Rr][Dd][Ss])$",
    "\\1_se\\2", newMethyls)

## test
for (i in seq_along(allMethyls)[-1]) {
    copy_object(from_object = allMethyls[i],
        to_object = newMethyls[i],
        from_bucket = "experimenthub",
        to_bucket = "experimenthub")
    message("Removing file: ", allMethyls[i])
    delete_object(allMethyls[i], "experimenthub", quiet = FALSE)
}

## rename local files to match uploaded scheme
pipefolder <-
    file.path(Sys.getenv("HOME"), "github", "MultiAssayExperiment-TCGA")

setwd(pipefolder)

local_methyls <- list.files(path = "data/bits", full.names = TRUE,
    pattern = "*_Methylation.*[RrHh][Dd5][Ss]?$", recursive = TRUE)
newlocal_methyls <- gsub("(.*Methylation.*)(\\.[Hh][5])$",
    "\\1_assays\\2", local_methyls)
newlocal_methyls <- gsub("(.*Methylation.*)(\\.[Rr][Dd][Ss])$",
    "\\1_se\\2", newlocal_methyls)

file.rename(local_methyls, newlocal_methyls)

