# load libraries
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

source("data-raw/diseaseCodes.R")
source("data-raw/helpers.R")

# newMAEO variables
TCGAcodes <- includeDatasets
runDate <- getFirehoseRunningDates(last=1)
analyzeDate <- getFirehoseAnalyzeDates(last=1)
dataDirectory <- "data"

# write header row to csv file for unit tests
if(!file.exists("MAEOinfo.csv")) {
    header <- data.frame(cbind("cohort_name", "experiment_name",
        "experiment_class", "feature_number", "sample_number"))

    write.table(header, file = "MAEOinfo.csv", sep = ",",
        append = TRUE, row.names = FALSE, col.names = FALSE)
}

# newMAEO function definition
newMAEO <- function(TCGAcodes, runDate, analyzeDate, dataDirectory) {
    if(!dir.exists(dataDirectory)) {
    dir.create(dataDirectory)
  }

  for(cancer in TCGAcodes) {
    message("\n######\n", "\nProcessing ", cancer, " : )\n", "\n######\n")
    cancerCode <- toupper(cancer)
    serialPath <- file.path(dataDirectory, paste0(cancerCode, ".rds"))

    if(file.exists(serialPath)) {
        cancerObject <- readRDS(serialPath)
    } else {
      cancerObject <- getFirehoseData(cancer, runDate = runDate,
                            gistic2_Date = analyzeDate,
                            RNAseq_Gene = TRUE,
                            Clinic = FALSE,
                            miRNASeq_Gene = TRUE,
                            RNAseq2_Gene_Norm = TRUE,
                            CNA_SNP = TRUE,
                            CNV_SNP = TRUE,
                            CNA_Seq = TRUE,
                            CNA_CGH = TRUE,
                            Methylation = TRUE,
                            Mutation = TRUE,
                            mRNA_Array = TRUE,
                            miRNA_Array = TRUE,
                            RPPA_Array = TRUE,
                            RNAseqNorm = "raw_counts",
                            RNAseq2Norm = "normalized_count",
                            forceDownload = FALSE,
                            destdir = "./tmp",
                            fileSizeLimit = 500000,
                            getUUIDs = FALSE)
      saveRDS(cancerObject, file = serialPath, compress = "bzip2")
    }
    ## Include curated clinical data
    clinicalPath <- file.path(dataDirectories()[["mergedClinical"]], paste0(cancer, "_reduced.csv"))
    stopifnot(file.exists(clinicalPath))
    clinicalData <- read.csv(clinicalPath, header=TRUE, stringsAsFactors=FALSE)
    rownames(clinicalData) <- clinicalData[["patientID"]]
    clinicalData <- S4Vectors::DataFrame(clinicalData)
    metadata(clinicalData)[["droppedColumns"]] <-
        readRDS(file.path(dataDirectories()[["mergedClinical"]],
                          paste0(cancer, "_dropped.rds")))

    targets <- c(slotNames(cancerObject)[c(5:16)], "gistica", "gistict")
    names(targets) <- targets
    dataList <- lapply(targets, function(x) {
                           tryCatch({TCGAextract(cancerObject, x)},
                               error = function(e) {message(x, " does not contain any data!")})
                            })
    dataFull <- Filter(function(x){class(x)!="NULL"}, dataList)
    assayNames <- names(dataFull)

    if("CNASNP" %in% assayNames) {
        source_file <- getFileNames(cancer, runDate, CNA_SNP = TRUE)
        genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file,
                             ignore.case = TRUE)
        genome(dataFull$CNASNP) <- genome_build
        source_file <- as.list(source_file)
        names(source_file) <- "source_file"
        metadata(dataFull$CNASNP) <- c(metadata(dataFull$CNASNP), source_file)
    }

    if("CNVSNP" %in% assayNames) {
        source_file <- getFileNames(cancer, runDate, CNV_SNP = TRUE)
        genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file,
                             ignore.case = TRUE)
        genome(dataFull$CNVSNP) <- genome_build
        source_file <- as.list(source_file)
        names(source_file) <- "source_file"
        metadata(dataFull$CNVSNP) <- c(metadata(dataFull$CNVSNP), source_file)
    }

    if("CNASeq" %in% assayNames) {
        source_file <- getFileNames(cancer, runDate, CNA_Seq = TRUE)
        genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file,
                             ignore.case = TRUE)
        genome(dataFull$CNASeq) <- genome_build
        source_file <- as.list(source_file)
        names(source_file) <- "source_file"
        metadata(dataFull$CNASeq) <- c(metadata(dataFull$CNASeq), source_file)
    }

    if("CNACGH" %in% assayNames) {
        source_file <- getFileNames(cancer, runDate, CNA_CGH = TRUE)
        genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file,
                             ignore.case = TRUE)
        genome(dataFull$CNACGH) <- genome_build
        source_file <- as.list(source_file)
        names(source_file) <- "source_file"
        metadata(dataFull$CNACGH) <- c(metadata(dataFull$CNACGH), source_file)
    }

    ExpList <- ExperimentList(dataFull)
    NewElist <- TCGAcleanExpList(ExpList, clinicalData)
    NewMap <- generateMap(NewElist, clinicalData, TCGAbarcode)
    MAEO <- MultiAssayExperiment(NewElist, clinicalData, NewMap)

    MAEOmeta <- c(cancer, runDate, analyzeDate, sessionInfo())
    names(MAEOmeta)[1:3] <- c("cohort_name", "running_date", "analysis_data")
    metadata(MAEO) <- c(metadata(MAEO), MAEOmeta)

    saveRDS(MAEO, file = file.path(dataDirectory,
                                   paste0(cancerCode, "MAEO.rds")),
            compress = "bzip2")

    # add lines to csv file for unit tests
    cohort_name <- rep(cancerCode, length(experiments(MAEO)))
    experiment_name <- names(MAEO)
    experiment_class <- vapply(experiments(MAEO), class, character(1L))
    feature_number <- vapply(experiments(MAEO), function(exp) dim(exp)[[1L]],
                             integer(1L))
    sample_number <- vapply(experiments(MAEO), function(exp) dim(exp)[[2L]],
                            integer(1L))
    MAEOinfo <- data.frame(cbind(cohort_name, experiment_name, experiment_class,
                                 feature_number, sample_number))
    write.table(MAEOinfo, file = "MAEOinfo.csv", sep = ",", append = TRUE,
                row.names = FALSE, col.names = FALSE)
  }
}

# call newMAEO function
newMAEO(TCGAcodes, runDate, analyzeDate, dataDirectory)

