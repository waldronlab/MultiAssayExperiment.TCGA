library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

rD <- getFirehoseRunningDates(last = 1)
## run date: 20151101
gD <- getFirehoseAnalyzeDates(last = 1)
## gistic date: 20150821

## about 578 patients in the data (affymetrix)
ovca <- getFirehoseData("OV", runDate = rD, destdir = "./inst/extdata",
                        gistic2_Date = gD,
                        RNAseq_Gene=TRUE,
                        miRNASeq_Gene=TRUE,
                        RNAseq2_Gene_Norm=TRUE,
                        CNA_SNP = TRUE,
                        CNV_SNP=TRUE,
                        CNA_Seq = TRUE, # not available from RTCGAToolbox
                        CNA_CGH = TRUE,
                        Methylation = TRUE,
                        Mutation = TRUE,
                        mRNA_Array = TRUE,
                        miRNA_Array = TRUE,
                        RPPA_Array = TRUE,
                        fileSizeLimit = 50000,
                        RNAseqNorm = "raw_counts",
                        RNAseq2Norm = "normalized_count")

# save(ovca, file = "inst/extdata/ovca.Rda")

clinical_ovca <- ovca@Clinical
rownames(clinical_ovca) <- toupper(gsub("\\.", "-", rownames(clinical_ovca)))
clinical_ovca <- readr::type_convert(clinical_ovca)

targets <- c(slotNames(ovca)[c(5:16)], "gistica", "gistict")
names(targets) <- targets

dataList <- lapply(targets, function(x) {try(TCGAextract(ovca, x))})

dataFull <- Filter(function(x){class(x)!="try-error"}, dataList)
ExpList <- Elist(dataFull)
NewElist <- TCGAcleanExpList(ExpList, clinical_ovca)
NewMap <- generateMap(NewElist, clinical_ovca, TCGAbarcode)

ovMAEO <- MultiAssayExperiment(NewElist, clinical_ovca, NewMap)
saveRDS(ovMAEO, file = "./inst/extdata/ovMAEO2.rds", compress = "bzip2")
## ovMAEO <- readRDS("./inst/extdata/ovMAEO.rds")
