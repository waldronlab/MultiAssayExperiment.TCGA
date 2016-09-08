library(readxl)
library(dplyr)

# Readlines from TXT file
ST = readLines("./data-raw/Subtypes.txt")

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

# Use list of data.frames to extract relevant columns
subTypeFiles <- list.files(file.path("./inst", "extdata",
                                     "allsubtypes"), full.names = TRUE)
names(subTypeFiles) <- basename(subTypeFiles)
subtypes <- lapply(subTypeFiles, function(x) {
  print(basename(x))
  read.csv(x, header = TRUE)
})

dflist <- dflist[names(subtypes)]


## How to figure out which datasets don't have matching columns
## List of lists (each inner list has names in dataset and names that were
## supposed to match)
Filter(function(x) !is.null(x), mapply(function(dfs, annotes){
    targetColumns <- make.names(annotes[[2]])
    if (!all(targetColumns %in% names(dfs)))
        return(list(df_names = sort(names(dfs)),
                    target_names = sort(
                        targetColumns[!targetColumns %in% names(dfs)])))
}, dfs = subtypes, annotes = dflist, SIMPLIFY = FALSE))

## Code to subset relevant columns (dflist needs barcode column)
## Not working due to mismatches
mapply(function(dfs, annotes) {
  targetColumns <- make.names(annotes[[2]])
  if (!all(targetColumns %in% names(dfs)))
    warning(names(annotes), " don't match")
  return(dfs[, targetColumns])
}, dfs = subtypes, annotes = dflist, SIMPLIFY = FALSE)

