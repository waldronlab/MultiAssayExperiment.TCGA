library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)

rD <- getFirehoseRunningDates(last = 1)
## run date: 20151101
gD <- getFirehoseAnalyzeDates(last = 1)
## gistic date: 20150821

coad <- getFirehoseData("KIRC", runDate = rD, destdir = "./inst/extdata",
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

clinical_kirc <- kirc@Clinical
rownames(clinical_kirc) <- gsub("\\.", "-", rownames(clinical_kirc))
clinical_kirc <- readr::type_convert(clinical_kirc)

targets <- c(slotNames(kirc)[c(5:16)], "gistica", "gistict")

dataList <- lapply(targets, function(x) {try(BiocInterfaces::TCGAextract(kirc, x))})
names(dataList) <- targets

dataFull <- Filter(function(x){class(x)!="try-error"}, dataList)
ExpList <- Elist(dataFull)
NewElist <- TCGAcleanExpList(ExpList, clinical_kirc)
NewMap <- generateMap(NewElist, clinical_kirc, TCGAbarcode)

kircMAEO <- MultiAssayExperiment(NewElist, clinical_kirc, NewMap)
saveRDS(kircMAEO, file = "./inst/extdata/kircMAEO.rds", compress = "bzip2")
## kircMAEO <- readRDS("./inst/extdata/kircMAEO.rds")
