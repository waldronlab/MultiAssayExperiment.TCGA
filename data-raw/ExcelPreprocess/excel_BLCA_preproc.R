library(readr)
library(readxl)

blcaxl <- read_excel("data-raw/ExcelPreprocess/Copy of BLCA_Clinical_Data_Table_updated_supplement_2013-09-24.xlsx",
                     sheet = 1L)

## Duplicate column names
dupNames <- names(blcaxl)[duplicated(names(blcaxl))]
dupIdx <- which(duplicated(names(blcaxl)))

## Ensure only duplicated once
stopifnot(vapply(dupNames, FUN = function(named) {
    !(sum(names(blcaxl) %in% named) > 2)
}, FUN.VALUE = logical(1L)))

sortColsDupIdx <- which(duplicated(sort(names(blcaxl))))
sortColsDupNames <- sort(names(blcaxl))[duplicated(sort(names(blcaxl)))]
dupCols <- cbind(first = sortColsDupIdx-1, second = sortColsDupIdx)

listDups <- apply(dupCols, 1, function(x) {
    dff <- blcaxl[,sort(names(blcaxl))]
    dff[x]
})

names(listDups) <- sortColsDupNames

result <- cbind.data.frame(dupCols, identical =
                               vapply(listDups, FUN = function(dff) {
                                   identical(dff[[1L]], dff[[2L]])
                               }, FUN.VALUE = logical(1L)),
                           row.names = names(listDups))

## Return only rows that have identical data in them
result <- subset(result, result[["identical"]])

## Keep order and variables that appear first (match reversed names)
clearNames <- rev(rev(names(blcaxl))[-match(rownames(result),
                                            rev(names(blcaxl)))])

processedBLCA <- blcaxl[, clearNames]

## save as csv file for upload
write_csv(processedBLCA, path = "data-raw/ExcelPreprocess/BLCA.csv")

rdrop2::drop_upload("data-raw/ExcelPreprocess/BLCA.csv",
                    dest = "The Cancer Genome Atlas/Script/allsubtypes/",
                    overwrite = TRUE)
