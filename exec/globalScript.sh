#!/bin/bash
# export R_LIBS="/scratch/$USER/R_libs"
# source start.sh

ulimit -s unlimited

time /home/$USER/src/svn/r-devel/R/bin/Rscript ../R/globalScript.R --verbose

