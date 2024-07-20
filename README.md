# Correlation Analysis: Onshore Wind Expansion & Local Voting Behavior

## Description

The project aims to examine a possible correlation between the onshore wind expansion as part of the ongoing energy transition AND voting behavior on municipality level representing the local political orientation. Average wind speeds and land use patterns are also recognized and included in the analysis.

## Table of Contents

-   [Description](#description)
-   [Data](#data)
-   [Installation](#installation)

## Data

Vector:

-   <https://www.zeit.de/politik/deutschland/2021-09/ergebnisse-bundestagswahl-gemeinde-karte>

-   <https://globalenergymonitor.org/projects/global-wind-power-tracker/>

-   <https://gadm.org/download_country.html>

Raster:

-   <https://www.mundialis.de/en/germany-2020-land-cover-based-on-sentinel-2-data/>

-   <https://opendata.dwd.de/climate_environment/CDC/grids_germany/multi_annual/wind_parameters/Project_QuWind100/future_2021_2050/fu_ff_mean_year_201902280000_l140.nc.bz2>

The raster data is too large to store in Github and must be therefore downloaded manually.

## Installation 

The necessary libraries are stored in renv and should be automatically activated when opening the project. To run the project files it is only necessary to execute the first chunk in the Final_Report.Rmd file. From there all the R files should complete in approximate time of 10 to 20 minutes.

-   Line 49 geo_wrangle.R takes about 15 mins
-   Line 48 analysis.R takes about 5-10 mins
