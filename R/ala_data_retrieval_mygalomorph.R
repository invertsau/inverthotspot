#install pacman
install.packages("pacman")

# load other plugins
pacman::p_load(galah, arrow)

# Add ALA registered email to access data (register at ala.org.au)
galah_config(email = "ashleybrowse@invertsau.org")

# Download observations from ALA
Mygalomorphae_occurrences <- 
  galah_call() |>                               
  galah_identify("Mygalomorphae") |>   
  galah_filter(country == "Australia") |>
  galah_apply_profile(ALA) |> # ALA's set of data cleaning filters
  atlas_occurrences() 

# Inspect the data
object.size(Mygalomorphae_occurrences) |> format(units = "MB")
nrow(Mygalomorphae_occurrences)
names(Mygalomorphae_occurrences)
str(Mygalomorphae_occurrences)
head(Mygalomorphae_occurrences)

#clean the data
Mygalomorphae_clean <- Mygalomorphae_occurrences |> 
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) |>
  filter(!duplicated(decimalLatitude) & !duplicated(decimalLongitude)) 

# Inspect cleaned data
object.size(Mygalomorphae_clean) |> format(units = "MB")
nrow(Mygalomorphae_clean)
head(Mygalomorphae_clean)

#timestamp data
Mygalomorphae_clean$timestamp <- Sys.Date()
head(Mygalomorphae_clean)

help("write_parquet")
write_parquet(Mygalomorphae_clean, "data/galah/Mygalomorphae_ALA.paraquet")
