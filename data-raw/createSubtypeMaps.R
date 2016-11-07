## Write data.frame list to files
source("data-raw/readDFList.R")

invisible(
    lapply(seq_along(dflist),
           function(i, disease, data) {
               write_csv(x = data[[i]],
                         path = file.path("inst", "extdata",
                                          "curatedSubtypes", "curatedMaps",
                                          paste0(disease[[i]],
                                                 "_subtypeMap.csv")))
           }, disease = gsub(".csv", "", names(dflist)),
           data = dflist))

curationAvailable <- gsub(".csv", "", names(dflist), fixed = TRUE)
