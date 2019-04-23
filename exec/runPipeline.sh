#!/bin/bash
# source start.sh

ulimit -s unlimited

time R_LIBS_USER=$HOME/R/bioc-devel $HOME/src/svn/r-devel/R/bin/R -e \
'
setwd("..")
message("Using: ", getwd())
library(MultiAssayExperiment.TCGA)
buildMultiAssayExperiments(upload = FALSE)
'

