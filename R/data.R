#' Scanned and aligned map
#'
#' Scanned and aligned map from the 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971).
#'
#' @format
#' .jpeg file
#' @source 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971)
#'
"aligned_map"

#' Polygon feature to mask map border
#'
#' Polygon feature used in the automated cleaning process to mask map border and legend.
#'
#' @format
#' Polygon spatial feature, gcs WGS 84 -- WGS84 - World Geodetic System 1984, EPSG:4326
#'
"border_remove"

#' Georeferenced and digitised map
#'
#' Georeferenced and digitised map from the 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971).
#'
#' @format
#' Polygon spatial feature, gcs WGS 84 -- WGS84 - World Geodetic System 1984, EPSG:4326
#' @source 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971)
#'
"database_map"

#' List of maps for species in the *Galium* genera
#'
#' List of georeferenced and digitised maps for species in the *Galium* genera from the 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971).
#'
#' @format
#' List of 14 spatial polygon features, gcs WGS 84 -- WGS84 - World Geodetic System 1984, EPSG:4326
#' @source 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971)
#'
"galium_list"

#' Historical per grid cell presence of vascular plants in Sweden
#'
#' Historical per grid cell presence in the Swedish 10×10 km National grid of of vascular plants from the 'Atlas of the distribution of vascular plants in northwestern Europe' (Hultén 1971).
#'
#' @format
#' Data frame, 2,046,758 rows and 3 columns
#' \describe{
#'  \item{scientificName}{Scientific name of species}
#'  \item{gridID}{Grid ID }
#'  \item{histPres}{1=historical presence}
#' }
"histPresSweNationalGrid"

#' IDs of grids with land surface
#'
#' String of Grid cells IDs with 50% or more land surface outside Sweden’s national borders and grid cells covered to 80% or more by sea surface or waterways.
#'
#' @format ## `land_cells`
#' Character string
#'
"land_cells"

#' European 10×10 km reference grid over Scandinavia and Finland
#'
#' Subset of the European 10×10 km reference grid (Scandinavia and Finland).
#'
#' @format
#' Spatial polygon feature, projected gcs ETRS89-extended / LAEA Europe, EPSG:3035
#' @source https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/europe-10-km-100-km
#'
"ScanGrid"

#' Swedish 10×10 km national grid
#'
#' Swedish 10×10 km national grid
#'
#' @format
#' Spatial polygon feature, projected gcs SWEREF99 TM, EPSG:3006
#'
"SweNationalGrid"

