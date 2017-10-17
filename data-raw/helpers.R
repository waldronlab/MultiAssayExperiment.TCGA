## Source dataDirectories function
source("R/dataDirectories.R")
load("data/curationAvailable.rda")

## Helper function for reading clinical variable curation files
.readClinicalCuration <- function(diseaseCode) {
    clinicalCuration <- dataDirectories()[["clinicalCurationPath"]]
    curatePrefix <- "TCGA_Variable_Curation_"
    stopifnot(S4Vectors::isSingleString(diseaseCode))
    curatedFile <- readxl::read_excel(file.path(clinicalCuration,
                                                paste0(curatePrefix,
                                                       diseaseCode,
                                                       ".xlsx")), na = " ",
                                      sheet = 1L)
    names(curatedFile) <- make.names(names(curatedFile))
    curatedFile
}

## Read clinical data from file location
.readClinical <- function(diseaseCode, runDate, dataDir=NULL) {
    if (is.null(dataDir))
        stop("provide data directory name from dataDirectories()")
    clinicalLoc <- dataDirectories()[[dataDir]]
    clinicalData <- readr::read_csv(
        file.path(clinicalLoc, paste(runDate,
                                     paste0(diseaseCode,
                                            if (dataDir == "mergedClinical") {
                                                "_merged.csv"
                                            } else { ".csv" } ),
                                     sep = "-")
        ))
    clinicalData
}

## Helper function stipulation:
## * Column lengths must be the same in "Variables" and "Priority"
.rowToDataFrame <- function(singleRowDF) {
    priorityIndex <- match("priority", tolower(names(singleRowDF)))
    stopifnot(!is.na(priorityIndex), length(priorityIndex) == 1L,
              priorityIndex != 0L)
    columnRange1 <- seq_len(priorityIndex-1)
    columnRange2 <- columnRange1 + rev(columnRange1)
    data.frame(variable = as.character(singleRowDF[columnRange1]),
               priority = as.integer(singleRowDF[columnRange2]),
               stringsAsFactors = FALSE)
}

## Helper for finding barcode column
## **Takes the first result!**
.findBarcodeCol <- function(DF) {
    apply(DF, 2, function(column) {
        logicBCode <- grepl("^TCGA", column)
        logicBCode
    }) %>% apply(., 2, all) %>% Filter(isTRUE, .) %>% names %>% `[[`(1L)
}

## Download Subtype file from allsubtypes
.getSubtypeFile <- function(diseaseCode, overwrite=TRUE) {
    invisible(BoxSubTypes <-
                  rdrop2::drop_dir("The Cancer Genome Atlas/Script/allsubtypes")[["path"]])
    subtypePath <- dataDirectories()[["subtypePath"]]
    subtypeFile <- BoxSubTypes[grepl(paste0(diseaseCode, ".csv"),
                                     basename(BoxSubTypes), fixed = TRUE)]
    if (rdrop2::drop_get(subtypeFile, local_file =
                         file.path(subtypePath, basename(subtypeFile)),
                         overwrite = overwrite))
        message("download successful")
}

## Download Clinical Curation File
.getClinicalFile <- function(diseaseCode, overwrite=TRUE) {
    invisible(BoxClinicalCuration <-
                  drop_dir("The Cancer Genome Atlas/TCGA_Clinical_Curation")[["path"]])
    clinicalCurationPath <- dataDirectories()[["clinicalCurationPath"]]
    clinicalFile <-
        BoxClinicalCuration[grepl(paste0("TCGA_Variable_Curation_",
                                         diseaseCode, ".xlsx"),
                                  basename(BoxClinicalCuration))]
    if (rdrop2::drop_get(clinicalFile,
                         local_file = file.path(clinicalCurationPath,
                                                basename(clinicalFile)),
                         overwrite = overwrite))
        message("download successful")
}


## Helper to read small df - subtypeMap
.readSubtypeMap <- function(diseaseCode) {
    subtypeMapFile <- file.path(dataDirectories()[["curatedMaps"]],
                                paste0(diseaseCode, "_subtypeMap.csv"))
    readr::read_csv(subtypeMapFile)
}

## Helper to read original subtype file
.readSubtypeData <- function(diseaseCode) {
    subtypeDataFile <- file.path(dataDirectories()[["subtypePath"]],
                                 paste0(diseaseCode, ".csv"))
    subtypeData <- readr::read_csv(subtypeDataFile)
    names(subtypeData) <- make.names(names(subtypeData))
    subtypeData
}

## Download extra columns from BROAD
.downloadExtraClinical <- function(diseaseCode, runDate) {
    adt <- runDate
    dset <- diseaseCode
    cl_url <- "http://gdac.broadinstitute.org/runs/stddata__"
    cl_url <- paste0(cl_url, substr(adt, 1, 4), "_", substr(adt, 5, 6),
                     "_", substr(adt, 7, 8), "/data/")
    cl_url <- paste0(cl_url,dset,"/",adt,"/")
    cl_url <- paste0(cl_url, "gdac.broadinstitute.org_", dset,
                     ".Merge_Clinical.Level_1.", adt, "00.0.0.tar.gz")

    download.file(url=cl_url, destfile=paste0(dset, "-ExClinical.tar.gz"),
                  method="auto", quiet=TRUE, mode="w")
    fileList <- untar(paste0(dset, "-ExClinical.tar.gz"), list=TRUE)
    fileList <- grep(".clin.merged.txt", fileList, fixed = TRUE, value=TRUE)
    untar(paste0(dset,"-ExClinical.tar.gz"),files=fileList)
    filename <- paste0(adt,"-",dset,"-ExClinical.txt")
    file.rename(from=fileList,to=filename)
    file.remove(paste0(dset,"-ExClinical.tar.gz"))
    unlink(strsplit(fileList[1],"/")[[1]][1], recursive = TRUE)
    extracl <- data.table::fread(filename, data.table=FALSE, na.strings = "<NA>")
    file.remove(filename)
    colnames(extracl)[-1] <- extracl[grep("patient_barcode", extracl[, 1]),][-1]
    rownames(extracl) <- extracl[, 1]
    extracl <- extracl[,-1]
    extracl <- as.data.frame(t(extracl), stringsAsFactors = FALSE)
    colnames(extracl) <- tolower(colnames(extracl))
    rownames(extracl) <- toupper(rownames(extracl))
    if (requireNamespace("readr", quietly = TRUE)) {
        extracl <- readr::type_convert(extracl)
    }
    extracl <- extracl[,!grepl("patient_barcode", colnames(extracl))]
    extracl
}

## Standardize barcode format
.stdIDs <- function(patientID) {
    if (grepl("\\.", sample(patientID, 1L)))
        patientID <- gsub("\\.", "-", patientID)
    toupper(patientID)
}

## Merge basic clinical and extra to create enhanced
.mergeClinicalData <- function(diseaseCode, runDate) {
    basicClinical <- .readClinical(diseaseCode, runDate, "basicClinical")
    idName <- grep("patientID", names(basicClinical), ignore.case = TRUE,
                   value = TRUE)
    stopifnot(S4Vectors::isSingleString(idName))
    patientIDs <- basicClinical[[idName]]
    patientIDs <- .stdIDs(patientIDs)
    basicClinical <- as.data.frame(basicClinical, stringsAsFactors=FALSE)
    rownames(basicClinical) <- patientIDs
    extraClinical <- .downloadExtraClinical(diseaseCode, runDate)
    enhancedClinical <- merge(basicClinical, extraClinical, "row.names")
    enhancedClinical$patientID <- enhancedClinical[["Row.names"]]
    enhancedClinical <-
        enhancedClinical[, -na.omit(match(c("Row.names",
                                            "Composite Element REF"),
                                          names(enhancedClinical)))]
    enhancedClinical
}

## Pull subtype column from original supplemental data
.extractCurationColumns <- function(diseaseCode) {
    subtypeMap <- .readSubtypeMap(diseaseCode)
    subtypeData <- .readSubtypeData(diseaseCode)
    targetColumns <- make.names(subtypeMap[[2L]])
    stopifnot(all(targetColumns %in% names(subtypeData)))
    subtypeData[, targetColumns, drop = FALSE]
}

## Fix barcodes that are inconsistent
.curateBarcodes <- function(diseaseCode) {
    subtypeData <- .readSubtypeData(diseaseCode)
    bcode <- .findBarcodeCol(subtypeData)
    if (length(bcode)) {
        subtypeData[[bcode]] <- .stdIDs(subtypeData[[bcode]])
    }
    subtypeData
}

## Read clinical and merge subtype information
.mergeSubtypeClinical <- function(diseaseCode, runDate, curationAvailable) {
    clinicalData <-
        readr::read_csv(
            file.path(
                dataDirectories()[["enhancedClinical"]],
                paste(runDate, paste0(diseaseCode, ".csv"), sep = "-")
            )
        )
    if (diseaseCode %in% curationAvailable) {
        subtypeCuration <- .readSubtypeData(diseaseCode)
        BarcodeColName <- .findBarcodeCol(subtypeCuration)
        subtypeCuration[, BarcodeColName] <-
            TCGAutils::TCGAbarcode(subtypeCuration[[BarcodeColName]])
        clinicalData <- merge(clinicalData, subtypeCuration,
                              by.x = "patientID", by.y = BarcodeColName,
                              all = TRUE, sort = FALSE)
    }
    clinicalData
}

## Find columns that are all NA
.findNAColumns <- function(dataset) {
    apply(dataset, 2, function(column) {
              all(is.na(column))
                              })
}

## Clean and take second element from string split
.cleanFileNames <- function(fileNames, splitDelim, position) {
    fileNames <- gsub("\\.rd[as]", "", basename(fileNames))
    strsplit(fileNames, splitDelim) %>% vapply(., `[`, character(1L), position)
}

