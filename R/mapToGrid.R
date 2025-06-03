#' Match species' ranges to (national) grid
#'
#' @param x file path to folder with range map database
#' @param pattern file extension. Default is patterm = "*.geojson"
#' @param grid (national) grid polygon feature
#'
#' @returns a list of data frames with per species per grid cell historical presence
#' @export
#'

rangeToGrid <- function(x,pattern="*.geojson", grid=SweNationalGrid){

  if(!any(grepl("gridID", names(grid)))){stop("no column with name 'gridID' in 'grid'")}

  dat_list<-list() # create list

  files_of_interest <- gtools::mixedsort(list.files(x, pattern = pattern)) # list files

  for(i in seq_along(files_of_interest))  { # list files
    loop_file <- files_of_interest[i]
    species<-substring(loop_file,1,nchar(loop_file)-13) # scientific name - removing ".geojson" and map number

    message(paste0("start processing of ", species, " (number ",i," out of ", length(files_of_interest), " species)"))

    geoj <- sf::st_read(paste(x,loop_file, sep="")) # import GeoJSON polygon feature file

    message(paste0("transform range map coordinates to grid coordinate reference system"))

    geoj_swe <-sf::st_transform(geoj, crs = sf::st_crs(grid)) # transform CRS to the CRS of the (national) grid

    message(paste0("identify and reduce size of polygons representing 'isolated finds'"))

    # 1 - calculate area and length to find "isolated finds"
    geoj_swe$area <- as.numeric(sf::st_area(geoj_swe)) # calculate polygon area
    # calculate length of polygons
    geoj_swe$length <- NA # new column
    for(j in 1:length(geoj_swe$clumps)){
      poly <- geoj_swe[j,] # subset by polygon
      if(poly$area>400000000){ # calculate length only for polygons that are small enough to be "isolated finds" in the original maps
        geoj_swe$length[j] <- NA
      }
      else{
        point <- suppressWarnings(sf::st_cast(poly, "POINT")) # turn polygons into point features
        dis <- dplyr::distinct(point) # remove duplicates
        dist <- as.data.frame(sf::st_distance(dis)) # calculate distances
        p <- tidyr::gather(dist, point_id, dist) # gather table
        geoj_swe$length[j] <- max(p$dist, na.rm=T) # get max distance
      }
    }

    # find "isolated finds" based on polygon size and length
    geoj_swe$point <- ifelse(geoj_swe$area/(((geoj_swe$length/2)^2)*pi)>0.55 # 1 =  all polygons that are 55% similar to a circle, 0 = all other polygons
                             & geoj_swe$length<24000 # AND less than 20000m long
                             & geoj_swe$length>10000, 1, 0) # AND more than 10000m long
    geoj_swe$point <- ifelse(is.na(geoj_swe$length), 0, geoj_swe$point) # set polygons with no length measurement to 0
    geoj_p <- geoj_swe[geoj_swe$point==1,] # subset "isolated finds"
    geoj_a <- geoj_swe[!geoj_swe$point==1,] # distribution area with "isolated finds" removed
    # 2 - decrease the size of the "isolated finds" polygons
    geoj_b <- sf::st_buffer(geoj_p, dist = -5000) # create negative buffer around each point
    geoj_m <- rbind(geoj_a, geoj_b) # combine
    # 3 - intersect the (national) grid with historical range (spatial join)
    message(paste0("match the (national) grid with the species' historical range"))
    intersects <- sf::st_join(grid,geoj_m, left = F)
    intersects <- sf::st_drop_geometry(intersects[,"gridID"])
    nonsens <- as.data.frame(matrix(c(NA),ncol=1, byrow=T, dimnames= list(c(1),c("gridID"))))# add nonsense data for species with no historical presence in your grid
    intersects <-rbind(intersects, nonsens) # combine
    intersects <- base::unique(intersects) # since one grid square can overlap with several polygon features in the historical data, we keep only unique gridIDs
    if(nrow(intersects)>1){
      message(paste0("create dataframe with historical precence per grid"))
      intersects$scientificName <- species
      intersects$histPres <- 1
      dat_list[[species]] <- intersects
    }
    else(message(paste0("species has no historical presence within the grid extent")))
    message("------------------")
  }
  return(dat_list)
}
