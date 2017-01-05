#!/bin/bash
# export R_LIBS="/scratch/$USER/R_libs"
# source start.sh

ulimit -s unlimited

/home/$USER/src/svn/r-devel/R/bin/Rscript ../R/globalScript.R --verbose

