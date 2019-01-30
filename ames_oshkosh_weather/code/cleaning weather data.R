# Cleaning Weather Data
# 2019-01-29 (a cold cold day...)

# Data obtained from: https://www.ncdc.noaa.gov/cdo-web/

# Variable definitions:
  # WSF2 - Fastest 2-minute wind speed
  # WDF2 - Direction of fastest 2-minute wind
  # AWND - Average wind speed
  # WSF5 - Fastest 5-second wind speed
  # WDF5 - Direction of fastest 5-second wind
  # SNOW - Snowfall
  # PGTM - Peak gust time
  # TMAX - Maximum temperature
  # TAVG - Average Temperature.
  # TMIN - Minimum temperature
  # PRCP - Precipitation
  # SNWD - Snow depth

## Libraries -------------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(lubridate)

## Ames data -------------------------------------------------------------------------

# Load in the Ames data and start the cleaning process
ames <- read_csv("./ames_oshkosh_weather/data/ames_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date)) %>%
  select(name, year:day, prcp:snwd, tmax:tobs, wsf5, awnd)

# Extract and clean the data from "AMES 5 SE, IA US" which has temperature and 
# precipitation variables
ames_temp_precip <- ames %>%
  filter(name == "AMES 5 SE, IA US") %>%
  select(name, year:day, tmax:tobs, prcp:snwd) %>%
  mutate(name = "Ames, IA",
         tmax = as.numeric(tmax),
         tmin = as.numeric(tmin),
         tobs = as.numeric(tobs),
         snow = as.numeric(snow),
         snwd = as.numeric(snwd))

# Extract the data from "AMES MUNICIPAL AIRPORT, IA US" which has wind variables
ames_wind <- ames %>%
  filter(name == "AMES MUNICIPAL AIRPORT, IA US") %>%
  select(name, year:day, awnd, wsf5) %>%
  mutate(name = "Ames, IA",
         awnd = as.numeric(awnd),
         wsf5 = as.numeric(wsf5))

# Join the weather data for Ames
ames_weather <- full_join(ames_temp_precip, ames_wind, 
                          by = c("name", "year", "month", "day")) 

## Oshkosh data ----------------------------------------------------------------------

# Clean the dataset with the temperature and precipitation variables for Oshkosh
oshkosh_temp_precip <- read_csv("./ames_oshkosh_weather/data/oshkosh_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date),
         name = "Oshkosh, WI") %>%
  select(name, year:day, tmax:tobs, prcp:snwd)

# Clean the dataset with the wind variables for Oshkosh
oshkosh_wind <- read_csv("./ames_oshkosh_weather/data/oshkosh_airport_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date),
         name = "Oshkosh, WI") %>%
  select(name, year:day, awnd, wsf5)

# Join the weather data for Oshkosh
oshkosh_weather <- full_join(oshkosh_temp_precip, oshkosh_wind, 
                             by = c("name", "year", "month", "day"))

## Join Ames and Oshkosh data --------------------------------------------------------

# Join the datasets
weather <- bind_rows(oshkosh_weather, ames_weather)

# Export the data
write.csv(x = weather, 
          file = "./ames_oshkosh_weather/data/ames_oshkosh_weather.csv", 
          row.names = FALSE)



