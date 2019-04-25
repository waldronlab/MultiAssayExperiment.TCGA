# MultiAssayExperiment.TCGA

`MultiAssayExperiment.TCGA` is the pipeline package for building and uploading
MultiAssayExperiment datasets from the GDAC Firehose pipeline as obtained
from `RTCGAToolbox`.

There are several steps to rebuild datasets for 33 cancer types.

Generally, users should use the packaged product of the pipeline:

[`curatedTCGAData`](http://bioconductor.org/packages/curatedTCGAData)

For those looking to rebuild the pipeline, there are several steps that need
to be followed:

0. Create all data directories required (`dataDirectories`)
1. Obtain all clinical and assay data from RTCGAToolbox (`saveRTCGAdata`)
2. Introduce additional clinical variables to all clinical datasets
3. Download and integrate subtype curation data from Dropbox
4. Generate and serialize data maps, providing relationships between samples
and patients
5. Update metadata and upload to `ExperimentHub` (`buildMultiAssayExperiments`)

These functions can be found in the `data-raw`, `inst/scripts`, and `R` folders.

NOTE. Include `AWS CLI` authentication credentials in the `~/.Renviron` file.
It should include three key:value pairs,
`AWS_SESSION_TOKEN`, `AWS_SECRET_ACCESS_KEY`, and `AWS_ACCESS_KEY_ID`

