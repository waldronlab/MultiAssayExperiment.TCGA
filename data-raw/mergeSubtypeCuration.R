### Merging subtype files with clinical data

## Load available cancer codes
load("data/curationAvailable.rda")

## Save final merged datasets
writeMergedClinical <- function(diseaseCode, curationAvailable) {
    dirList <- dataDirectories()
    mergedClinical <- dirList[["mergedClinical"]]
    fileName <- file.path(mergedClinical,
                          paste0(diseaseCode, "_merged.csv"))
    if (!file.exists(fileName)) {
        mergedData <- .mergeSubtypeClinical(diseaseCode, curationAvailable)
        write_csv(x = mergedData, path = fileName)
    }
}

BiocParallel::bplapply(TCGAcodes, writeMergedClinical,
       curationAvailable=curationAvailable)

