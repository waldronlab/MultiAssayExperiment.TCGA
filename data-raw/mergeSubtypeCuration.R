### Merging subtype files with clinical data

## Load available cancer codes
load("data/curationAvailable.rda")

## Save final merged datasets
writeMergedClinical <- function(diseaseCode, runDate = "20160128", curationAvailable) {
    dirList <- dataDirectories()
    mergedClinical <- dirList[["mergedClinical"]]
    fileName <- file.path(mergedClinical, paste(runDate,
                          paste0(diseaseCode, "_merged.csv"), sep = "-"))
    if (!file.exists(fileName)) {
        mergedData <- .mergeSubtypeClinical(diseaseCode, runDate = runDate,
                                            curationAvailable)
        write_csv(x = mergedData, path = fileName)
    }
}

BiocParallel::bplapply(TCGAcodes, writeMergedClinical,
       curationAvailable=curationAvailable)
