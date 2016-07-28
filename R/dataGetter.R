# load libraries
library(devtools)
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

# newMAEO variables
ds <- getFirehoseDatasets()[3]
rd <- getFirehoseRunningDates()[1]
ad <- getFirehoseAnalyzeDates()[1]
dd <- "data"

# newMAEO function definition
newMAEO <- function(ds, rd, ad, dd) {
  for(i in ds) {
    cn <- tolower(i)
    fp <- file.path(dd, paste0(cn, ".rds"))
    if(file.exists(fp)) {
      co <- readRDS(fp)
    } else {
      co <- getFirehoseData(i, runDate = rd, gistic2_Date = ad,
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
      saveRDS(co, file = fp, compress = "bzip2")
    }
  }
}

# call newMAEO function
newMAEO(ds, rd, ad, dd)
