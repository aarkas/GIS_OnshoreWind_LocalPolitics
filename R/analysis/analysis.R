library(sf)
library(terra)
library(dplyr)
library(exactextractr)

here("R/wrangle/geo_wrangle.R") |> source()

# ---------------------------------------------------------
# ELIGIBLE DISTRICTS
# ---------------------------------------------------------

# calculate proportion of district where the aggregated layer is TRUE (land is considered eligible)
crs(aggregated_layer) <- crs(districts)
ext(aggregated_layer) <- ext(districts)

district_true <- crop(aggregated_layer, districts)
plot(district_true)

district_mask_true <- mask(district_true, districts)
plot(district_mask_true)

coverage_stats <- exact_extract(
  district_mask_true,
  districts,
  fun = function(values, coverage_fraction) {
    if (length(values) == 0) {
      return(NA)
    }
    sum(values * coverage_fraction, na.rm = TRUE) / sum(coverage_fraction)
  }
)

districts$true_proportion <- coverage_stats

# taking all districts with at least 10% of eligible land
suitable_districts <- districts[districts$true_proportion >= 0.1, ]

# ---------------------------------------------------------
# CALCULATION OF STRONGEST PARTY PER (SUITABLE) DISTRICT
# ---------------------------------------------------------

# overlay municipalities/ election & districts
st_crs(suitable_districts) <- st_crs(election_mp)

intersections <- st_intersection(election_mp, suitable_districts) %>%
  mutate(area = st_area(.))

largest_intersections <- intersections %>%
  group_by(AGS) %>%
  filter(area == max(area)) %>%
  ungroup()

municipalities_overlay <- largest_intersections

districts_summary <- municipalities_overlay %>%
  group_by(GID_2) %>%
  mutate(total_valid_votes = sum(`Valid.votes`, na.rm = TRUE)) %>%
  mutate(weighted_score = `Valid.votes` / total_valid_votes) %>%
  summarise(Strongest_party = Strongest_party[which.max(weighted_score)], .groups = 'drop')

# ---------------------------------------------------------
# COMBINE WIND FARM AND DISTRICTS
# ---------------------------------------------------------

# drop non-unique wind farms (as we just count the point and not the turbines capacity)
wind_points_sf <- wind_points_sf %>%
  filter(!duplicated(st_geometry(.)))

# join wind farms and districts
wind_farms_districts <- st_join(wind_points_sf, districts, join = st_within)

district_wind_farms <- wind_farms_districts %>%
  group_by(GID_2) %>%
  summarise(count = n(), .groups = 'drop')

district_analysis <- left_join(districts_summary %>% as.data.frame(),
                               district_wind_farms %>% as.data.frame(),
                               by = "GID_2")
district_analysis <- st_sf(district_analysis, sf_column_name = "geometry.x")

# ---------------------------------------------------------
# CORRELATION
# ---------------------------------------------------------

correlation_result <- cor(district_analysis$Strongest_party, district_analysis$count)



ggplot() +
  geom_sf(data = wind_points_sf, aes(color = Status)) +
  geom_sf(data = district_analysis, aes(fill = Strongest_party))
