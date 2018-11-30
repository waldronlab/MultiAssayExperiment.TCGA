loadData <- function(cancer, dataType, runDate, serialDir, mapDir) {
    cancerFolder <- file.path(serialDir, cancer)

    clinicalPath <- file.path(
        dataDirectories()[["mergedClinical"]],
        paste(runDate, paste0(cancer, "_reduced.csv"), sep = "-"))
    stopifnot(file.exists(clinicalPath))
    clinicalData <- read.csv(clinicalPath, header=TRUE,
        stringsAsFactors=FALSE)
    rownames(clinicalData) <- clinicalData[["patientID"]]
    clinicalData <- S4Vectors::DataFrame(clinicalData)
    metadata(clinicalData)[["droppedColumns"]] <-
        readRDS(file.path(
            dataDirectories()[["mergedClinical"]],
            paste(runDate, paste0(cancer, "_dropped.rds"), sep = "-")))

    ### Add subtype maps where available
    subtypeMapFile <- file.path(dataDirectories()[["curatedMaps"]],
        paste0(cancer, "_subtypeMap.csv"))
    if (file.exists(subtypeMapFile)) {
        curatedMap <- read.csv(subtypeMapFile)
        metadata(clinicalData)[["subtypes"]] <- curatedMap
    }

    dataFiles <- list.files(cancerFolder, full.names = TRUE,
        pattern = "rds$")

    dataMap <- data.frame(
        Rpath = dataFiles,
        dataType = .cleanFileNames(dataFiles, "-|_", 2L),
        ObjName = .cleanFileNames(dataFiles, "-", 1L),
        stringsAsFactors = FALSE
    )
    subTargets <- match(dataType, dataMap[["dataType"]])
    dataMap <- dataMap[subTargets, ]

    ## Load targets to memory
    dataList <- lapply(dataMap[["Rpath"]], readRDS)
    names(dataList) <- dataMap[["ObjName"]]

    dataList <- Map(function(x, y) {
        RTCGAToolbox::biocExtract(x, y)
        }, dataList, dataMap[["dataType"]])

    ## Filter by zero length
    dataFull <- Filter(length, dataList)
    if (!length(dataFull))
        next

    isList <- vapply(dataFull, is.list, logical(1L))
    if (any(isList))
        dataFull <- unlist(lapply(dataFull, unlist, use.names = TRUE))
    names(dataFull) <- paste0(gsub("\\.", "_", names(dataFull)),
        "-", runDate)

    # sampleMap - generate by getting all colnames
    sampMap <- saveMapData(dataFull, clinicalData, TCGAutils::TCGAbarcode,
    cancer = cancer, force = force, directory = mapDir)

    # ExperimentList
    MultiAssayExperiment:::.harmonize(
        MultiAssayExperiment::ExperimentList(dataFull),
        clinicalData,
        sampMap)
}

