library(here)
library(sf)
library(terra)
library(raster)
library(ncdf4)
library(dplyr)

# load data from data_manipulation.R
here("R/wrangle/data_manipulation.R") |> source()

# ---------------------------------------------------------
# RASTER PROJECTION
# ---------------------------------------------------------

# set original crs for wind_speed_mean
crs(wind_speed_mean) <- 'EPSG: 3035'

# define projection
projection <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

# check Resolution, Extent and CRS
res(wind_speed_mean)
res(land_use)

ext(wind_speed_mean)
ext(land_use)

crs(wind_speed_mean)
crs(land_use)

# reduce resolution to fasten projection for land_use --> project 
land_use_resampled <- aggregate(land_use, fact=10)
land_use <- project(land_use_resampled, "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

# project wind_speed_mean
wind_speed_mean <- project(wind_speed_mean, "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

# ---------------------------------------------------------
# RASTER RESAMPLE & COMBINE
# ---------------------------------------------------------

# resample wind_speed_mean to match land_use
wind_speed_mean <- terra::resample(wind_speed_mean, land_use, method="bilinear")

# take first layer from wind_speed_mean
wind_speed <- wind_speed_mean[[1]]

# condition that wind speed must be at least 7.5 m/s at hub height
wind_speed_condition <- wind_speed >=7
plot(wind_speed_condition)

# recreate categories that land-use has (10,20,30,40,50,60)
reclass_matrix <- matrix(c(
  10, 15, 10,
  15, 25, 20,
  25, 35, 30,
  35, 45, 40,
  45, 55, 50,
  55, 60, 60
), ncol = 3, byrow = TRUE)

land_use <- classify(land_use, reclass_matrix)
category_labels <- data.frame(id = c(10, 20, 30, 40, 50, 60),
                              category = c("Forest", "Low Vegetation", "Water", 
                                           "Built-Up", "Bare Soil", "Agriculture"))
levels(land_use) <- category_labels

# condition that just takes eligible land for placing wind turbines (low vegetation & bare soil)
land_use_condition <- land_use == 20 | land_use == 50
plot(land_use_condition)

# laying both conditions over each other
aggregated_layer <- wind_speed_condition & land_use_condition
plot(aggregated_layer)


# ---------------------------------------------------------
# SET VECTOR CRS
# ---------------------------------------------------------

st_crs(wind_points_sf) #already matching CRS
st_crs(election_mp)

election_mp <- st_set_crs(election_mp, projection)
