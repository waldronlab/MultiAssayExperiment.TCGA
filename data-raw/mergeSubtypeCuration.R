### Merging subtype files with clinical data

## Load available cancer codes
load("data/curationAvailable.rda")

## Save final merged datasets
writeMergedClinical <- function(diseaseCode, curationAvailable) {
    mergedData <- .mergeSubtypeClinical(diseaseCode, curationAvailable)
    mergedLocation <- dataDirectories()[["mergedClinical"]]
    write_csv(x = mergedData,
        path = file.path(mergedLocation, paste0(diseaseCode, "_merged.csv")))
}

lapply(TCGAcodes, writeMergedClinical,
       curationAvailable=curationAvailable)

