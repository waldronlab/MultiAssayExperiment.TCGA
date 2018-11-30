saveRTCGAdata <- function(runDate = "20160128", diseaseCode,
    dataType = c("RNASeqGene", "miRNASeqGene", "RNASeq2GeneNorm", "CNASNP",
    "CNVSNP", "CNASeq", "CNACGH", "Methylation", "Mutation", "mRNAArray",
    "miRNAArray", "RPPAArray", "GISTIC"), analyzeDate = "20160128", directory,
    force = FALSE) {
    if (!dir.exists(file.path(directory, diseaseCode)))
        dir.create(file.path(directory, diseaseCode), recursive = TRUE)
    choices <- match.arg(dataType, c("RNASeqGene", "miRNASeqGene",
        "RNASeq2GeneNorm", "CNASNP", "CNVSNP", "CNASeq", "CNACGH",
        "Methylation", "Mutation", "mRNAArray", "miRNAArray", "RPPAArray",
        "GISTIC"), several.ok = TRUE)
    for(dataType in choices) {
        rdsPath <- file.path(directory, diseaseCode, paste0(diseaseCode, "_",
            dataType, "-", runDate, ".rds"))
        if (!file.exists(rdsPath) || force) {
            gistic <- grepl("^GIST", dataType, ignore.case = TRUE)
            if (gistic) {
                dateType <- "gistic2Date"
                args <- list(diseaseCode, analyzeDate, TRUE)
                names(args) <- c("dataset", dateType, dataType)
            } else {
                dateType <- "runDate"
                args <- list(diseaseCode, runDate, TRUE)
                names(args) <- c("dataset", dateType, dataType)
            }
                dataPiece <- do.call(RTCGAToolbox::getFirehoseData, args = c(
                    list(clinical = FALSE, destdir = "./tmp",
                         fileSizeLimit = 500000), args))
                saveRDS(dataPiece, file = rdsPath, compress = "bzip2")
                message(basename(rdsPath), " saved in ", dirname(rdsPath))
        } else { message(diseaseCode, "_", dataType, " data exists") }
    }
}
