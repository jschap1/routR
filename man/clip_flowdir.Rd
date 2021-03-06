% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clip_flowdir.R
\name{clip_flowdir}
\alias{clip_flowdir}
\title{Clip FlowDir}
\usage{
clip_flowdir(fd, basinmask, savename, out_format = "ascii")
}
\arguments{
\item{fd}{flow direction map}

\item{basinmask}{mask to which to clip the fd file}

\item{savename}{output name to save the clipped flow direction file}

\item{out_format}{format to output the flow direction file. Can be GTiff or ascii.}
}
\description{
Clips the flow direction file to the basinmask
}
\examples{
flowdir <- raster("/Volumes/HD3/SWOTDA/FDT/v10282019/flow_direction_vic_d4_00.asc")
basinmask <- raster("/Volumes/HD3/SWOTDA/FDT/v10282019/mangla_basinmask_coarse.tif")
savename <- "/Volumes/HD3/SWOTDA/Calibration/Mangla/mangla_flowdir_vic"
fd <- clip_flowdir(flowdir, basinmask, savename, out_format = "ascii")
}
