library(here)
library(ggplot2)
library(dplyr)

# load data from data_read.R
here("R/load/data_read.R") |> source()


# filter and clean wind_points
wind_points2 <- wind_points %>%
  filter(
    `Country/Area` == "Germany",
    `Installation Type` == "Onshore",
    `Status` %in% c("announced", "construction", "operating", "pre-construction")
  )

wind_points2 <- wind_points2 %>%
  select()

# create point layer out of wind farm data
wind_points_sf <- st_as_sf(wind_points,
                           coords = c("Longitude", "Latitude"),
                           crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
str(wind_points_sf)
ggplot() +
  geom_sf(data = wind_points_sf) +
  theme_minimal() +
  labs(title = "Point Layer from Excel Data", x = "Longitude", y = "Latitude")
