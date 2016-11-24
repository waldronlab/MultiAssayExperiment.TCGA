## Read and split curation to small data.frames

# Download from Dropbox
# rdrop2::drop_get("The Cancer Genome Atlas/Script/subtypes_curation.txt", local_file =
#                      "data-raw/subtypes_curation.txt", overwrite = TRUE)

# Readlines from TXT file downloaded from Dropbox
ST = readLines("data-raw/subtypes_curation.txt")

# Create a list of data.frames
dflist <- list()
for (i in seq(from=1, to=57, by=3)) {
    df = as.data.frame(strsplit(ST[c(i, i+1)], "\t"), stringsAsFactors = FALSE)
    colnames(df) = t(df[1, ])
    df = df[-1, ]
    df = df[!df[, 1] %in% "", ]
    dflist[[colnames(df)[2]]] = df
}

rm(df, ST)

dflist <- lapply(dflist, function(x) {
    x[[2]] <- gsub('"', "", x[[2]])
    x
})

