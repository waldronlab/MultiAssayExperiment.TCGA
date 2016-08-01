# load libraries
library(MultiAssayExperiment)
library(RTCGAToolbox)
library(BiocInterfaces)
library(readr)

# newMAEO variables
ds <- getFirehoseDatasets()[c(1:3, 4:5, 7:9, 12:14, 16:31, 33:38)]
rd <- getFirehoseRunningDates()[1]
ad <- getFirehoseAnalyzeDates()[1]
dd <- "data"

# write header row to csv file for unit tests
if(!file.exists("MAEOinfo.csv")) {
  header <- data.frame(cbind("cohort_name", "experiment_name", "experiment_class", "feature_number", "sample_number"))
  write.table(header, file = "MAEOinfo.csv", sep = ",", append = TRUE, row.names = FALSE, col.names = FALSE)
}

# newMAEO function definition
newMAEO <- function(ds, rd, ad, dd) {
  if(!dir.exists(dd)) {
    dir.create(dd)
  }
  
  for(i in ds) {
    message("\n######\n", "\nProcessing ", i, " : )\n", "\n######\n")
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
    
    pd <- co@Clinical
    rownames(pd) <- toupper(gsub("\\.", "-", rownames(pd)))
    pd <- type_convert(pd)
    targets <- c(slotNames(co)[c(5:16)], "gistica", "gistict")
    names(targets) <- targets
    dataList <- lapply(targets, function(x) {tryCatch({TCGAextract(co, x)}, error = function(e) {message(x, " does not contain any data!")})})
    dataFull <- Filter(function(x){class(x)!="NULL"}, dataList)
    assayNames <- names(dataFull)
    
    if("CNASNP" %in% assayNames) {
      source_file <- getFileNames("ACC", rd, CNA_SNP = TRUE)
      genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file, ignore.case = TRUE)
      genome(dataFull$CNASNP) <- genome_build
      source_file <- as.list(source_file)
      names(source_file) <- "source_file"
      metadata(dataFull$CNASNP) <- c(metadata(dataFull$CNASNP), source_file)
    }
    
    if("CNVSNP" %in% assayNames) {
      source_file <- getFileNames(i, rd, CNV_SNP = TRUE)
      genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file, ignore.case = TRUE)
      genome(dataFull$CNVSNP) <- genome_build
      source_file <- as.list(source_file)
      names(source_file) <- "source_file"
      metadata(dataFull$CNVSNP) <- c(metadata(dataFull$CNVSNP), source_file)
    }
    
    if("CNASeq" %in% assayNames) {
      source_file <- getFileNames(i, rd, CNA_Seq = TRUE)
      genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file, ignore.case = TRUE)
      genome(dataFull$CNASeq) <- genome_build
      source_file <- as.list(source_file)
      names(source_file) <- "source_file"
      metadata(dataFull$CNASeq) <- c(metadata(dataFull$CNASeq), source_file)
    }
    
    if("CNACGH" %in% assayNames) {
      source_file <- getFileNames(i, rd, CNA_CGH = TRUE)
      genome_build <- gsub("(^.+)_(hg[0-9]{2})_(.+$)", "\\2", x = source_file, ignore.case = TRUE)
      genome(dataFull$CNACGH) <- genome_build
      source_file <- as.list(source_file)
      names(source_file) <- "source_file"
      metadata(dataFull$CNACGH) <- c(metadata(dataFull$CNACGH), source_file)
    }
    
    ExpList <- ExperimentList(dataFull)
    NewElist <- TCGAcleanExpList(ExpList, pd)
    NewMap <- generateMap(NewElist, pd, TCGAbarcode)
    MAEO <- MultiAssayExperiment(NewElist, pd, NewMap)
    
    MAEOmeta <- c(i, rd, ad, sessionInfo())
    names(MAEOmeta)[1:3] <- c("cohort_name", "running_date", "analysis_data")
    metadata(MAEO) <- c(metadata(MAEO), MAEOmeta)
    
    saveRDS(MAEO, file = file.path(dd, paste0(cn, "MAEO.rds")), compress = "bzip2")
    
    # add lines to csv file for unit tests
    cohort_name <- rep(cn, length(experiments(MAEO)))
    experiment_name <- names(MAEO)
    experiment_class <- sapply(experiments(MAEO), class)
    feature_number <- sapply(experiments(MAEO), dim)[1,]
    sample_number <- sapply(experiments(MAEO), dim)[2,]
    MAEOinfo <- data.frame(cbind(cohort_name, experiment_name, experiment_class, feature_number, sample_number))
    write.table(MAEOinfo, file = "MAEOinfo.csv", sep = ",", append = TRUE, row.names = FALSE, col.names = FALSE)
  }
}

# call newMAEO function
newMAEO(ds, rd, ad, dd)
