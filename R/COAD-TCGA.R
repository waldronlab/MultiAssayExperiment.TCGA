library(MultiAssayExperiment)
library(RTCGAToolbox)
library(TCGAbiolinks)

rD <- getFirehoseRunningDates(last = 1)
## run date: 20151101
gD <- getFirehoseAnalyzeDates(last = 1)
## gistic date: 20150821

coad <- getFirehoseData("COAD", runDate = rD, gistic2_Date = gD, destdir = "./rawdata",
                        RNAseq_Gene=TRUE, miRNASeq_Gene=TRUE, RNAseq2_Gene_Norm=TRUE,
                        CNA_SNP = TRUE, CNV_SNP=TRUE, CNA_Seq = TRUE,
                        CNA_CGH = TRUE, Methylation = TRUE, Mutation = TRUE,
                        mRNA_Array = TRUE, miRNA_Array = TRUE, RPPA = TRUE,
                        fileSizeLimit = 50000)
