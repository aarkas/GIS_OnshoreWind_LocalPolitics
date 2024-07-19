library(sf)
library(terra)
library(dplyr)
library(exactextractr)

here("R/wrangle/geo_wrangle.R") |> source()

# ---------------------------------------------------------
# xxxx
# ---------------------------------------------------------

# true punkte 1/3 district level
# filter gleiche windparks auf basis von koordinaten
# gpt reihenfolge für analyse

crs(aggregated_layer) <- crs(districts) 
ext(aggregated_layer) <- ext(districts)

district_true <- crop(aggregated_layer, districts)
plot(district_true)

district_mask_true <- mask(district_true, districts) 
plot(district_mask_true)

coverage_stats <- exact_extract(district_mask_true, districts, fun = function(values, coverage_fraction) {
  if (length(values) == 0) {
    return(NA)
  }
  sum(values * coverage_fraction, na.rm = TRUE) / sum(coverage_fraction)
})





####
districts_raster <- rasterize(districts, aggregated_layer, field="GID_2")
crs(districts_raster) <- crs(aggregated_layer)
plot(districts_raster)

#districts_raster <- resample(districts_raster, aggregated_layer, method="bilinear")
masked_suitability <- mask(aggregated_layer, districts_raster)
plot(masked_suitability)
coverage_stats <- zonal(masked_suitability, districts_raster, fun='mean')





aggregated_combined_layer <- aggregate(aggregated_layer, fact = 10, fun = mean, na.rm = TRUE)
plot(aggregated_layer)
plot(aggregated_combined_layer > 0.2)

res(aggregated_layer)

calculate_true_proportion <- function(district, aggregated_layer) {
  mask_raster <- terra::mask(aggregated_layer, district)
  true_proportion <- sum(mask_raster[], na.rm = TRUE) / ncell(mask_raster)
  return(true_proportion)
}

# Apply the function to each municipality
districts$true_proportion <- sapply(1:nrow(districts), function(i) {
  calculate_true_proportion(districts[i, ], aggregated_layer)
})

mask_raster <- terra::mask(aggregated_layer, districts)
crs(aggregated_layer) == crs(districts)
plot(mask_raster)
