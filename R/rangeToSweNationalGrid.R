
#' Match species' ranges to (national) grid
#'
#' @param x file path to folder with range map database
#' @param pattern file extension. Default is patterm = "*.geojson"
#' @param grid (national) grid polygon feature
#'
#' @returns a list of data frames with per species per grid cell historical presence
#' @export
#'
#' @examples
rangeToSweNationalGrid <- function(x,pattern="*.geojson", grid=SweNationalGrid){
  dat_list<-list()
  for(i in gtools::mixedsort(list.files(x, pattern = pattern)))  { # list files
  species<-substring(i,1,nchar(i)-13) # scientific name - removing ".geojson" and map number
  geoj <- sf::st_read(paste(x,i, sep="")) # import GeoJSON polygon feature file
  geoj_swe <-sf::st_transform(geoj, crs = sf::st_crs(grid)) # transform CRS to the CRS of the (national) grid
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
  # 3 - intersect the Swedish national grid with historical range
  intersects <- as.data.frame(sf::st_intersects(grid, geoj_m, sparse = TRUE)) # intersect Swedish national grid with historical range
  nonsens <- as.data.frame(matrix(c(6000,1),ncol=2, byrow=T, dimnames= list(c(1), c("row.id", "col.id")))) # add nonsense data for species with no historical presence in Sweden
  intersects <-rbind(intersects, nonsens)
  intersects <- stats::aggregate(col.id~row.id, intersects, FUN=length) # since one grid square can overlap with several polygon features in the historical data, we aggregate the result by grid square
  if(nrow(intersects)>1){ # only for species with historical presence in the (national) grid
    # 4 - create data frame with historical presence per species per grid
    dat_grid <- as.data.frame(grid)
    names(dat_grid)<-c("id","grid","geom")
    dat <- as.data.frame(dat_grid[dat_grid$id %in% intersects$row.id,c("grid")]) # gridIDs for the grid squares that intersects the historical range
    dat$scientificName <- species # column with species
    names(dat)<- c("gridID","scientificName") # new names
    dat <- dat[,c("scientificName", "gridID")] # new order
    dat$histPres <-1 # add column with historical presence
    dat_list[[species]]<-dat # add species data to list
  }
}
return(dat_list)
}
