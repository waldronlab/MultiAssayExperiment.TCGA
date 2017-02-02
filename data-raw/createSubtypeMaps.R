## Write data.frame list to files
source("data-raw/subtypeMaps.R")

invisible(
    lapply(seq_along(subtypeMaps),
           function(i, disease, data) {
               readr:::write_csv(x = data[[i]],
                         path = file.path("inst", "extdata",
                                          "curatedSubtypes", "curatedMaps",
                                          paste0(disease[[i]],
                                                 "_subtypeMap.csv")))
           }, disease = names(subtypeMaps),
           data = subtypeMaps))

curationAvailable <- names(subtypeMaps)
# save(curationAvailable, file = "data/curationAvailable.rda")
