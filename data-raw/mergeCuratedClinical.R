library(readr)

## Merge two vectors keeping left-hand side
mergeVecs <- function(x1, x2, prioritize=TRUE) {
  ##x1 and x2 are vectors to be merged.
  ##x1 will be over-written by x2, and in case of conflict, x2 takes priority
  if(!identical(length(x1), length(x2))) stop("x1 and x2 must have the same length")
  if(!identical(class(x1), class(x2))) stop("x1 and x2 must have the same class")
  x1[is.na(x1)] = x2[is.na(x1)]
  mismatches <- which(x1 != x2)
  if(length(mismatches) > 0){
    if(prioritize){
      x1[mismatches] = x2[mismatches]
    }else{
      warning(paste("There were mismatches in positions:",
                    paste0(mismatches, collapse=", ")))
      x1[mismatches] = paste(x1[mismatches], x2[mismatches], sep="///")
    }
  }
  return(x1)
  ## mergeVecs(x1=c(1, 2, 3, NA), x2=c(2, 2, NA, 4), prioritize=TRUE)
  ## mergeVecs(x1=c(1, 2, 3, NA), x2=c(2, 2, NA, 4), prioritize=FALSE)
}

diseaseCode <- "BRCA"
filePath <- paste0("./inst/extdata/TCGA_Curation_Cancer_Types/TCGA_Variable_Curation_", diseaseCode, ".xlsx")
curatedLines <- readxl::read_excel(path = filePath, na = " ", sheet = 1L)
names(curatedLines) <- make.names(names(curatedLines))

clinicalData <- readr::read_csv(paste0("inst/extdata/Clinical/", diseaseCode, ".csv"))

rowToDataFrame <- function(DataFrame) {
  columnIndex <- seq_len(which(names(DataFrame) == "Priority")-1)
  dplyr::data_frame(variable = as.character(DataFrame[columnIndex]),
             priority = as.character(DataFrame[-columnIndex]))
}

listDF <- apply(curatedLines, 1, rowToDataFrame)
listDF <- lapply(listDF, na.omit)
listDF1 <- Filter(function(x) {nrow(x) > 1}, listDF)
listDF2 <- lapply(listDF1, function(df) {
    df <- type_convert(df, cols(
        variable = col_character(),
        priority = col_integer()
    ))
    df
})

listDF3 <- lapply(listDF2, function(df) {
    df[order(df[["priority"]]), ]
})

## check all names in curatedLines are in clinicalData
curatedLinesNames <- unlist(lapply(listDF3, FUN = function(df) df[["variable"]]))
missingColumns <- curatedLinesNames[!curatedLinesNames %in% names(clinicalData)]

listDF4 <- lapply(listDF3, function(df) {
    df[!df[["variable"]] %in% missingColumns,]
})

clinicalDFL <- lapply(listDF4, function(df) {
    clinicalData[, df[["variable"]]]
})

## Not working, columns of different type
lapply(clinicalDFL, function(df) {
    Reduce(mergeVecs, df)
})
