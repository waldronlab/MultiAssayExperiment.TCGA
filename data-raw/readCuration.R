library(readxl)
library(dplyr)

# Readlines from TXT file
ST = readLines("./data-raw/subtypes_curation.txt", n=51)

# Create a list of data.frames
dflist <- list()
for (i in seq(from=1, to=51, by=3)) {
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

# Use list of data.frames to extract relevant columns
subTypeFiles <- list.files(file.path("./inst", "extdata",
                                     "allsubtypes"), full.names = TRUE)

lapply(dflist[1], function(smalldf) {
    shortFileName <- names(smalldf)[2]
    diseaseCode <- gsub("\\.csv", "", shortFileName)
    xlDx <- gsub("\\.csv", "", basename(subTypeFiles)) %>% strsplit(., "_")
    xlIndex <- match(diseaseCode, xlDx)
    clinical <- read.csv(subTypeFiles[xlIndex], header = TRUE)
    clinical[, smalldf[[2]]]
})

clinfiles <- dir(file.path("./inst", "extdata", "Clinical"), full.names = TRUE)

