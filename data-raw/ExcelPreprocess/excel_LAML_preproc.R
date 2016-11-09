library(readr)
library(readxl)
source("data-raw/cleanDuplicates.R")

mRNA_laml <- read_excel("data-raw/ExcelPreprocess/TCGA.LAML.cNMF-clustering.20140820.xlsx", sheet="mRNA-seq (n=179)")
miRNA_laml <- read_excel("data-raw/ExcelPreprocess/TCGA.LAML.cNMF-clustering.20140820.xlsx", sheet="miRNA-seq (n=187)")

names(miRNA_laml) <- gsub(" +", "", names(miRNA_laml))

names(mRNA_laml) <- gsub("cluster", "mRNA", fixed = TRUE, names(mRNA_laml))
names(miRNA_laml) <- gsub("cluster", "microRNA", fixed = TRUE,
                          names(miRNA_laml))
names(miRNA_laml)[4L] <- paste0(names(miRNA_laml)[4], ".miRNA")
names(mRNA_laml)[4L] <- paste0(names(mRNA_laml)[4], ".mRNA")

processedLAML <- merge(mRNA_laml, miRNA_laml, by = "sample.id")

write_csv(x = processedLAML, path = "inst/extdata/allsubtypes/LAML.csv")


rdrop2::drop_upload("inst/extdata/allsubtypes/LAML.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)

