if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")}

# Load libraries
pacman::p_load(
  sf,             # handle vector spatial data
  terra,          # handle raster spatial data
  tidyverse,      # data wrangling and plotting
  mapview,        # interactive maps 
  tmap,            # plot maps 
  exactextractr,  # fast raster extraction to polygons
  tidycensus,     # Census and ACS data via API
  units)          # unit conversion 

# Set working directory (update to your local path)
setwd("/Users/corgi/Downloads/TE_North_America_20260405_Non_Commercial")

lines <- st_read("geojson/lines.geojson")
head(lines)
