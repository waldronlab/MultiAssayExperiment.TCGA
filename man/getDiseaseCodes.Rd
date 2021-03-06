% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getDiseaseCodes.R
\name{getDiseaseCodes}
\alias{getDiseaseCodes}
\title{Function for getting available TCGA cancer disease codes}
\usage{
getDiseaseCodes()
}
\value{
A vector of named disease codes
}
\description{
A convenience function to get available cancer codes from TCGA. It excludes
joint codes such as `COADREAD` and `GBMLGG`, among others. See the
`diseaseCodes` datasets in `TCGAutils` for a complete list.
}
