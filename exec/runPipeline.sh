#!/bin/bash
# source start.sh

ulimit -s unlimited

aws sts get-session-token --duration-seconds 129600 > ~/data/aws/sts.txt

time R_LIBS_USER=$HOME/R/bioc-devel $HOME/src/svn/r-devel/R/bin/Rscript \
runPipeline.R

