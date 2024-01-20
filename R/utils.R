#' Get the latest galah download
#'
#' @param path_to_galah_data path where parquets of ALA downloads are stored
#'
#' @return path to most recent galah download
#'
#' @examples 
#' arrow::open_dataset(get_latest_download())

get_latest_download <- function(path_to_galah_data = 'data/galah/'){
  # Grab all files in folder
  all_downloads <- list.files(path_to_galah_data) 
  
  # Grab the dates only
  dates <- stringr::str_extract(all_downloads, pattern = regex("[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}"))
  
  # Determine the most recent date
  most_recent <- max(lubridate::ymd(dates)) |> as.character()
  
  # Identify the file name that is the most recent
  most_recent_file <- stringr::str_subset(all_downloads, most_recent)
  
  # Get path to most recent file
  paste0(path_to_galah_data, most_recent_file)
}

open_dataset(get_latest_download())
