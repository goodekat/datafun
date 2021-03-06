# Cleaning tornado data

# Data obtained from: http://www.tornadohistoryproject.com/tornado/Iowa/table
# Link to variables: https://www.spc.noaa.gov/wcm/data/SPC_severe_database_description.pdf

## Libraries -------------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(lubridate)

## Data steps ------------------------------------------------------------------------

# Read in the tornado data
tornadoes <- read_csv("./iowa_tornadoes/data/iowa_tornado_data.csv")

# Clean the tornado data and extract the information I am interested in
tornadoes_2000_2017 <- tornadoes %>%
  mutate(Year = year(mdy(Date))) %>%
  filter(Year %in% c(2000:2017), 
         Segment != "State") %>%
  select(Date, Time, Fujita:Length, Damage)

# Export the tornado data
write_csv(tornadoes_2000_2017, "./iowa_tornadoes/data/iowa_tornadoes_2000_2017.csv")

