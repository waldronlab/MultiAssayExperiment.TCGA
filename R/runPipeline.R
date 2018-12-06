## Load libraries
source("R/loadLibraries.R")
## Load supporting functions
source("data-raw/helpers.R")
## Load function for updating metadata
source("R/updateInfo.R")
## Load function for downloading raw data
source("R/saveRTCGAdata.R")
## Load function for saving results and uploading to S3
source("R/saveNupload.R")
## Load function for saving map pieces
source("R/saveMapData.R")
## Load function for reading and loading data from files
source("R/loadData.R")

# Create MultiAssayExperiments for each TCGA disease code
TCGAcodes <- diseaseCodes[diseaseCodes[["Available"]] == "Yes",
    "Study.Abbreviation"]
names(TCGAcodes) <- TCGAcodes

# If subset needs to be run, replace cancer code with last unsuccessful attempt
TCGAcodes <- TCGAcodes[which(TCGAcodes == "ACC"):length(TCGAcodes)]

# buildMultiAssayExperiments function definition
buildMultiAssayExperiments <-
    function(
    TCGAcodes,
    dataType = c("RNASeqGene", "RNASeq2GeneNorm", "miRNASeqGene", "CNASNP",
        "CNVSNP", "CNASeq", "CNACGH", "Methylation", "mRNAArray", "miRNAArray",
        "RPPAArray", "Mutation", "GISTIC"),
    runDate = "20160128", analyzeDate = "20160128",
    serialDir = "data/raw", outDataDir = "data/bits", mapDir = "data/maps",
    metadataFile = "MAEOinfo.csv", upload = TRUE, force = FALSE)
{
    if (!dir.exists(outDataDir))
        dir.create(outDataDir)

    for (cancer in TCGAcodes) {
        message("\n######\n",
                "\nProcessing ", cancer, " : )\n",
                "\n######\n")

        ## slotNames in FirehoseData RTCGAToolbox class
        targets <- c("RNASeqGene", "RNASeq2GeneNorm", "miRNASeqGene",
            "CNASNP", "CNVSNP", "CNASeq", "CNACGH", "Methylation",
            "mRNAArray", "miRNAArray", "RPPAArray", "Mutation",
            "GISTIC")

        dataType <- match.arg(dataType, targets, several.ok = TRUE)
        names(dataType) <- dataType

        ## Download raw data if not already serialized
        saveRTCGAdata(runDate, cancer, dataType = dataType,
            analyzeDate = analyzeDate, directory = serialDir,
            force = force)
        dataFull <- loadData(cancer = cancer, dataType = dataType,
            runDate = runDate, serialDir = serialDir, mapDir = mapDir,
            force = force)
        # builddate
        buildDate <- Sys.time()
        # metadata
        metadata <- list(buildDate, cancer, runDate, analyzeDate,
            devtools::session_info())
        names(metadata) <- c("buildDate", "cancerCode", "runDate",
            "analyzeDate", "session_info")

        mustData <- list(dataFull[["colData"]], dataFull[["sampleMap"]],
            metadata)
        mustNames <- paste0(cancer, "_",
            c("colData", "sampleMap", "metadata"), "-", runDate)
        names(mustData) <- mustNames

        # add colData, sampleMap, and metadata to ExperimentList
        if (length(dataFull[["experiments"]]))
            allObjects <- c(as(dataFull[["experiments"]], "list"), mustData)

        # save rda files and upload them to S3
        saveNupload(allObjects, cancer, directory = outDataDir, upload = upload)

        # update MAEOinfo.csv
        updateInfo(dataList = allObjects, cancerCode = cancer,
            filePath = metadataFile)
    }
}

# call buildMultiAssayExperiments function
buildMultiAssayExperiments(TCGAcodes)
