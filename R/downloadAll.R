# Author: Lucas Schiffer
# install devtools
install.packages("devtools", repos = "http://cran.r-project.org")

# install bioconductor
source("https://bioconductor.org/biocLite.R")
biocLite()

# install MultiAssayExperiment
BiocInstaller::biocLite("schifferl/MultiAssayExperiment")
library(MultiAssayExperiment)

# install RTCGAToolbox
BiocInstaller::biocLite("schifferl/RTCGAToolbox")
library(RTCGAToolbox)

# install BiocInterfaces
BiocInstaller::biocLite("waldronlab/BiocInterfaces")
library(BiocInterfaces)

# newMAEO variables
ds <- getFirehoseDatasets()[c(1:5, 7:9, 12:14, 16:31, 33:38)]
rd <- getFirehoseRunningDates()[1]
ad <- getFirehoseAnalyzeDates()[1]

mergedDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL")
availDatasets <- getFirehoseDatasets()[!(getFirehoseDatasets() %in% mergedDatasets)]
dataFolder <- "./rawdata/"

# newMAEO function
newMAEO <- function(datasets, rundate, analyzedate, datadir) {
  # dd <- paste(getwd(), "/data", sep = "")
  if(!dir.exists(datadir)){
    dir.create(datadir)
  }
  for(i in datasets) {
    cn <- tolower(i)
    fp <- file.path(datadir, paste0(cn, ".Rda"))
    if(file.exists(fp)) {
      load(fp)
    } else {
      co <- getFirehoseData(i, runDate = rundate, gistic2_Date = analyzedate, RNAseq_Gene = TRUE,
                            Clinic = TRUE, miRNASeq_Gene = TRUE, RNAseq2_Gene_Norm = TRUE,
                            CNA_SNP = TRUE, CNV_SNP = TRUE, CNA_Seq = TRUE, CNA_CGH = TRUE,
                            Methylation = TRUE, Mutation = TRUE, mRNA_Array = TRUE, miRNA_Array = TRUE,
                            RPPA = TRUE, RNAseqNorm = TRUE, RNAseq2Norm = TRUE, forceDownload = FALSE,
                            destdir = datadir, fileSizeLimit = 500000, getUUIDs = FALSE)
      save(co, file = fp)
    }
    # pd <- DataFrame(TCGAextract(co, NULL, clinical = TRUE))
    pd <- co@Clinical
    rownames(pd) <- BiocInterfaces::TCGAbarcode(rownames(pd))
    el <- list()
    nl <- list()
    targets <- c(slotNames(co)[c(5:16)], "gistica", "gistict")
    for(i in targets) {
      push2el <- TRUE
      tryCatch({
        assign(i, BiocInterfaces::TCGAextract(co, i))
      }, error = function(e) {
        push2el <<- FALSE
      }, finally = {
        if(push2el == TRUE){
          nl <- c(nl, i)
          el <- c(el, get(i))
        }
      })
    }
    names(el) <- nl
    # pd <- BiocInterfaces::TCGAmatchClinical(el, pd)
    nel <- Elist(el)
    cel <- BiocInterfaces::TCGAcleanExpList(nel, pd)
    map <- BiocInterfaces::TCGAgenerateMap(cel, pd)
    MAEOname <- paste(cn, "MAEO", sep = "")
    assign(paste(cn, "MAEO", sep = ""), MultiAssayExperiment(Elist = cel, pData = pd, sampleMap = map),
           envir = .GlobalEnv)
    # cat(get(MAEOname), file=file.path(datadir, "MAEOlist.txt"), sep="\n")
    # save(list = MAEOname, file = file.path(datadir, paste0(cn, "MAEO.Rda")))
  }
}

# call newMAEO
newMAEO(availDatasets, rd, ad, dataFolder)
