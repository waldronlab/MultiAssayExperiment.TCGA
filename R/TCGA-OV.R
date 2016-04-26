library(MultiAssayExperiment)
library(RTCGAToolbox)

rD <- getFirehoseRunningDates(last = 1)
## run date: 20151101
gD <- getFirehoseAnalyzeDates(last = 1)
## gistic date: 20150821

ovca <- getFirehoseData("OV", runDate = rD, destdir = "./rawdata",
                        gistic2_Date = gD,
                        RNAseq_Gene=TRUE,
                        miRNASeq_Gene=TRUE,
                        RNAseq2_Gene_Norm=TRUE,
                        CNA_SNP = TRUE,
                        CNV_SNP=TRUE,
                        CNA_Seq = TRUE,
                        CNA_CGH = TRUE,
                        Methylation = TRUE,
                        Mutation = TRUE,
                        mRNA_Array = TRUE,
                        miRNA_Array = TRUE,
                        RPPA = TRUE,
                        fileSizeLimit = 50000,
                        RNAseqNorm = "raw_counts",
                        RNAseq2Norm = "normalized_count")

clinical_ovca <- ovca@Clinical
rownames(clinical_ovca) <- gsub("\\.", "-", rownames(clinical_ovca))

targets <- c(slotNames(ovca)[c(5:16)], "gistica", "gistict")

dataList <- lapply(targets, function(x) {TCGAmisc::extract(ovca, x)})
