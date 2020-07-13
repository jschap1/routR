#' Clip raster
#' 
#' Clips a raster to a shapefile
#' A user-written function from Carsten Neumann:
#' https://stat.ethz.ch/pipermail/r-sig-geo/2013-July/018912.html
#' @export
#' @param raster raster to clip
#' @param shape shapefile to use as clip boundary

clip_raster <- function(raster,shape) {
  a1_crop<-raster::crop(raster,shape)
  step1<-raster::rasterize(shape,a1_crop)
  a1_crop*step1
  }
