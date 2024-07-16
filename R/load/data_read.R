library(here)
library(sf)

wind_points <- st_read(here("data","input", "Windkraftanlagen DE - Windkraftanlagen 2023", "Windkraftanlagen DE - Windkraftanlagen 2023.shp"))
plot(wind_points)

deu <- st_read(here("data","input", "gadm41_DEU_shp", "gadm41_DEU_2.shp"))
plot(deu)

rm(x)
