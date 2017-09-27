# Update RTCGAToolbox objects

dataFiles <- list.files("data/raw", pattern = "*\\.rds$", full.names = TRUE,
    recursive = TRUE)

dataNames <- vapply(strsplit(basename(dataFiles), "\\."), `[`,
    character(1L), 1L)

folderName <- vapply(strsplit(dataNames, "_"), `[`, character(1L),
    1L)

lapply(folderName, function(x) dir.create(file.path("data", "rawold", x)))

names(dataFiles) <- dataNames

lapply(seq_along(dataFiles), function(i, file) {
    dataObj <- RTCGAToolbox::updateObject(readRDS(file[i]))
    readr::write_rds(x = assign(names(file[i]), dataObj),
        path = file.path("data/rawold", folderName[i],
            paste0(names(file[i]), ".rds")),
        compress = "bz2")
}, file = dataFiles)

