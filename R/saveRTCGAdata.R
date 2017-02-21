saveRTCGAdata <- function(diseaseCode, runDate, analyzeDate, directory, force) {
    rdsLocation <- file.path(directory, paste0(diseaseCode, ".rds"))
    if (file.exists(rdsLocation))
        cancerObject <- readRDS(rdsLocation)
    else {
        cancerObject <- getFirehoseData(dataset = diseaseCode,
                                     runDate = runDate,
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
        saveRDS(cancerObject, file = rdsLocation, compress = "bzip2")
    }
}
