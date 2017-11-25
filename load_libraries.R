all.libraries <- c('leaflet', 'maps','mapproj',
                   'maptools','RColorBrewer', 'shiny',
                   'shinyjs','shinythemes','rgdal',
                   'sp', 'raster', 'mapview', 'automap',
                   'dygraphs','xts', 'plotly', 'lubridate')

if(length(new.pkgs <- setdiff(all.libraries, 
                              rownames(installed.packages())))) install.packages(new.pkgs)

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