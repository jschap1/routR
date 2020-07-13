#' Make fraction file
#' 
#' Creates a fraction file for the UW routing model
#' An alternative function is provided for creating a fraction file of all 1's
#'
#' @param dem fine resolution DEM at least as large as the study area
#' @param bb basin boundary shapefile defining the study area
#' @param saveloc directory to save outputs
#' @param basename basename for the outputs
#' @param target_res target (coarse) resolution
#' @export
#' @return Returns the following rasters, in ASCII grid format:
#' Fraction File at VIC model resolution
#' Watershed mask at DEM resolution
#' Watershed mask at VIC model resolution
#' DEM clipped to basin boundaries
#' @details All coordinate systems should be geographic. I've been using WGS84.
#' If the pixels are not square (in geographic coordinates), this becomes a pain.
#' @examples
#' dem <- raster("/Volumes/HD4/SWOTDA/Data/IRB/irb_dem.tif")
#' bb <- readOGR("/Volumes/HD4/SWOTDA/Data/IRB/irb_bb_1_16/bb.shp")
#' saveloc <- "/Volumes/HD3/SWOTDA/FDT/v12032019/Routing_Inputs"
#' basename <- "irb"
#' fract <- make_fract(dem, bb, saveloc, basename, fineres = 1/16, coarseres = 1/16)

make_fract <- function(dem, bb, saveloc, basename, target_res = 1/16)
{
  
  print("Creating fraction file")
  
  # Check that resolution is the same in both directions
  if (raster::res(dem)[1] == raster::res(dem)[2])
  {
    print("Square grid cells. Good.")
  } else
  {
    print("Non-square grid cells. Forcing them to be square.")
    newres <- raster::mean(raster::res(dem))
    dem <- raster::projectRaster(dem, crs = raster::crs(dem), res = c(newres, newres))
  }
    
  fineres <- raster::res(dem)[1] # DEM resolution (arc-seconds - "fine")
  coarseres <- target_res
  
  # Create a clipped DEM using the basin boundary shapefile
  dem.clipped <- clip_raster(dem, bb)
  raster::writeRaster(dem.clipped, 
                      file.path(saveloc, 
                                paste0(basename, "_clipped_DEM_fine")
                                ),
              format = "ascii", overwrite = T)
  
  # Create a watershed mask at the DEM resolution
  dem.clipped.copy <- dem.clipped
  dem.clipped.copy[!is.na(dem.clipped.copy)] <- 1
  
  # Use a slightly larger extent than that of the clipped DEM
  e <- raster::extent(dem.clipped)
  e@xmax <- ceiling(e@xmax)
  e@xmin <- floor(e@xmin)
  e@ymax <- ceiling(e@ymax)
  e@ymin <- floor(e@ymin)
  
  finemask <- raster::raster(resolution = fineres, ext = e, 
                             crs = raster::crs(bb)
                             )
  values(finemask) <- 0
  
  # Make sure origins are the same (if necessary)
  if (identical(raster::origin(dem.clipped.copy),
      raster::origin(finemask)))
  {
    print("Good. Origins are the same.")
  } else
  {
    print("Bad. Origins are not the same.")
    print("Manually setting origins to zero")
    raster::origin(dem.clipped.copy) <- c(0,0)
    raster::origin(finemask) <- c(0,0)
  }
  
  basinmask.fine <- raster::merge(dem.clipped.copy, finemask)
  
  raster::writeRaster(basinmask.fine, 
                      file.path(
                        saveloc, paste0(basename, "_basinmask_fine")
                        ), 
              format = "ascii", overwrite = T)

  # Make a grid with the VIC model resolution.
  # Extent must be larger than the real basin boundaries.
  
  # Must have a unique value in each cell (defines "zones").
  coarsegrid <- raster::raster(resolution = coarseres , ext = e, 
                               crs =  raster::crs(bb)
                               )
  values(coarsegrid) <- 1: raster::ncell(coarsegrid)
  
  # Resample the coarse grid to the DEM resolution, without changing the values
  finegrid <-  raster::resample(coarsegrid, basinmask.fine, method = "ngb")
  
  # Compute zonal mean
  zmean <- raster::zonal(basinmask.fine, z = finegrid, progress = "text")
  
  # Output fraction file
  fract <-  raster::raster(coarsegrid)
  raster::values(fract) <- zmean[,2]
  raster::writeRaster(fract, file.path(saveloc, 
                               paste0(basename, "_fract")
                               ), 
              format = "ascii", overwrite = T)
  
  # Create a basin mask at the VIC model resolution
  basinmask.coarse <- fract
  basinmask.coarse[basinmask.coarse != 0] <- 1
  raster::writeRaster(basinmask.coarse, 
                      file.path(saveloc, paste0(basename, "_basinmask_coarse")), 
              format = "ascii", overwrite = T)
  raster::writeRaster(basinmask.coarse, 
                      file.path(saveloc, paste0(basename, "_basinmask_coarse")), 
                                          format = "GTiff", overwrite = T)
  
  # Crop fraction file to basin extent (to make up for large extent of e)
  e_bb <- raster::extent(bb)
  e_bb@xmax <- e_bb@xmax + target_res
  e_bb@xmin <- e_bb@xmin - target_res
  e_bb@ymax <- e_bb@ymax + target_res
  e_bb@ymin <- e_bb@ymin - target_res
  fract_crop <- raster::crop(fract, e_bb)
  
  print(paste("Outputs written to", saveloc))
  return(fract_crop)
}