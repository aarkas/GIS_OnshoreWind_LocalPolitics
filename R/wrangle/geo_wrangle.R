library(here)

# load data from data_manipulation.R
here("R/wrangle/data_manipulation.R") |> source()

# ---------------------------------------------------------
# RASTERS
# ---------------------------------------------------------

crs_layer1 <- crs(land_use)
crs_layer2 <- crs(wind_speed_mean)

# Print the CRS of both layers
print(crs_layer1)
print(crs_layer2)

# Check if they are the same
if (crs_layer1 == crs_layer2) {
  print("CRS of both layers are the same.")
} else {
  print("CRS of the layers are different.")
}

wind_speed_mean <- project(wind_speed_mean, crs(land_use) )
crs(wind_speed_mean)


plot(land_use)
plot(wind_speed_mean, add = TRUE, col = "red")