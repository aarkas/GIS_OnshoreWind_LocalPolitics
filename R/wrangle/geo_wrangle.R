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

# set original crs for wind_speed_mean (from source)
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

# mapping for the land use categories
land_use_mapping <- data.frame(
  id = c(10, 20, 30, 40, 50, 60),
  label = c(
    "Forest",
    "Low Vegetation",
    "Water",
    "Built-Up",
    "Bare Soil",
    "Agriculture"
  )
)

# setting levels
levels(land_use) <- land_use_mapping

# reduce resolution to fasten projection for land_use; using modal so that classification is maintained
# takes about 15 min
land_use_resampled <- aggregate(land_use, fact = 10, fun = modal)

# project land_use using "near"-method to maintain classification
land_use <- project(land_use_resampled, projection, method = "near")

levels(land_use) <- land_use_mapping

# project wind_speed_mean
wind_speed_mean <- project(wind_speed_mean, projection)

# ---------------------------------------------------------
# RASTER RESAMPLE & COMBINE CONDITIONAL LAYER
# ---------------------------------------------------------

# resample wind_speed_mean to match land_use
wind_speed_mean <- terra::resample(wind_speed_mean, land_use, method = "bilinear")

# take first layer from wind_speed_mean
wind_speed <- wind_speed_mean[[1]]

# condition that wind speed must be at least 7 m/s at hub height
wind_speed_condition <- wind_speed >= 7
plot(wind_speed_condition)

# condition that just takes eligible land for placing wind turbines (low vegetation & bare soil)
land_use_condition <- land_use == "Low Vegetation" | land_use == "Bare Soil"
plot(land_use_condition)

# laying both conditions over each other
aggregated_layer <- wind_speed_condition & land_use_condition
plot(aggregated_layer)

# ---------------------------------------------------------
# SET VECTOR CRS AND CONVERT TO SF
# ---------------------------------------------------------

st_crs(wind_points_sf) #already matching CRS
st_crs(election_mp)
st_crs(municipalities)
st_crs(districts)

election_mp <- st_set_crs(election_mp, projection)
municipalities <- st_set_crs(municipalities, projection)
districts <- st_set_crs(districts, projection)
