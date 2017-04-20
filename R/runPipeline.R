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
buildMultiAssayExperiments <-
    function(TCGAcodes, runDate, analyzeDate, dataDirectory, force) {
    if (!dir.exists(dataDirectory))
        dir.create(dataDirectory)

    for (cancer in TCGAcodes) {
        message("\n######\n",
                "\nProcessing ", cancer, " : )\n",
                "\n######\n")
        serialDir <- file.path("data/raw")

        ## Download raw data if not already serialized
        saveRTCGAdata(cancer, runDate, analyzeDate, serialDir, force)

        ## Load data
        cancerObject <- readRDS(file.path(serialDir, paste0(cancer, ".rds")))

        ## colData - clinicalData
        clinicalPath <- file.path(dataDirectories()[["mergedClinical"]],
                                  paste0(cancer, "_reduced.csv"))
        stopifnot(file.exists(clinicalPath))
        clinicalData <- read.csv(clinicalPath, header=TRUE,
                                 stringsAsFactors=FALSE)
        rownames(clinicalData) <- clinicalData[["patientID"]]
        clinicalData <- S4Vectors::DataFrame(clinicalData)
        metadata(clinicalData)[["droppedColumns"]] <-
            readRDS(file.path(dataDirectories()[["mergedClinical"]],
                              paste0(cancer, "_dropped.rds")))

        ### Add subtype maps where available
        subtypeMapFile <- file.path(dataDirectories()[["curatedMaps"]],
                                    paste0(cancer, "_subtypeMap.csv"))
        if (file.exists(subtypeMapFile)) {
            curatedMap <- read.csv(subtypeMapFile)
            metadata(clinicalData)[["subtypes"]] <- curatedMap
        }

        ## slotNames in FirehoseData RTCGAToolbox class
        targets <- c("RNASeqGene", "RNASeq2GeneNorm", "miRNASeqGene",
                     "CNASNP", "CNVSNP", "CNAseq", "CNACGH", "Methylation",
                     "mRNAArray", "miRNAArray", "RPPAArray", "Mutations",
                     "gistica", "gistict")
        names(targets) <- targets
        dataList <- lapply(targets, function(datType) {
            tryCatch({TCGAutils::TCGAextract(cancerObject, datType)},
                     error = function(e) {
                         message(datType, " does not contain any data!")
                         })
        })
        dataFull <- Filter(function(x) {!is.null(x)}, dataList)
        assayNames <- names(dataFull)

        exps <- c("CNASNP", "CNVSNP", "CNAseq", "CNACGH")
        inAssays <- exps %in% assayNames
        if (any(inAssays)) {
        exps <- exps[inAssays]
        invisible(lapply(exps, function(dataType) {
            type <- switch(dataType,
                           CNASNP = "CNA_SNP",
                           CNVSNP = "CNV_SNP",
                           CNAseq = "CNA_Seq",
                           CNACGH = "CNA_CGH")
            args <- list(cancer, runDate, TRUE)
            names(args) <- c("disease", "runDate", type)
            source_file <- do.call(getFileNames, args = args)
            genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2",
                                 x = source_file,
                                 ignore.case = TRUE)
            if (S4Vectors::isEmpty(genome_build))
                genome_build <- NA
            GenomeInfoDb::genome(dataFull[[dataType]]) <- genome_build
            source_file <- c(source_file = source_file)
            metadata(dataFull[[dataType]]) <-
                c(metadata(dataFull[[dataType]]), source_file)
        }))
        message(paste(exps, collapse = ", ") , " metadata added")
        }
        ## Create RaggedExperiment from GRangesList
        for (i in seq_along(dataFull)) {
            if (is(dataFull[[i]], "GRangesList"))
                dataFull[[i]] <-
                    RaggedExperiment::RaggedExperiment(dataFull[[i]])
        }

        # sampleMap
        newMap <- generateMap(dataFull, clinicalData, TCGAbarcode)
        # ExperimentList
        dataFull <- MultiAssayExperiment:::.harmonize(
            MultiAssayExperiment::ExperimentList(dataFull),
            clinicalData,
            newMap)
        # builddate
        buildDate <- Sys.time()
        # metadata
        metadata <- list(buildDate, cancer, runDate, analyzeDate,
                      devtools::session_info())
        names(metadata) <- c("buildDate", "cancerCode", "runDate",
                             "analyzeDate", "session_info")

        # add colData, sampleMap, and metadata to ExperimentList
        allObjects <- c(as(dataFull[["experiments"]], "list"),
                        colData = dataFull[["colData"]],
                        sampleMap = dataFull[["sampleMap"]],
                        metadata = list(metadata))

        # save rda files and upload them to S3
        saveNupload(allObjects, cancer, directory = "data/bits")
        # update MAEOinfo.csv
        lapply(seq_along(allObjects), function(i, dataElement, code) {
        if (!names(dataElement[i]) %in% c("colData", "sampleMap", "metadata"))
           updateInfo(dataElement[i], code)
        }, dataElement = allObjects, code = cancer)
    }
}

# call buildMultiAssayExperiments function
buildMultiAssayExperiments(TCGAcodes, runDate,
            analyzeDate, dataDirectory, force = FALSE)

