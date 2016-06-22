#!/bin/bash

export R_LIBS="/scratch/lucas.schiffer/R_libs"

module load intel r

Rscript installLibraries.R --verbose
