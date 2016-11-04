cleanDuplicates <- function(dataset) {
    ## Duplicate column names
    dupNames <- names(dataset)[duplicated(names(dataset))]
    dupIdx <- which(duplicated(names(dataset)))

    ## Ensure only duplicated once
    stopifnot(vapply(dupNames, FUN = function(named) {
        !(sum(names(dataset) %in% named) > 2)
    }, FUN.VALUE = logical(1L)))

    sortColsDupIdx <- which(duplicated(sort(names(dataset))))
    sortColsDupNames <- sort(names(dataset))[duplicated(sort(names(dataset)))]
    dupCols <- cbind(first = sortColsDupIdx-1, second = sortColsDupIdx)

    listDups <- apply(dupCols, 1, function(x) {
        dff <- dataset[,sort(names(dataset))]
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
    clearNames <- rev(rev(names(dataset))[-match(rownames(result),
                                                 rev(names(dataset)))])
    dataset[, clearNames]
}
