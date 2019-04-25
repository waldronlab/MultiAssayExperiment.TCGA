setwd("~/MultiAssayExperiment.TCGA")
message("Using: ", getwd())

creds <- readLines("~/data/aws/sts.txt")
config <- strsplit(creds, "\t")[[1L]]
config <- config[c(2, 4, 5)]

renv <- readLines("~/.Renviron")

posidx <- vapply(aws_vars, function(x) grep(x, renv, fixed = TRUE), integer(1L))

aws_vars <- c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN")

for (i in 1:3) {
    idx <- posidx[i]
    renv[idx] <- paste0(aws_vars[i], "=", config[i])
}

writeLines(renv, con = file("~/.Renviron"))

library(MultiAssayExperiment.TCGA)

buildMultiAssayExperiments()
