## Script for checking subtype curation
library(readxl)
library(readr)
library(dplyr)

# Readlines from TXT file
ST = readLines("./data-raw/subtypes_curation.txt")

# Create a list of data.frames
dflist <- list()
for (i in seq(from=1, to=57, by=3)) {
    print(i)
    df = as.data.frame(strsplit(ST[c(i, i+1)], "\t"), stringsAsFactors = FALSE)
    colnames(df) = t(df[1, ])
    df = df[-1, ]
    df = df[!df[, 1] %in% "", ]
    dflist[[colnames(df)[2]]] = df
}

dflist <- lapply(dflist, function(x) {
    x[[2]] <- gsub('"', "", x[[2]])
    x
})

invisible(lapply(seq_along(dflist), function(i, disease, data) {
    write_csv(x = data[[i]],
              path = file.path("inst", "extdata", "curatedSubtypes", "curatedMaps",
                               paste0(disease[[i]], "_subtypeMap.csv")))
}, disease = gsub(".csv", "", names(dflist)),
data = dflist))
