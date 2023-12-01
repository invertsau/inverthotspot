##----------------------------------------------------------------------##
# Calc weighed endemism for invertebrates shapefiles
# Aaron Greenville
#
# Updated for testing - Payal Bal
##----------------------------------------------------------------------##


rm(list = ls())
gc()

x <- c('phyloregion', 'terra', 'sf')
lapply(x, require, character.only = TRUE)
rm(x)



## Load species polygons (as spdf) ####

### Fonti's output ####
species_polys <- readRDS("output/myg_spiders_conr_sp.rds")

## Extract spdf from list
species_polys <- x[1:5]
species_polys <- lapply(species_polys, "[[", 1) 
species_polys <- lapply(species_polys, "[[", 2) 

## Extract species names from list
xnames <- x[1:5]
xnames <- lapply(xnames, "[[", 1)
xnames <- lapply(xnames, "[[", 1)
xnames <- ... ## extract species names from your nested list

names(species_polys) <- xnames ## assign names from nested list for the rest of the code to work with your output file



### NESP output ####
## >> In the meantime, I have trialled the script with the NESP outputs and it works!

# y <- readRDS("/home/payalb/gsdms_r_vol/tempdata/research-cifs/6300-payalb/uom_data/nesp_bugs_data/outputs/species_ahullEOOspdf.rds") 
# species_polys <- y[51:55]
# saveRDS(species_polys, "./data/example_species_ahullEOOspdf.rds")

species_polys <- readRDS("./data/example_species_ahullEOOspdf.rds")




## Combine spdf into a single object ####
combinedShp <- do.call(what = rbind, args=species_polys)

## Assign species names
combinedShp$dummy <- names(species_polys)
combinedShp <- vect(combinedShp)
names(combinedShp) <- "species"



##  Calulate community matrix ####
comm.poly <- polys2comm(dat = combinedShp, species = "species", trace=1, res = 0.5)
head(comm.poly)



## Calulate weighed endemism ####
Endm.invert.poly <- weighted_endemism(comm.poly$comm_dat)
head(Endm.invert.poly)


## Join results back to spatial community data ####
m1.poly <- merge(comm.poly$map, data.frame(grids=names(Endm.invert.poly), WE=Endm.invert.poly), by="grids")
m1.poly <- m1.poly[!is.na(m1.poly$WE),]



## Calulate corrected weighted endemism #### 
# (weighted endemism tally per cell divided by the species richness of that cell)
m1.poly$corrected_endemism <- m1.poly$WE/m1.poly$richness

plot(m1.poly)

## Plotting ####
library(tmap)

aust_WGS84 <- st_transform(ozmaps::ozmap_country, crs(comm.poly$map))

## >> plotting is not my forte! I'll leave this part for you to figure out please :)
spRh.poly <- tm_shape(m1.poly) +
  tm_polygons("richness", 
              style="quantile", 
              title="Species Richness",
              palette="YlGnBu")+
  tm_shape(aust_WGS84)+
  tm_polygons("PLACENAME", 
              alpha = 0,
              legend.show = F,
              lwd = 2, border.col = 1)

weighted.endemism.poly <- tm_shape(m1.poly) +
  tm_polygons("WE", 
              style="quantile", 
              title="Weighted endemism",
              palette="YlGnBu")+
  tm_shape(aust_WGS84)+
  tm_polygons("PLACENAME", 
              alpha = 0,
              legend.show = F,
              lwd = 2, border.col = 1)

Corrected.weighted.endemism.poly <- tm_shape(m1.poly) +
  tm_polygons("corrected_endemism", 
              style="quantile", 
              title="Polygons: Corrected weighted endemism",
              lwd = 0.5,
              palette="YlGnBu")+
  tm_shape(aust_WGS84)+
  tm_polygons("PLACENAME", 
              alpha = 0,
              legend.show = F,
              lwd = 2, border.col = 1) #+
# tm_shape(fire_sf)+
# tm_polygons(
#             alpha = 0.5,
#             legend.show = T,
#             lwd = 2, border.col = 1)




maps.poly <- tmap_arrange(spRh.poly, weighted.endemism.poly, Corrected.weighted.endemism.poly, ncol =1 )

# tmap_save(maps.poly, filename = "output/tmap_invert_poly_endemism_1.png",
#           height = 7, width = 7)

maps.poly.point <- tmap_arrange(Corrected.weighted.endemism, Corrected.weighted.endemism.poly, ncol =1 )

# tmap_save(maps.poly.point, filename = "output/tmap_invert_poly-point_endemism_0-5.png",
#           height = 7, width = 7)


## Save out endemism file ####
save(m1.poly, file = "data/m1_poly_0.5.rds")



