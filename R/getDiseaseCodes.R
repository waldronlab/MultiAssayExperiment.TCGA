#' Function for getting available TCGA cancer disease codes
#'
#' A convenience function to get available cancer codes from TCGA. It excludes
#' joint codes such as `COADREAD` and `GBMLGG`, among others. See the
#' `diseaseCodes` datasets in `TCGAutils` for a complete list.
#'
#' @return A vector of named disease codes
#' @export
getDiseaseCodes <- function() {
    nev <- new.env()
    data("diseaseCodes", package = "TCGAutils", envir = nev)
    diseaseCodes <- nev[["diseaseCodes"]]
    excludedCodes <- c("COADREAD", "GBMLGG", "KIPAN",
        "STES", "FPPP", "CNTL", "LCML", "MISC")
    logicalSub <- !diseaseCodes[[1L]] %in% excludedCodes
    diseases <- diseaseCodes[logicalSub, "Study.Abbreviation"]
    setNames(diseases, diseases)
}
