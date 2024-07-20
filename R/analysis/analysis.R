library(sf)
library(terra)
library(dplyr)
library(exactextractr)
library(nnet)
library(tidyr)
library(ggplot2)
library(broom)

here("R/wrangle/geo_wrangle.R") |> source()

# ---------------------------------------------------------
# ELIGIBLE DISTRICTS
# ---------------------------------------------------------

# calculate proportion of district where the aggregated layer is TRUE (land is considered eligible)
st_crs(districts) <- crs(aggregated_layer)
#ext(aggregated_layer) <- ext(districts)

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
  mutate(area = st_area(.)) #takes a couple minutes

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

district_analysis <- district_analysis %>%
  mutate(party_code = as.numeric(factor(Strongest_party)))

model <- lm(party_code ~ count, data = district_analysis)
summary(model)
broom_model <- tidy(model)
print(broom_model)

ggplot(district_analysis, aes(x = count, y = party_code)) +
  geom_point(aes(color = Strongest_party), alpha = 0.6) +
  geom_smooth(method = "lm",
              se = FALSE,
              color = "blue") +
  labs(x = "Count of Wind Farms", y = "Coded Strongest Party", title = "Relationship between Wind Farms and Party Strength") +
  theme_minimal()

multinom_model <- multinom(Strongest_party ~ count, data = district_analysis)

summary(multinom_model)

new_data <- data.frame(count = unique(district_analysis$count))
predicted_probs <- predict(multinom_model, newdata = new_data, type = "probs")

# Convert probabilities to a dataframe
probs_df <- as.data.frame(predicted_probs)
probs_df$count <- new_data$count

# Transform to long format for ggplot
plot_data <- tidyr::pivot_longer(
  probs_df,
  cols = -count,
  names_to = "Party",
  values_to = "Probability"
)

ggplot(plot_data, aes(x = count, y = Probability, color = Party)) +
  geom_line() +
  labs(title = "Probability of Each Party Being Strongest vs. Count of Wind Farms", x = "Count of Wind Farms", y = "Probability") +
  theme_minimal()

