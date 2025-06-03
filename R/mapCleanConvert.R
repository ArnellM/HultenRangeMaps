#' Clean raster and convert to polygon feature
#'
#'Cleans the digitised range map by removing (most of the) map border, removing small inconsistencies by 'clumping' and 'sifting' and converts the raster map to a polygon feature.
#'
#' @param x digitised map (RasterLayer)
#'
#' @returns a polygon feature (SpatVector)
#' @export
#'

mapCleanConvert <- function(x){
  border_remove <- sf::as_Spatial(border_remove)
  ras_crop <- raster::crop(x, raster::extent(border_remove)) # crop raster to the extent of the polygon
  ras_mask <- raster::mask(ras_crop, border_remove) # mask raster by polygon
  ras_cl <- raster::clump(ras_mask) # detect "clumps" (patches) of connected cells
  freq_cl = data.frame(raster::freq(ras_cl))# frequency of pixels in identified clumps
  freq_cl[freq_cl$count==max(freq_cl$count),2] <- NA #set the clump with the highest number of pixels to NA
  r_re <- raster::reclassify(ras_cl, freq_cl) # reclassify raster to the pixel frequency count
  r_re[r_re <= 15] <- NA # "sift" the raster by setting all clumps with <15 pixels to NA
  r_re[r_re > 0] <-1 # set all the rest of the clumps to 1
  r_cl <- raster::clump(r_re) # clump raster again
  r_cl <-terra::rast(r_cl) # convert to a SpatRaster-format used in the "terra" package
  cl_pol <- terra::as.polygons(r_cl) # convert raster to polygon spatial feature based on clumps
}
