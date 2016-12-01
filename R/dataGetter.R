# load libraries
library(devtools)
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

source("R/getDiseaseCodes.R")
TCGAcodes <- getDiseaseCodes()
runDate <- "20151101"
analyzeDate <- "20150821"
directory <- "data"

saveRTCGAdata <- function(diseaseCode, runDate, analyzeDate, directory) {
    diseaseCodename <- tolower(diseaseCode)
    rdsLocation <- file.path(directory, paste0(diseaseCode, ".rds"))
    if (file.exists(rdsLocation))
        cancerObj <- readRDS(rdsLocation)
    else {
        cancerObj <- getFirehoseData(dataset = diseaseCode,
                                     runDate = runDate,
                                     gistic2_Date = analyzeDate,
                            RNAseq_Gene = TRUE,
                            Clinic = TRUE,
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
        saveRDS(cancerObj, file = rdsLocation, compress = "bzip2")
    }
}

lapply(TCGAcodes, saveRTCGAdata, runDate, analyzeDate, directory)
