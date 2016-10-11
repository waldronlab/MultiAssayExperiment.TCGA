##Needed function
mergeVecs <- function(x1, x2, prioritize=TRUE){
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

curatedLines <- readxl::read_excel("inst/TCGA_Clinical_Curation/TCGA_Variable_Curation_UVM.xlsx", na = " ")
clinicalData <- readr::read_csv("inst/")

rowToDataFrame <- function(DataFrame) {
  columnIndex <- seq_len(which(names(DataFrame) == "Priority")-1)
  data.frame(variable = unlist(unname(DataFrame[columnIndex])), 
             priority = unlist(unname(DataFrame[-columnIndex])))
}

listDF <- apply(curatedLines, 1, rowToDataFrame)

listDF[[1]]

