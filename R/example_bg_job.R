pacman::p_load(galah, arrow, usethis)

galah_config(email = Sys.getenv("ALA_EMAIL"), 
             atlas = "Australia")

Mygalomorphae_occurrences <- 
  galah_call() |>                               
  galah_identify("Mygalomorphae") |>   
  #galah_filter(identificationIncorrect == FALSE) |> # This is where we want to add in assertion filters
  galah_select(group = c("assertions")) |> # This is where we want to add in which columns we want
  atlas_occurrences() 
#atlas_counts()