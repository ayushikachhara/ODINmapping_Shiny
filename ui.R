# User interface definition for the Shiny app

# Load libraries

library(leaflet)
library(maps)
library(mapproj)
library(maptools)
library(RColorBrewer)
library(shiny)
library(rgdal)
library(sp)
library(raster)
library(mapview)

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

## Get DUST data
source('./load_dust_data.R')

# Get WIND data
source('./load_wind_data.R')

# The user interface
ui <- fluidPage(
  titlePanel("9th August 2016"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("timeRange", label = "Date/Time:",
                  min = min(as.POSIXct(as.character(data$date_time2),
                                       format = "%Y%m%d%H%M%S")),
                  max = max(as.POSIXct(as.character(data$date_time2),
                                       format = "%Y%m%d%H%M%S")),
                  value = min(as.POSIXct(as.character(data$date_time2),
                                         format = "%Y%m%d%H%M%S")),
                  step = 60,animate = TRUE)
    ),
    mainPanel(leafletOutput("myMap")
    )
  )
)