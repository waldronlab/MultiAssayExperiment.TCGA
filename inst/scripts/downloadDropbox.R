## dataDirectories and getDiseaseCodes should be run first
dirList <- dataDirectories()
TCGAcode <- getDiseaseCodes()

## Download DropBox files
downloadDropbox <- function(dropBoxPaths, TCGAcode, dirList) {
    dataType <- deparse(substitute(dropBoxPaths))
    thePath <- switch(dataType,
                    BoxSubTypes = "subtypePath",
                    BoxClinicalData = "basicClinical",
                    BoxClinicalCuration = "clinicalCurationPath")
    fileNames <- gsub("TCGA_Variable_Curation_", "", basename(dropBoxPaths),
                      fixed = TRUE)
    dxCodes <- gsub(".csv|.xlsx", "", fileNames)
    files <- dropBoxPaths[dxCodes %in% TCGAcode]
    invisible(lapply(files, function(archive) {
        drop_get(archive, local_file = file.path(dirList[[thePath]],
                                                basename(archive)),
                overwrite = TRUE)
    }))
}

