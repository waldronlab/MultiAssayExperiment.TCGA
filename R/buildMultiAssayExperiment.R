#' A unifying pipeline function for building MultiAssayExperiment objects
#'
#' This is the main function of the package. It brings together all of the
#' exported functions to load, create, and save data objects on ExperimentHub
#' and return documented metadata
#'
#' @inheritParams loadData
#'
#' @param TCGAcodes `character(1)` A single TCGA cancer code
#'
#' @param analyzeDate `character(1)` The GDAC Firehose analysis run date, only
#'   '20160128' is supported
#'
#' @param version `character(1)` A version string for versioning data runs (such
#'   as "1.0.0")
#'
#' @param outDataDir `character(1)` The single string indicating piecewise data
#'   product save location
#'
#' @param upload `logical(1)` (default FALSE) Whether to save data products to
#'   the cloud infrastructure, namely the Azure Blob Storage location.
#'
#' @param uploadFolder `character(1)` The folder where to upload the data
#'   (default "staginghub")
#'
#' @param update `logical(1)` (default TRUE) Whether to update the metadata data
#'   from the data pooled by the function
#'
#' @param forceDownload `logical(1)` Whether to re-download existing resources
#'   that were previously saved as Rds files in `saveRTCGAdata` (default FALSE)
#'
#' @param include `character()` A vector of metadata names to include. It must
#'   include any or all of "colData", "sampleMap", or "metadata". This allows to
#'   only publish changed data.
#'
#' @export
buildMultiAssayExperiment <-
    function(
    TCGAcode,
    dataType = c("RNASeqGene", "RNASeq2Gene", "RNASeq2GeneNorm",
        "miRNASeqGene", "CNASNP", "CNVSNP", "CNASeq", "CNACGH", "Methylation",
        "mRNAArray", "miRNAArray", "RPPAArray", "Mutation", "GISTIC"),
    runDate = "20160128", analyzeDate = "20160128", version,
    serialDir = "data/raw", outDataDir = "data/bits", mapDir = "data/maps",
    upload = FALSE, uploadFolder, update = TRUE,
    force = FALSE, forceDownload = FALSE,
    include = c("colData", "sampleMap", "metadata")
) {
    if (missing(TCGAcode))
        stop("Provide a valid and available TCGA disease code: 'TCGAcode'")

    message("\n######\n",
            "\nProcessing ", TCGAcode, " : )\n",
            "\n######\n")

    metas <- c("colData", "sampleMap", "metadata")
    includes <- match.arg(include, metas, several.ok = TRUE)
    names(includes) <- includes
    ## slotNames in FirehoseData RTCGAToolbox class
    targets <- c("RNASeqGene", "RNASeq2Gene", "RNASeq2GeneNorm",
        "miRNASeqGene", "CNASNP", "CNVSNP", "CNASeq", "CNACGH",
        "Methylation", "mRNAArray", "miRNAArray", "RPPAArray",
        "Mutation", "GISTIC")
    # builddate
    buildDate <- Sys.time()

    if (!is.null(dataType)) {
        dataType <- match.arg(dataType, targets, several.ok = TRUE)
        names(dataType) <- dataType

        ## Download raw data if not already serialized
        saveRTCGAdata(
            runDate, TCGAcode, dataType = dataType, analyzeDate = analyzeDate,
            directory = serialDir, force = forceDownload
        )
        dataFull <- loadData(
            cancer = TCGAcode, dataType = dataType, runDate = runDate,
            serialDir = serialDir, mapDir = mapDir, force = force
        )
        # dataLinks
        dataLinks <-
            getDataLinks(TCGAcode, data_date = runDate, dataTypes = targets)
        # metadata
        metadata <- list(
            buildDate, TCGAcode, runDate, analyzeDate, dataLinks,
            devtools::session_info()
        )
        names(metadata) <- c("buildDate", "cancerCode", "runDate",
            "analyzeDate", "dataLinks", "session_info")
    } else {
        dataFull <- list(
            colData = .loadClinicalData(cancer = TCGAcode, runDate = runDate)
        )
        metadata <- list(
            buildDate, TCGAcode, runDate, analyzeDate, devtools::session_info()
        )
        names(metadata) <- c("buildDate", "cancerCode", "runDate",
            "analyzeDate", "session_info")
    }

    mustData <- list(dataFull[["colData"]], dataFull[["sampleMap"]], metadata)
    mustNames <- paste0(
        TCGAcode, "_", c("colData", "sampleMap", "metadata"), "-", runDate
    )
    names(mustData) <- mustNames
    mustData <- mustData[grepl(paste(include, sep = "|"), names(mustData))]

    # add colData, sampleMap, and metadata to ExperimentList
    if (length(dataFull[["experiments"]]))
        mustData <- c(as(dataFull[["experiments"]], "list"), mustData)

    # save rda files and upload them to S3
    saveNupload(
        dataList = mustData, cancer = TCGAcode, directory = outDataDir,
        version = version, upload = upload, container = uploadFolder
    )

    # update MAEOinfo.csv
    if (update)
        updateInfo(
            dataList = mustData, cancer = TCGAcode,
            folderPath = outDataDir, version = version
        )
    mustData
}
