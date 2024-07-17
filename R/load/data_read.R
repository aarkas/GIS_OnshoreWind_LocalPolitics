library(here)
library(sf)
library(ggplot2)
library(sp)
library(raster)
library(terra)
library(ncdf4)
library(readxl)

## VECTOR DATA

# wind farms as point layer
wind_points_old <- st_read(
  here(
    "data",
    "input",
    "Windkraftanlagen DE - Windkraftanlagen 2023",
    "Windkraftanlagen DE - Windkraftanlagen 2023.shp"
  )
)
st_crs(wind_points_old)
plot(wind_points_old)

# wind farm database with more recent data
wind_points <- read_excel(here("data", "input", "Global-Wind-Power-Tracker-June-2024.xlsx"),
                           sheet = "Data")

# Germany ...TODO: Which level do I want Germany shp?
deu <- st_read(here("data", "input", "gadm41_DEU_shp", "gadm41_DEU_2.shp"))
st_crs(deu)
ggplot() +
  geom_sf(data = deu) +
  geom_sf(data = wind_points_old, aes(color = 'red'))
theme_minimal()

# municipalities for the 2021 federal election
municipality <- st_read(
  here(
    "data",
    "input",
    "2021-bundestagswahl-gemeinden",
    "2021-bundestagswahl-gemeinden.shp"
  )
)
st_crs(municipality)
ggplot() +
  geom_sf(data = municipality) +
  theme_minimal()

# federal election 2021 results
election_2021 <- read.csv2(
  here(
    "data",
    "input",
    "2021-bundestagswahl-gemeinden",
    "2021-bundestagswahl-gemeinden.csv"
  ),
  sep = ','
)


## RASTER DATA

# land use raster for Germany (2021)
land_use <- rast(here(
  "data",
  "input",
  "raster",
  "classification_map_germany_2020_v02.tif"
))
st_crs(land_use)
print(land_use)
plot(land_use)

# wind speed monthly average for January, April, July & October (2012)
wind_speed_jan <- nc_open(here("data", "input", "raster", "FF_201201_monmean.nc"))
wind_speed_april <- nc_open(here("data", "input", "raster", "FF_201204_monmean.nc"))
wind_speed_july <- nc_open(here("data", "input", "raster", "FF_201207_monmean.nc"))
wind_speed_oct <- nc_open(here("data", "input", "raster", "FF_201210_monmean.nc"))
print(wind_speed_jan)
