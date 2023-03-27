getDataLinks <- function(TCGAcode, data_date, dataTypes) {
    names(dataTypes) <- dataTypes
    allLinks <- lapply(dataTypes, function(dataType) {
        datatype <- list(TRUE)
        names(datatype) <- dataType
        do.call(
            getLinks,
            args = c(
                datatype,
                dataset = TCGAcode,
                data_date = data_date
            )
        )
    })
    reslist <- list(as(allLinks, "CharacterList"))
    names(reslist) <- paste0(TCGAcode, "_GDAC_LINKS")
    reslist
}
