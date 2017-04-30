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


## read both the data files for wind and air quality data

data <- readOGR("/Users/sahilbhouraskar/Desktop/forApp/Data9082016/ODIN_9th_Aug_2016.shp")
data <- spTransform(data, CRS("+proj=longlat +datum=WGS84"))
data$date_time3 <- as.POSIXct(as.character(data$date_time2),format = "%Y%m%d%H%M%S")
binpal <- colorBin(c("Green","Orange","Red"),data$PM2_5, 10, pretty = TRUE)

data1 <- readOGR("/Users/sahilbhouraskar/Desktop/forApp/Data9082016/CONA_met_9th_Aug_v3.shp")
data1 <- spTransform(data1, CRS("+proj=longlat +datum=WGS84"))
data1$date_time3 <- as.POSIXct(as.character(data1$date_time2),format = "%Y%m%d%H%M%S")

ui <- fluidPage(
  titlePanel("9th August 2016"),uiOutput("slider_to_anim"),uiOutput("speed_value"))

server <- function(input,output) {
  output$slider_to_anim <- renderUI({
    sliderInput("timeRange", label = "Date/Time:",
                min = min(as.POSIXct(as.character(data$date_time2),
                                     format = "%Y%m%d%H%M%S")),
                max = max(as.POSIXct(as.character(data$date_time2),
                                     format = "%Y%m%d%H%M%S")),
                value = min(as.POSIXct(as.character(data$date_time2),
                                       format = "%Y%m%d%H%M%S")),
                animate = animationOptions(interval = input$speed)
                
  )
  })
  
  output$speed_value <- renderUI({
    numericInput("speed","Speed Value :",value = 60)
  })
}

shinyApp(ui, server)
