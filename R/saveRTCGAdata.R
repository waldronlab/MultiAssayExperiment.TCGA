saveRTCGAdata <- function(runDate, diseaseCode, dataType = c("RNAseq_Gene",
    "miRNASeq_Gene", "RNAseq2_Gene_Norm", "CNA_SNP", "CNV_SNP", "CNA_Seq",
    "CNA_CGH", "Methylation", "Mutation", "mRNA_Array", "miRNA_Array",
    "RPPA_Array", "GISTIC"), analyzeDate, directory, force = FALSE) {
    if (!dir.exists(directory))
        dir.create(directory)
    choices <- match.arg(dataType, c("RNAseq_Gene", "miRNASeq_Gene",
        "RNAseq2_Gene_Norm", "CNA_SNP", "CNV_SNP", "CNA_Seq", "CNA_CGH",
        "Methylation", "Mutation", "mRNA_Array", "miRNA_Array", "RPPA_Array",
        "GISTIC"), several.ok = TRUE)
    for(dataType in choices) {
        dataTypeName <- gsub("_", "", dataType)
        rdsPath <- file.path(directory, paste0(runDate, "-",
            diseaseCode, "_", dataTypeName, ".rds"))
        if (!file.exists(rdsPath) || force) {
            gistic <- grepl("^GIST", dataType, ignore.case = TRUE)
            if (gistic) {
                dateType <- "gistic2_Date"
                args <- list(diseaseCode, analyzeDate)
                names(args) <- c("dataset", dateType)
            } else {
                dateType <- "runDate"
                args <- list(diseaseCode, runDate, TRUE)
                names(args) <- c("dataset", dateType, dataType)
            }
                dataPiece <- do.call(getFirehoseData, args = c(
                    list(Clinic = FALSE, destdir = "./tmp",
                         fileSizeLimit = 500000), args))
                saveRDS(dataPiece, file = rdsPath, compress = "bzip2")
                message(basename(rdsPath), " saved in ", dirname(rdsPath))
        } else { message(diseaseCode, "_", dataType, " data exists") }
    }
}
