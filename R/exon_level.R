## Downloading bt.exon_quantification files from TCGA
library(TCGAbiolinks)
library(TCGAmisc)

data("diseaseCodes")
goodDatasets <- diseaseCodes$Study.Abbreviation
badDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL")
goodDatasets <- goodDatasets[!goodDatasets %in% badDatasets]

dataFolder <- "/scratch/TCGAbt/"

lapply(goodDatasets, function(disease) {
   cancer <- TCGAquery(tumor = disease, platform = "IlluminaHiSeq_RNASeqV2",
                       level = 3)
   dir.create(file.path(dataFolder, disease), recursive = TRUE)
   TCGAdownload(cancer, path = file.path(dataFolder, disease), type = "bt.exon_quantification")
})

diseaseFolders <- dir(file.path(dataFolder), full.names = TRUE)
downloadedDx <- basename(diseaseFolders)

TCGAexons <- lapply(diseaseFolders, readExonFiles)
names(TCGAexons) <- downloadedDx
