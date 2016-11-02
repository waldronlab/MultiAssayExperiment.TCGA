library(readr)
library(readxl)

blcaxl <- read_excel("data-raw/ExcelPreprocess/Copy of BLCA_Clinical_Data_Table_updated_supplement_2013-09-24.xlsx",
                     sheet = 1L)

## Duplicate column names
colsDupIdx <- which(duplicated(sort(names(blcaxl))))
dupCols <- cbind(first = colsDupIdx, second = colsDupIdx-1)

listDups <- apply(dupCols, 1, function(x) {
    dff <- blcaxl[,sort(names(blcaxl))]
    dff[x]
})

sortedNames <- sort(names(blcaxl))
dupNames <- sortedNames[duplicated(sortedNames)]
stopifnot(vapply(dupNames, FUN = function(named) {
    !(sum(names(blcaxl) %in% named) > 2)
}, FUN.VALUE = logical(1L)))

result <- cbind.data.frame(dupCols, identical =
                               vapply(listDups, FUN = function(dff) {
                                   identical(dff[[1L]], dff[[2L]])
                               }, FUN.VALUE = logical(1L)))

result <- subset(result, result[["identical"]])
clearNames <- sortedNames[-result[["second"]]]

processedBLCA <- blcaxl[, clearNames]

## save as csv file for upload
write_csv(processedBLCA, path = "data-raw/ExcelPreprocess/BLCA.csv")

rdrop2::drop_upload("data-raw/ExcelPreprocess/BLCA.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
