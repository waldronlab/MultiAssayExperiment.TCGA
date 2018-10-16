#!/bin/bash
# source start.sh

cd exec/

ulimit -s unlimited

time R_LIBS_USER=/home/$USER/R/x86_64-pc-linux-gnu-library/bioc-devel \
/home/$USER/src/svn/r-release/R/bin/Rscript ../R/globalScript.R --verbose

