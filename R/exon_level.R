## Downloading bt.exon_quantification files from TCGA
library(TCGAbiolinks)
library(BiocInterfaces)

data("diseaseCodes")
availDatasets <- diseaseCodes$Study.Abbreviation
mergedDatasets <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL")
availDatasets <- availDatasets[!availDatasets %in% mergedDatasets]

dataFolder <- "/scratch/TCGAbt/"

lapply(availDatasets, function(disease) {
   cancer <- TCGAquery(tumor = disease, platform = "IlluminaHiSeq_RNASeqV2",
                       level = 3)
   dir.create(file.path(dataFolder, disease), recursive = TRUE)
   TCGAdownload(cancer, path = file.path(dataFolder, disease), type = "bt.exon_quantification")
})

diseaseFolders <- dir(file.path(dataFolder), full.names = TRUE)
downloadedDx <- basename(diseaseFolders)

TCGAexons <- lapply(diseaseFolders, TCGAexonToGRangesList)
names(TCGAexons) <- downloadedDx
