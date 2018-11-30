saveMapData <- function(data_list, clinical_frame, FUN = TCGAutils::TCGAbarcode,
    cancer, force, directory) {
    sampMap <- generateMap(data_list, clinical_frame, FUN)
    splitMap <- splitAsList(sampMap, sampMap[["assay"]])
    mapDir <- file.path(directory, cancer)
    if (!dir.exists(mapDir))
        dir.create(mapDir, recursive = TRUE)
    mapFiles <- list.files(path = mapDir, pattern = "_map.csv",
        full.names = TRUE)
    assayNames <- gsub("_map.csv", "", basename(mapFiles))
    splitNames <- if (force) TRUE else !names(splitMap) %in% assayNames
    newAssays <- names(splitMap)[splitNames]

    for (assay in newAssays)
        write.table(splitMap[[assay]], sep = ",",
            file = file.path(mapDir, paste0(assay, "_map.csv")))

    return(sampMap)
}
