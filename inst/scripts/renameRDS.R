## All saved datasets should include capital letter disease codes
## To keep all scripts consistent
## e.g., OV, COAD, etc.

dataFiles <- list.files("../../data/", pattern = "rds$", full.names = TRUE)
codeNames <- unlist(lapply(strsplit(basename(dataFiles), "\\."),
		function(x) { x[[1]] }))
upperNames <- paste0(toupper(codeNames), ".rds")
newFiles <- file.path("../../data/", upperNames)
stopifnot(identical(length(dataFiles), length(newFiles)))
file.rename(dataFiles, newFiles)

