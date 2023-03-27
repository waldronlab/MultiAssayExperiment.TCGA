processClinicalFirehose <-
    function(diseaseCode, runDate = "20160128", force = FALSE)
{
    dirList <- dataDirectories()
    rawClinical <- dirList[["rawClinical"]]
    file.path(rawClinical,
        paste(runDate, diseaseCode, "Clinical.txt", sep = "-"))
    fileName <- file.path(rawClinical, paste0(diseaseCode, ".csv"))
    if (!file.exists(fileName) || force) {
        TCGAclin <- RTCGAToolbox::getFirehoseData(
            diseaseCode, runDate = runDate, clinical = TRUE,
            destdir = dirList[["rawClinical"]]
        )
        TCGAclin <- selectType(TCGAclin, "clinical")
        stdBarcodes <- .stdIDs(rownames(TCGAclin))
        TCGAclin <- cbind(patientID = stdBarcodes, TCGAclin)
        newFile <- file.path(dirList[["basicClinical"]],
            paste(runDate, paste0(diseaseCode, ".csv"), sep = "-"))
        readr::write_csv(TCGAclin, path = newFile)
    } else {
        message(fileName, " already downloaded and processed")
    }
}

## Write enhancedData to enhanced folder
writeClinicalData <-
    function(diseaseCode, runDate = "20160128", force=FALSE, path)
{
    fileName <-
        file.path(path, paste(runDate, paste0(diseaseCode, ".csv"), sep = "-"))
    if (!file.exists(fileName) || force) {
        dataset <- .mergeClinicalData(diseaseCode, runDate = runDate)
        readr::write_csv(dataset, file = fileName)
        message(diseaseCode, " with extra columns created")
    }
    message("\n", fileName, " available")
}

getClinicalData <- function(TCGAcodes, nworkers = multicoreWorkers()) {
    BiocParallel::bplapply(
        TCGAcodes,
        processClinicalFirehose,
        force = TRUE,
        BPPARAM = MulticoreParam(
            workers = nworkers,
            jobname = "getClinicalData"
        )
    )
}

downloadExtraClinical <- function(TCGAcodes) {
    enhancedPath <- dataDirectories()[["enhancedClinical"]]
    for (i in TCGAcodes) {
        writeClinicalData(i, force = TRUE, path = enhancedPath)
    }
}

downloadClinicalDrop <- function(TCGAcodes) {
    BoxClinicalData <-
        rdrop2::drop_dir("The Cancer Genome Atlas/Clinical/data")[["path"]]
    downloadDropbox(BoxClinicalData, TCGAcodes=TCGAcodes, dirList=dirList)
}

downloadSubtypeDrop <- function(TCGAcodes) {
    BoxSubTypes <-
        rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]]
    downloadDropbox(BoxSubTypes, TCGAcodes=TCGAcodes, dirList=dirList)
}

downloadDropbox <- function(dropBoxPaths, TCGAcodes, dirList) {
    dataType <- deparse(substitute(dropBoxPaths))
    thePath <- switch(dataType,
                    BoxSubTypes = "subtypePath",
                    BoxClinicalData = "basicClinical",
                    BoxClinicalCuration = "clinicalCurationPath")
    fileNames <- gsub("TCGA_Variable_Curation_", "", basename(dropBoxPaths),
                      fixed = TRUE)
    dxCodes <- gsub(".csv|.xlsx", "", fileNames)
    files <- dropBoxPaths[dxCodes %in% TCGAcodes]
    invisible(lapply(files, function(archive) {
        drop_get(archive, local_file = file.path(dirList[[thePath]],
                                                basename(archive)),
                overwrite = TRUE)
    }))
}

writeMergedClinical <-
    function(diseaseCode, runDate = "20160128", force = FALSE)
{
    dirList <- dataDirectories()
    mergedClinical <- dirList[["mergedClinical"]]
    fileName <- file.path(mergedClinical, paste(runDate,
                          paste0(diseaseCode, "_merged.csv"), sep = "-"))
    if (!file.exists(fileName) || force) {
        mergedData <- .mergeSubtypeClinical(diseaseCode, runDate = runDate)
        write_csv(x = mergedData, path = fileName)
        message(diseaseCode, " curation merged to clincial data!\n",
        "See: ", fileName)
    }
}

cleanMerged <-
    function(
        TCGAcodes, runDate = "20160128", force = FALSE,
        nworkers = multicoreWorkers()
    )
{
    mergedLoc <- dataDirectories()[["mergedClinical"]]
    BiocParallel::bplapply(TCGAcodes, FUN = function(diseaseCode) {
        fileName <- file.path(mergedLoc,
            paste(runDate, paste0(diseaseCode, "_reduced.csv"), sep = "-"))

        droppedFile <- file.path(mergedLoc,
            paste(runDate, paste0(diseaseCode, "_dropped.rds"), sep = "-"))

        if (!file.exists(fileName) || force) {
            fullClinical <- readr::read_csv(
                file.path(mergedLoc, paste(runDate, paste0(diseaseCode,
                    "_merged.csv"), sep = "-")))

            NACols <- .findNAColumns(fullClinical)
            droppedCols <- names(fullClinical)[NACols]

            if (!file.exists(droppedFile) || force) {
                saveRDS(
                    droppedCols,
                    file = file.path(mergedLoc, paste(
                        runDate, paste0(diseaseCode, "_dropped.rds"), sep = "-"
                    ))
                )
            }
            write_csv(fullClinical[, !NACols], path = fileName)
            message(diseaseCode, " saved at ", fileName)
        } else {
            message(diseaseCode, "_reduced.csv already available!")
        }
    },
    BPPARAM = MulticoreParam(workers = nworkers, jobname = "cleanMerged"))
}

### Merging subtype files with clinical data
mergeSubtypeCuration <- function(TCGAcodes) {
    BiocParallel::bplapply(TCGAcodes, writeMergedClinical)
}
