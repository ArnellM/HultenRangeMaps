#' Digitise scanned range maps
#'
#'Takes a scanned range map (raster stack) with three bands (Red-Green-Blue) and extracts the range information by taking the green raster band and setting all pixel values up to 150 to 1 and all other to 0. The pixel range 0-150 in green raster band represents the dark red areas in the scanned map.
#'
#' @param x scanned range map (RGB rasterStack).
#' @param value maximum pixel value that delimits the pixel values representing the range information in the scanned maps. Default value is x=150.
#'
#' @returns A raster layer.
#' @export
#'
#' @examples
mapDig <- function(x,value=150){
    gr <- x$ref_map_2 # select only the green band
    raster::calc(gr, fun=function(x){base::ifelse(x<=value,1,NA)}) # set "dark red" pixel values to 1 and all other to NA

}
