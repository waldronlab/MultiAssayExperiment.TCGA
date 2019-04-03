## Read and split curation to small data.frames

# Download from Dropbox
# rdrop2::drop_download("The Cancer Genome Atlas/Script/subtypes_curation.txt",
#    local_path = "subtypes_curation.txt", overwrite = TRUE)

# Readlines from TXT file downloaded from Dropbox
ST <- readLines("subtypes_curation.txt")

# Create a list of data.frames
subMap <- list()
for (i in seq(from=1, to=57, by=3)) {
    df <- as.data.frame(strsplit(ST[c(i, i+1)], "\t"), stringsAsFactors = FALSE)
    colnames(df) = t(df[1, ])
    df <- df[-1, ]
    diseaseCode <- gsub(".csv", "", colnames(df)[[2]])
    colnames(df) <- gsub(".csv", "_subtype", colnames(df))
    df <- df[!df[, 1] %in% "", ]
    subMap[[diseaseCode]] <- df
}

rm(df, ST)

subtypeMaps <- lapply(subMap, function(x) {
    x[[2]] <- gsub('"', "", x[[2]])
    x
})

