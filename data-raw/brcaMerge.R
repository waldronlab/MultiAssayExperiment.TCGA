library(readr)

brca1 <- read_csv("inst/extdata/allsubtypes/BRCA.csv")
brca2 <- read_csv("inst/extdata/allsubtypes/BRCA2.csv")

## Select relevant columns
brca2 <- brca2[, c("Sample ID", "60 Gene-classifier Class Assignment")]

## Prep patient IDs for merging
brca2[["Sample ID"]] <- gsub("\\.", "-", brca2[["Sample ID"]])

## Merge both files and keep all cases
newBRCA <- merge(brca1, brca2, by.x = "Complete TCGA ID", by.y = "Sample ID", all = TRUE)

write_csv(newBRCA, path = "inst/extdata/allsubtypes/BRCA.csv")

# remove BRCA2 file
unlink("inst/extdata/allsubtypes/BRCA2.csv")

## Test read written file
## read_csv("inst/extdata/allsubtypes/BRCA.csv")
