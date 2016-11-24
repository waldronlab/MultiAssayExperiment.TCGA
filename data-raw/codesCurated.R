## small script for resolving TCGA curation codes available
## BiocInstaller::biocLite("waldronlab/BiocInterfaces")
source("data-raw/readDFList.R")
data("diseaseCodes")

dxCodes <- diseaseCodes[["Study.Abbreviation"]]
tbxCodes <- getFirehoseDatasets()

dput(setdiff(diseaseCodes[[1L]], tbxCodes))
codesNotInTbx <- c("CNTL", "LCML", "MISC")

dput(setdiff(tbxCodes, diseaseCodes[[1L]]))
codesNotInDxCodes <- c("COADREAD", "GBMLGG", "KIPAN", "STES")

excludeDatasets <- c(codesNotInTbx, codesNotInDxCodes, "FPPP")

includeDatasets <- dxCodes[!(dxCodes %in% excludeDatasets)]
names(includeDatasets) <- includeDatasets

## Disease codes for which we have subtype curation
## run script: readDFList.R
curationAvailable <- gsub(".csv", "", names(dflist), fixed = TRUE)
curationAvailable <- curationAvailable[!curationAvailable == "BRCA2"]

names(curationAvailable) <- curationAvailable

save(curationAvailable, file = "data/curationAvailable.rda")

