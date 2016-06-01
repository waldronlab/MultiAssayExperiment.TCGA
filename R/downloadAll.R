library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

ds <- getFirehoseDatasets()[c(1:5, 7:9, 12:14, 16:31, 33:38)]
rd <- getFirehoseRunningDates()[1]
ad <- getFirehoseAnalyzeDates()[1]
dd <- "./data"

newMAEO <- function(ds, rd, ad, dd) {
  if(!dir.exists(dd)) {
    dir.create(dd)
  }
  for(i in ds) {
    cn <- tolower(i)
    fp <- file.path(dd, paste0(cn, ".Rda"))
    if(file.exists(fp)) {
      load(fp)
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
      save(co, file = fp)
    }
    pd <- co@Clinical
    rownames(pd) <- gsub("\\.", "-", rownames(pd))
    pd <- type_convert(pd)
    targets <- c(slotNames(co)[c(5:16)], "gistica", "gistict")
    dataList <- lapply(targets, function(x) {try(TCGAextract(co, x))})
    names(dataList) <- targets
    dataFull <- Filter(function(x){class(x)!="try-error"}, dataList)
    ExpList <- Elist(dataFull)
    NewElist <- TCGAcleanExpList(ExpList, pd)
    NewMap <- TCGAgenerateMap(NewElist, pd)
    MAEOname <- paste0(cn, "MAEO")
    assign(paste0(cn, "MAEO"), MultiAssayExperiment(NewElist, pd, NewMap))
    save(list = MAEOname, file = file.path("./data", paste0(cn, "MAEO.Rda")))
  }
}

newMAEO(ds, rd, ad, dd)
