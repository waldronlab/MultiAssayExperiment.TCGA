## Read datasets
source("R/getDiseaseCodes.R")

TCGAcodes <- getDiseaseCodes()

updateInfo <- function(diseaseCode) {
    maeoFile <- paste0(tolower(diseaseCode), "MAEO.rds")
    location <- "data/built"
    builtMAEO <- file.path(location, maeoFile)
header <- cbind.data.frame("cancerCode", "assay", "class", "nrow", "ncol")
write.table(header = file = "MAEOinfo.csv", sep = ",", append = TRUE,
    row.names = FALSE, col.names = FALSE)
## TODO: add function to main pipeline
}
