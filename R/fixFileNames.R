

#' Cange filenames to match Dyntaxa
#'
#'In the Swedish Taxonomic Database Dyntaxa, hybrid species are denoted by the symbol ×. To facilitate file handling the symbol × has been replaced by the letter x in the database file names. This function changes the letter x in the file names back the symbol × so that the file names are identical to the Dyntaxa scientific names.
#' @param path file path folder with range map database
#' @param pattern file extension. Default is patterm = "*.geojson"
#'
#' @returns new filenames
#' @export
#'

fixFileNames <- function(path,pattern="*.geojson"){
  for(i in list.files(path, pattern = "*.geojson"))  { # list files
    file.rename(from = paste0(path,i), to = paste0(path,gsub(" x "," × ",i)))
  }
}
