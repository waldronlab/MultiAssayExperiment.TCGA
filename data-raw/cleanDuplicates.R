cleanDuplicates <- function(dataset) {
    ## Duplicate column names
    dupNames <- unique(names(dataset)[duplicated(names(dataset))])
    dupIdx <- match(dupNames, names(dataset))
    whichDups <- lapply(dupNames, function(duplicate, dat) {
        which(names(dat) %in% duplicate)
    }, dat = dataset)

    uniqueData <- lapply(dupNames, function(duplicate) {
        dups <- dataset[, which(names(dataset) %in% duplicate)]
        combos <- gtools::combinations(ncol(dups), 2L)
        isSame <- apply(combos, 1L, function(colNums) {
            identical(dups[[colNums[[1L]]]], dups[[colNums[[2L]]]])
        })
        equals <- combos[isSame, , drop = FALSE]
        repeatedCols <- unique(as.vector(equals))
        Filter(function(vec) {!is.na(vec)},
               c(setdiff(seq_along(dups), repeatedCols),
                  repeatedCols[1L]))
    })
    duplicateOmit <- mapply(function(x, y) {
        x[-y]
    }, x = whichDups, y = uniqueData,
    SIMPLIFY = TRUE)
    removalIdx <- unlist(duplicateOmit)
    if (length(removalIdx))
        dataset <- dataset[, -removalIdx, drop = FALSE]

    names(dataset) <- make.unique(names(dataset))
    dataset
}
