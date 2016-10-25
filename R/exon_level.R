## Downloading bt.exon_quantification files from TCGA
library(TCGAbiolinks)

source("R/getDiseaseCodes.R")

availDatasets <- getDiseaseCodes()

## Code not working due to changes in TCGA

## TODO: Look at Legacy Archive for autodownload

# dataFolder <- "/scratch/TCGAbt/"

# lapply(availDatasets, function(disease) {
#    cancer <- TCGAquery(tumor = disease, platform = "IlluminaHiSeq_RNASeqV2",
#                        level = 3)
#    dir.create(file.path(dataFolder, disease), recursive = TRUE)
#    TCGAdownload(cancer, path = file.path(dataFolder, disease), type = "bt.exon_quantification")
# })
#
# diseaseFolders <- dir(file.path(dataFolder), full.names = TRUE)
# downloadedDx <- basename(diseaseFolders)
# names(diseaseFolders) <- downloadedDx
#
# TCGAexons <- lapply(diseaseFolders, TCGAexonToGRangesList)
