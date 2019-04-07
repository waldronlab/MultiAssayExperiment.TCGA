### Merging subtype files with clinical data

## Save final merged datasets
writeMergedClinical <-
    function(diseaseCode, runDate = "20160128", force = FALSE)
{
    dirList <- dataDirectories()
    mergedClinical <- dirList[["mergedClinical"]]
    fileName <- file.path(mergedClinical, paste(runDate,
                          paste0(diseaseCode, "_merged.csv"), sep = "-"))
    if (!file.exists(fileName) || force) {
        mergedData <- .mergeSubtypeClinical(diseaseCode, runDate = runDate)
        write_csv(x = mergedData, path = fileName)
        message(diseaseCode, " curation merged to clincial data!\n",
        "See: ", fileName)
    }
}

BiocParallel::bplapply(TCGAcodes, writeMergedClinical)
