## Load libraries
source("R/loadLibraries.R")
## Get TCGA cancer codes
source("R/getDiseaseCodes.R")
## Load supporting functions
source("data-raw/helpers.R")
## Load function for updating metadata
source("R/updateInfo.R")
## Load function for downloading raw data
source("R/saveRTCGAdata.R")
## Load function for saving results and uploading to S3
source("R/saveNupload.R")

# Create MultiAssayExperiments for each TCGA disease code
TCGAcodes <- getDiseaseCodes()

# If subset needs to be run, replace cancer code with last unsuccessful attempt
TCGAcodes <- TCGAcodes[which(TCGAcodes == "ACC"):length(TCGAcodes)]

# runDate <- getFirehoseRunningDates(last=1)
runDate <- "20160128"

# analyzeDate <- getFirehoseAnalyzeDates(last=1)
analyzeDate <- "20160128"
dataDirectory <- "data/built"

# write header row to csv file for unit tests
header <- cbind.data.frame("cancerCode", "assay", "class", "nrow", "ncol")
write.table(header, file = "MAEOinfo.csv", sep = ",",
            row.names = FALSE, col.names = FALSE)

# buildMultiAssayExperiments function definition
buildMultiAssayExperiments <- function(runDate, TCGAcodes, dataType = "all",
                                   analyzeDate, dataDirectory, force = FALSE) {
    if (!dir.exists(dataDirectory))
        dir.create(dataDirectory)

    for (cancer in TCGAcodes) {
        message("\n######\n",
                "\nProcessing ", cancer, " : )\n",
                "\n######\n")
        serialDir <- file.path("data/raw")

        targets <- c("RNASeqGene", "RNASeq2GeneNorm", "miRNASeqGene",
                     "CNASNP", "CNVSNP", "CNASeq", "CNACGH", "Methylation",
                     "mRNAArray", "miRNAArray", "RPPAArray", "Mutation",
                     "GISTIC")

        if (dataType != "all") {
            dataType <- match.arg(dataType, targets)
        } else {
            dataType <- targets
            names(dataType) <- dataType
        }

        ## Download raw data if not already serialized
        saveRTCGAdata(runDate, cancer, dataType = dataType,
                      analyzeDate = analyzeDate, directory = serialDir,
                      force = force)

        ## slotNames in FirehoseData RTCGAToolbox class

        ## Specify cancer folder
        cancerFolder <- file.path(serialDir, cancer)

        ## colData - clinicalData
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
        ObjNames <- .cleanFileNames(dataFiles, "-", 1L)
        ## Select targets from dataTypes
        fileDatType <- .cleanFileNames(ObjNames, "_", 2L)
        subTargets <- match(targets, fileDatType)
        ## Load targets to memory
        dataList <- lapply(dataFiles[subTargets], readRDS)
        names(dataList) <- ObjNames[subTargets]
        dataListIdx <- seq_along(dataList)
        names(dataListIdx) <- names(dataList)
        dataList <- lapply(dataListIdx, function(i, dlist) {
            dattype <- .cleanFileNames(names(dlist[i]), "_", 2L)
            TCGAutils::TCGAextract(dlist[[i]], dattype)
        }, dlist = dataList)

        ## Filter by zero length
        dataFull <- Filter(function(x) {length(x)}, dataList)

        isList <- vapply(dataFull, is.list, logical(1L))
        if (any(isList)) {
            dataFull <- unlist(dataFull, use.names = TRUE)
            names(dataFull) <- paste0(gsub("\\.", "_", names(dataFull)), "-",
                                      runDate)
        }

        # sampleMap - generate by getting all colnames
        sampMap <- generateMap(dataFull, clinicalData, TCGAbarcode, force = TRUE)

        # ExperimentList
        dataFull <- MultiAssayExperiment:::.harmonize(
            MultiAssayExperiment::ExperimentList(dataFull),
            clinicalData,
            sampMap)
        # builddate
        buildDate <- Sys.time()
        # metadata
        metadata <- list(buildDate, cancer, runDate, analyzeDate,
                      devtools::session_info())
        names(metadata) <- c("buildDate", "cancerCode", "runDate",
                             "analyzeDate", "session_info")

        mustData <- list(dataFull[["colData"]], dataFull[["sampleMap"]],
                         metadata)
        mustNames <- paste0(cancer, "_", c("colData", "sampleMap",
                                                 "metadata"), "-", runDate)
        names(mustData) <- mustNames

        # add colData, sampleMap, and metadata to ExperimentList
        if (length(dataFull[["experiments"]]))
        allObjects <- c(as(dataFull[["experiments"]], "list"), mustData)

        # save rda files and upload them to S3
        saveNupload(allObjects, cancer, directory = "data/bits")
        # update MAEOinfo.csv
        lapply(seq_along(allObjects), function(i, dataElement, code) {
        if (!names(dataElement[i]) %in% mustNames)
           updateInfo(dataElement[i], code)
        }, dataElement = allObjects, code = cancer)
    }
}

# call buildMultiAssayExperiments function
buildMultiAssayExperiments(runDate, TCGAcodes, dataType = "all", analyzeDate,
                           dataDirectory)
