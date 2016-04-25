## Downloading bt.exon_quantification files from TCGA

library(TCGAbiolinks)
## Include disease codes table
library(TCGAmisc)
data("diseaseCodes")
diseaseCodes$Study.Abbreviation


cancers <- TCGAquery(tumor = "prad", platform = "IlluminaHiSeq_RNASeqV2",
                  level = 3)
