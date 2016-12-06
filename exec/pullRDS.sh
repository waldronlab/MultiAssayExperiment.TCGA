#!/bin/bash

## Script for downloading data from iRods
## Load raw data saved from RTCGAToolbox

iinit

iget -r /cunyZone/home/microbiome001/mae/data ../data/

echo "done"
