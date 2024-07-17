library(here)
library(ggplot2)
library(dplyr)
library(sf)

# load data from data_read.R
here("R/load/data_read.R") |> source()

# ---------------------------------------------------------
# WIND FARM POINTS
# ---------------------------------------------------------

# filter and clean wind_points
wind_points <- wind_points %>%
  filter(
    `Country/Area` == "Germany",
    `Installation Type` == "Onshore",
    `Status` %in% c("announced", "construction", "operating", "pre-construction")
  )

# drop non-important columns
wind_points <- wind_points %>%
  select(
    `Date Last Researched`,
    `Country/Area`,
    `Project Name`,
    `Phase Name`,
    `Other Name(s)`,
    `Capacity (MW)`,
    `Installation Type`,
    `Status`,
    `Start year`,
    `Operator`,
    `Latitude`,
    `Longitude`,
    `Local area (taluk, county)`,
    `State/Province`
  )

# check for obvious duplicates
duplicates <- apply(wind_points, 1, function(row) {
  sum(duplicated(row)) >= 5
})
print(wind_points[duplicates, ])


# create point layer out of wind farm data
wind_points_sf <- st_as_sf(wind_points,
                           coords = c("Longitude", "Latitude"),
                           crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
str(wind_points_sf)

# factor Status for visualization
wind_points_sf$Status <- factor(wind_points_sf$Status)

# visualize with Status as Fill and Capacity as Size
ggplot() +
  geom_sf(data = deu) +
  geom_sf(data = subset, aes(color = Status, size = `Capacity (MW)`)) +
  scale_size_continuous(range = c(0.1, 2.5)) +
  theme_minimal() +
  labs(title = "Onshore Wind Farms Germany", x = "Longitude", y = "Latitude") +
  theme(plot.title = element_text(hjust = 0.5))

subset <- wind_points_sf[wind_points_sf$`Start year`>=2014, ]


# ---------------------------------------------------------
# ELECTION RESULTS
# ---------------------------------------------------------

# join election municipalities with election results
str(municipality)
str(election_2021)
election_2021$AGS <- as.character(election_2021$AGS)
election_mp <- municipality %>%
  left_join(election_2021, by = "AGS") %>%
  rename(Municipality = GEN, `Valid votes` = Gültige) %>%
  select(AGS, Municipality, everything()) %>%
  arrange(AGS)

# convert election results to numeric & determine strongest party for every municipality
election_mp <- election_mp %>%
  mutate(across(c(Union, SPD, Linke, AfD, FDP, Grüne, Sonstige), as.numeric))

election_mp <- election_mp %>%
  rowwise() %>%
  mutate(
    Strongest_party = if (all(is.na(c_across(c(Union, SPD, Linke, AfD, FDP, Grüne))))) {
      "No Data"
    } else {
      party_names <- c("Union", "SPD", "Linke", "AfD", "FDP", "Grüne")
      party_names[which.max(c_across(c(Union, SPD, Linke, AfD, FDP, Grüne)))]
    }
  ) %>%
  ungroup()

# factor Strongest_party for legend order
election_mp$Strongest_party <- factor(election_mp$Strongest_party, levels = c("Union", "SPD", "Linke", "AfD", "Grüne", "FDP", "No Data"))


ggplot() +
  geom_sf(data = election_mp, aes(fill = Strongest_party)) +
  scale_fill_manual(
    values = c(
      "Union" = "black",
      "SPD" = "red",
      "Linke" = "maroon3",
      "AfD" = "deepskyblue",
      "FDP" = "gold",
      "Grüne" = "green3",
      "No Data" = "grey"
    )
  ) +
  theme_minimal() + 
  labs(title = "Election Results by Municipality (2021)", x = "Longitude", y = "Latitude", fill = "") +
  theme(plot.title = element_text(hjust = 0.5))



# checken ob es sinn macht zu rasterizieren