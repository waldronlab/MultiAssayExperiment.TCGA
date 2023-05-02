.loadClinicalData <- function(cancer, runDate) {
    clinicalPath <- file.path(
        dataDirectories()[["mergedClinical"]],
        paste(runDate, paste0(cancer, "_reduced.csv"), sep = "-"))
    stopifnot(file.exists(clinicalPath))
    clinicalData <- read.csv(clinicalPath, header=TRUE,
        stringsAsFactors=FALSE)
    clinicalData <- clinicalData[!duplicated(clinicalData[["patientID"]]), ]
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
    clinicalData
}

#' Load and assemble MultiAssayExperiments from files
#'
#' loadData takes cancer, data type, and storage inputs to piece together a
#' working MultiAssayExperiment object
#'
#' @param cancer A single character string indicating the TCGA disease code
#' @param dataType A character vector of TCGA assay types
#' @param runDate A single string indicating the Firehose run date, usually
#' '20160128'
#' @param serialDir The directory corresponding to the serialized data from
#' RTCGAToolbox
#' @param mapDir A single string indicating the directory where sampleMaps
#' are stored from `saveMapData`
#' @param force (logical) Whether to resave all sample maps to the map
#' directory
#'
#' @return A harmonized MultiAssayExperiment object
#'
#' @export
loadData <- function(cancer, dataType, runDate, serialDir, mapDir, force) {
    cancerFolder <- file.path(serialDir, cancer)
    clinicalData <- .loadClinicalData(cancer = cancer, runDate = runDate)
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
