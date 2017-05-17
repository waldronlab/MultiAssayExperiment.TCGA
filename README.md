# MultiAssayExperiment-TCGA

This repo is for adding large curated MultiAssayExperiment datasets derived
from The Cancer Genome Atlas (TCGA). All original files and R scripts used to
create them can be found within. See `rawdata` and `R` subfolders.

## `littler`

* `install.packages("littler")`
* Use `littler` with R scripts with your own version of `R`
* Create `~/.littler.r` and add a `.libPaths` line
* Run the `exec/runPipeline.r` file with your path to `R` at the top
