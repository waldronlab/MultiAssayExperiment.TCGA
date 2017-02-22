#!/bin/bash
## Input 1 = User.name (e.g., first.last)

export R_LIBS="/scratch/${1}/R_libs"

source start.sh

Rscript ../inst/scripts/getRawData.R --verbose
