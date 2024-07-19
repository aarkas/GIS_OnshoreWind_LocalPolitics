library(here)
library(sf)
library(ggplot2)
library(sp)
library(raster)
library(terra)
library(ncdf4)
library(readxl)


# ---------------------------------------------------------
# VECTOR DATA
# ---------------------------------------------------------

# wind farms as point layer
# wind_points_old <- st_read(
#   here(
#     "data",
#     "input",
#     "Windkraftanlagen DE - Windkraftanlagen 2023",
#     "Windkraftanlagen DE - Windkraftanlagen 2023.shp"
#   )
# )
# st_crs(wind_points_old)
# plot(wind_points_old)

# wind farm database with more recent data
wind_points <- read_excel(here("data", "input", "Global-Wind-Power-Tracker-June-2024.xlsx"),
                          sheet = "Data")

# Germany ...TODO: Which level do I want Germany shp?
districts <- st_read(here("data", "input", "gadm41_DEU_shp", "gadm41_DEU_2.shp"))
st_crs(districts)
ggplot() +
  geom_sf(data = districts) +
  theme_minimal()

# municipalities for the 2021 federal election
municipalities <- st_read(
  here(
    "data",
    "input",
    "2021-bundestagswahl-gemeinden",
    "2021-bundestagswahl-gemeinden.shp"
  )
)
st_crs(municipalities)
ggplot() +
  geom_sf(data = municipalities) +
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


# ---------------------------------------------------------
# RASTER DATA
# ---------------------------------------------------------

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

# wind speed projected mean for near future (2021 - 2050) project by TU Dresden
wind_speed_mean <- rast(here(
  "data",
  "input",
  "raster",
  "fu_ff_mean_year_201902280000_l140.nc"
))

ext(wind_speed_mean)
res(wind_speed_mean)
st_crs(wind_speed_mean)
plot(wind_speed_mean)
