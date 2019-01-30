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

## Load libraries ---------------------------------------------------------------

library(tidyverse)
library(lubridate)

## Oshkosh data -----------------------------------------------------------------

oshkosh_temp_precip <- read_csv("./ames_oshkosh_weather/data/oshkosh_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date)) %>%
  filter(month == 1, day == 27) %>%
  select(name, year:day, tmax:tobs, prcp:snwd) %>%
  mutate(name = "Oshkosh, WI")

oshkosh_wind <- read_csv("./ames_oshkosh_weather/data/oshkosh_airport_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date)) %>%
  filter(month == 1, day == 27) %>%
  select(name, year:day, awnd, wsf5) %>%
  mutate(name = "Oshkosh, WI") %>%
  bind_rows(read_csv("./ames_oshkosh_weather/data/oshkosh_airport_weather.csv") %>%
              rename_all(tolower) %>%
              mutate(date = mdy(date),
                     year = year(date),
                     month = month(date),
                     day = day(date)) %>%
              filter(month == 1, day == 26, year == 2019) %>%
              select(name, year:day, awnd, wsf5) %>%
              mutate(name = "Oshkosh, WI")) %>%
  mutate(day = ifelse(day == 26, 27, day))

oshkosh_weather <- full_join(oshkosh_temp_precip, oshkosh_wind, by = c("name", "year", "month", "day"))

## Ames data --------------------------------------------------------------------

ames <- read_csv("./ames_oshkosh_weather/data/ames_weather.csv") %>%
  rename_all(tolower) %>%
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date)) %>%
  select(name, year:day, prcp:snwd, tmax:tobs, wsf5, awnd)

ames_temp_precip <- ames %>%
  filter(name == "AMES 5 SE, IA US",
         month == 1, 
         day == 27) %>%
  select(name, year:day, tmax:tobs, prcp:snwd) %>%
  mutate(name = "Ames, IA") %>%
  bind_rows(ames %>%
              filter(name %in% c("BOONE, IA US", "AMES 0.9 ENE, IA US"),
                     month == 1, 
                     day == 27, 
                     year == 2019) %>%
              select(name, year:day, tmax:tobs, prcp:snwd) %>%
              mutate(snow = ifelse(name == "BOONE, IA US", 1, snow),
                     snwd = ifelse(name == "BOONE, IA US", 5.5, snwd)) %>%
              slice(2) %>%
              mutate(name = "Ames, IA"))

ames_wind <- ames %>%
  filter(name == "AMES MUNICIPAL AIRPORT, IA US",
         month == 1, 
         day == 27) %>%
  select(name, year:day, awnd, wsf5) %>%
  bind_rows(ames %>%
              filter(name == "AMES MUNICIPAL AIRPORT, IA US",
                     month == 1, 
                     day == 26, 
                     year == 2019) %>%
              select(name, year:day, awnd, wsf5) %>%
              mutate(day = ifelse(day == 26, 27, day))) %>%
  mutate(name = "Ames, IA")
  
ames_weather <- full_join(ames_temp_precip, ames_wind, by = c("name", "year", "month", "day")) %>%
  mutate(snwd = as.numeric(snwd),
         tmax = as.numeric(tmax),
         tmin = as.numeric(tmin),
         tobs = as.numeric(tobs),
         awnd = as.numeric(awnd),
         wsf5 = as.numeric(wsf5))

## Join data --------------------------------------------------------------------

weather <- bind_rows(oshkosh_weather, ames_weather)

# Export the data
#write.csv(weather, "./ames_oshkosh_weather/data/weather_jan27.csv", row.names = FALSE)

