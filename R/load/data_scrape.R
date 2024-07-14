library(here)
library(sf)

wind_points <- st_read(here("data","input", "Windkraftanlagen DE - Windkraftanlagen 2023", "Windkraftanlagen DE - Windkraftanlagen 2023.shp"))
plot(wind_points)
