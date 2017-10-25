list.of.packages <- c("leaflet","maps","mapproj",
                      "maptools","RColorBrewer",
                      "shiny","shinyjs","shinythemes",
                      "rgdal","sp","raster","mapview",
                      "automap","dygraqphs","xts","plotly", "lubridate")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


library(leaflet)
library(maps)
library(mapproj)
library(maptools)
library(RColorBrewer)
library(shiny)
library(shinyjs)
library(shinythemes)
library(rgdal)
library(sp)
library(raster)
library(mapview)
library(automap)
library(dygraphs)  ## new addition on 09/05/2017
library(xts)
library(plotly) 
library(lubridate)