extraClinicalData <- function(diseaseCode) {
    adt <- "20151101"
    dset <- diseaseCode
    cl_url <- "http://gdac.broadinstitute.org/runs/stddata__"
    cl_url <- paste0(cl_url,substr(adt,1,4),"_",substr(adt,5,6),"_",substr(adt,7,8),"/data/")
    cl_url <- paste0(cl_url,dset,"/",adt,"/")
    cl_url <- paste0(cl_url, "gdac.broadinstitute.org_", dset, ".Merge_Clinical.Level_1.", adt, "00.0.0.tar.gz")

    download.file(url=cl_url, destfile=paste0(dset, "-ExClinical.tar.gz"), method="auto", quiet=TRUE, mode="w")
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
