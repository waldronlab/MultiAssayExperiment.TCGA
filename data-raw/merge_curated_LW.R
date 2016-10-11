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


csv= read.csv(file.choose(), header = T, as.is = T)
curxls = gdata::xls2tab(file.choose())
curdat = readLines(curxls)
curdat = strsplit(curdat, "\t")[-1]
for (i in 1:length(curdat)){
  tmp = gsub("\"", "", curdat[[i]])
  tmp = tmp[!tmp %in% ""]
  if(length(tmp) == 1) tmp = c(tmp, "1")  #in case numbers were forgotten
  idx = grep("^[1-9]$", tmp)
  output = as.integer(tmp[idx])
  tmp = tmp[-idx]
  if(!identical(length(output), length(tmp))){
    print(i)
    stop(paste("i =", i, "different numbers of column names and IDs:", output, tmp))
  }
  names(output) = tmp
  curdat[[i]] = output
}

curated.cols = do.call(c, sapply(curdat, names))
match(curated.cols, colnames(csv))
curdat[[1]]
sapply(curdat, length)


