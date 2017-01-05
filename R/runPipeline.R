# load libraries
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)
library(devtools)

source("R/getDiseaseCodes.R")
source("data-raw/helpers.R")

# Create MultiAssayExperiments for each TCGA disease code
TCGAcodes <- getDiseaseCodes()
# runDate <- getFirehoseRunningDates(last=1)
runDate <- "20151101"
# analyzeDate <- getFirehoseAnalyzeDates(last=1)
analyzeDate <- "20150821"
dataDirectory <- "data"

# write header row to csv file for unit tests
if(!file.exists("MAEOinfo.csv")) {
    header <- cbind.data.frame("cohort_name", "experiment_name",
        "experiment_class", "feature_number", "sample_number")

    write.table(header, file = "MAEOinfo.csv", sep = ",",
        append = TRUE, row.names = FALSE, col.names = FALSE)
}

# buildMultiAssayExperiments function definition
buildMultiAssayExperiments <-
    function(TCGAcodes, runDate, analyzeDate, dataDirectory) {
        if (!dir.exists(dataDirectory))
            dir.create(dataDirectory)

        for (cancer in TCGAcodes) {
            message("\n######\n", "\nProcessing ", cancer, " : )\n", "\n######\n")
            serialPath <- file.path(dataDirectory, paste0(cancer, ".rds"))

            if (file.exists(serialPath)) {
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
            clinicalPath <- file.path(dataDirectories()[["mergedClinical"]],
                                      paste0(cancer, "_reduced.csv"))
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

            exps <- c("CNASNP", "CNVSNP", "CNASeq", "CNACGH")
            inAssays <- exps %in% assayNames
            if (any(inAssays)) {
            exps <- exps[inAssays]
            invisible(lapply(exps, function(dataType) {
                type <- switch(dataType,
                               CNASNP = "CNA_SNP",
                               CNVSNP = "CNV_SNP",
                               CNASeq = "CNA_Seq",
                               CNACGH = "CNA_CGH")
                args <- list(cancer, runDate, TRUE)
                names(args) <- c("disease", "runDate", type)
                source_file <- do.call(getFileNames, args = args)
                genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file,
                                     ignore.case = TRUE)
                dataFull[[dataType]] <- genome_build
                source_file <- c(source_file = source_file)
                metadata(dataFull[[dataType]]) <- c(metadata(dataFull[[dataType]]),
                                                    source_file)
            }))
            message( paste(exps, collapse = ", ") , " metadata added")
            }
            NewMap <- generateMap(dataFull, clinicalData, TCGAbarcode)
            MAEO <- MultiAssayExperiment(dataFull, clinicalData, NewMap)

            MAEOmeta <- c(cancer, runDate, analyzeDate, devtools::session_info())
            names(MAEOmeta)[1:3] <- c("cancerCode", "runDate", "analyzeDate", "session_info")
            metadata(MAEO) <- c(metadata(MAEO), MAEOmeta)

            # Serialize MultiAssayExperiment object
            saveRDS(MAEO, file = file.path(dataDirectory,
                                           paste0(tolower(cancer), "MAEO.rds")),
                    compress = "bzip2")

            # Upload data to S3 bucket
            upload_to_S3(file = file.path(dataDirectory,
                                          paste0(tolower(cancer), "MAEO.rds")),
                         remotename = paste0(tolower(cancer), "MAEO.rds"),
                         bucket = "multiassayexperiments")

            # Add lines to csv file for unit tests
            cohort_name <- rep(cancer, length(experiments(MAEO)))
            experiment_names <- names(MAEO)
            experiment_classes <- vapply(experiments(MAEO), class, character(1L))
            feature_numbers <- vapply(experiments(MAEO), function(exp) dim(exp)[[1L]],
                                     integer(1L))
            sample_numbers <- vapply(experiments(MAEO), function(exp) dim(exp)[[2L]],
                                    integer(1L))
            MAEOinfo <- cbind.data.frame(cohort_name, experiment_names, experiment_classes,
                                         feature_numbers, sample_numbers)
            write.table(MAEOinfo, file = "MAEOinfo.csv", sep = ",", append = TRUE,
                        row.names = FALSE, col.names = FALSE)
        }
    }

# call buildMultiAssayExperiment function
buildMultiAssayExperiments(TCGAcodes, runDate, analyzeDate, dataDirectory)

