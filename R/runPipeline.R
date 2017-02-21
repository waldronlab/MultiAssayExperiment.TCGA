## Load libraries
source("R/loadLibraries.R")
## Get TCGA cancer codes
source("R/getDiseaseCodes.R")
## Load supporting functions
source("data-raw/helpers.R")
## Load function for updating metadata
source("R/updateInfo.R")
## Load subtypeMaps list from file
source("data-raw/subtypeMaps.R")

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
            serialPath <- file.path("data/raw", paste0(cancer, ".rds"))

            if (file.exists(serialPath) && !force) {
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
                                                RNAseq2Norm =
                                                    "normalized_count",
                                                forceDownload = FALSE,
                                                destdir = "./tmp",
                                                fileSizeLimit = 500000,
                                                getUUIDs = FALSE)
                saveRDS(cancerObject, file = serialPath, compress = "bzip2")
            }
            ## pData - clinicalData
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
            metadata(clinicalData)[["subtypes"]] <- subtypeMaps[[cancer]]
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

            # sampleMap
            NewMap <- generateMap(dataFull, clinicalData, TCGAbarcode)
            # ExperimentList
            dataFull <- MultiAssayExperiment:::.harmonize(
                MultiAssayExperiment::ExperimentList(dataFull),
                clinicalData,
                NewMap)
            # metadata
            metadata <- c(cancer, runDate, analyzeDate,
                          devtools::session_info())
            names(metadata) <- c("cancerCode", "runDate", "analyzeDate",
                                 "session_info")

            # add pData, sampleMap, and metadata to ExperimentList
            extraObjects <- list(pData = clinicalData,
                                 sampleMap = newMap,
                                 metadata = metadata)
            allObjects <- c(extraObjects, dataFull)
            saveNupload(allObjects, cancer, directory = "data/bits")

            lapply(seq_along(allObjects), function(i, dataElement, code) {
               updateInfo(dataElement[i], code)
            }, dataAssay = dataFull, code = cancer)
        }
    }

# call buildMultiAssayExperiments function
buildMultiAssayExperiments(TCGAcodes, runDate, analyzeDate, dataDirectory, force = TRUE)

