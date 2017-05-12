## Preprocessing of OV

## Load helper functions
source("data-raw/helpers.R")

library(dplyr)
library(readr)

## Fix bad barcodes
ovcur <- .curateBarcodes("OV")

## Write file to disk
write_csv(x = ovcur, path = "inst/extdata/allsubtypes/OV.csv")
