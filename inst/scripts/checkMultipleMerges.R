library(TCGAutils)
devtools::load_all("~/Documents/github/TCGAutils")

brcaList <-
    list.files("~/Documents/github/MultiAssayExperiment-TCGA/data/raw/BRCA",
        full.names = TRUE)
brcaNames <- vapply(strsplit(basename(brcaList), "_"), `[`, character(1L), 2)
brcaNames <- vapply(strsplit(brcaNames, "-"), `[`, character(1L), 1)
names(brcaList) <- brcaNames

brcaList <- brcaList[ -which(names(brcaList) == "Methylation")]

## TEST
brcaList <- brcaList[3L]
brcaActual <- brcaList
names(brcaActual) <- basename(brcaList)
brcaActual <- lapply(brcaActual, readRDS)

mergeIdxBRCA <- lapply(seq_along(brcaActual), function(i, dataTab) {
    type <- strsplit(names(dataTab[i]), "_|-")
    type <- vapply(type, function(x) { x[[2L]] }, character(1L))
    dataObject <- .removeShell(dataTab[[i]], type)
    if (is.list(dataObject) && !is.data.frame(dataObject)) {
    dataList <- .unNestList(dataObject)
    if (length(dataList) > 1L) {
    compareDF <- .compareListElements(dataList)
    TCGAutils:::.getMergeIndices(compareDF)
    } else { return(NULL) }
    } else { return(NULL) }
}, dataTab = brcaActual)

