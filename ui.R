## whole of August.
## interpolated surfaces from 10 minute averages of raw data.
## smoothing upto an hour to look like ECAN data
## 

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


## for DUST

data <- readOGR("/Users/sahilbhouraskar/Desktop/forApp/Data/ODIN_9th_Aug_2016.shp")
data <- spTransform(data, CRS("+proj=longlat +datum=WGS84"))
data$date_time3 <- as.POSIXct(as.character(data$date_time2),format = "%Y%m%d%H%M%S")
binpal <- colorBin(c("Green","Orange","Red"),data$PM2_5, 10, pretty = TRUE)

data1 <- readOGR("/Users/sahilbhouraskar/Desktop/forApp/Data/CONA_met_9th_Aug_v3.shp")
data1 <- spTransform(data1, CRS("+proj=longlat +datum=WGS84"))
data1$date_time3 <- as.POSIXct(as.character(data1$date_time2),format = "%Y%m%d%H%M%S")

# for WIND 

#Starting x and y coordinates
start.x <- data1$NZTM_E #longitude
start.y <- data1$NZTM_N #latitude

#Wind variables (speed, direction and date)
w.speed <- data1$U #wind speed
w.direction <- data1$dd #wind azimuth angle (degrees)
w.date <- data1$date_time3 #datetime of data collection (yyyy-mm-dd)
id <- c(1:length(start.x)) #id of sample data

#Dataframe with georeferenced wind data
df <- data.frame(id=id,start.x=start.x,start.y=start.y,w.speed=w.speed,w.direction=w.direction,w.date=w.date)

#------------------------------
#Step 2 - Complement `df` with auxiliary coordinates for representing wind as arrowhead lines.

#Line parameters
line.length <- 1000 #length of polylines representing wind in the map (meters)
arrow.length <- 300 #lenght of arrowhead leg (meters)
arrow.angle <- 120 #angle of arrowhead leg (degrees azimuth)

#Generate data frame with auxiliary coordinates
end.xy.df <- data.frame(end.x=NA,end.y=NA,end.arrow.x=NA,end.arrow.y=NA)

for (i in c(1:nrow(df))){
  
  #coordinates of end points for wind lines (the initial points are the ones where data was observed)
  if (df$w.direction[i] <= 90) {
    end.x <- df$start.x[i] + (cos((90 - df$w.direction[i]) * 0.0174532925) * line.length)
  } else if (df$w.direction[i] > 90 & df$w.direction[i] <= 180) {
    end.x <- df$start.x[i] + (cos((df$w.direction[i] - 90) * 0.0174532925) * line.length)
  } else if (df$w.direction[i] > 180 & df$w.direction[i] <= 270) {
    end.x <- df$start.x[i] - (cos((270 - df$w.direction[i]) * 0.0174532925) * line.length)
  } else {end.x <- df$start.x[i] - (cos((df$w.direction[i] - 270) * 0.0174532925) * line.length)}
  
  if (df$w.direction[i] <= 90) {
    end.y <- df$start.y[i] + (sin((90 - df$w.direction[i]) * 0.0174532925) * line.length)
  } else if (df$w.direction[i] > 90 & df$w.direction[i] <= 180) {
    end.y <- df$start.y[i] - (sin((df$w.direction[i] - 90) * 0.0174532925) * line.length)
  } else if (df$w.direction[i] > 180 & df$w.direction[i] <= 270) {
    end.y <- df$start.y[i] - (sin((270 - df$w.direction[i]) * 0.0174532925) * line.length)
  } else {end.y <- df$start.y[i] + (sin((df$w.direction[i] - 270) * 0.0174532925) * line.length)}
  
  #coordinates of end points for arrowhead leg lines (the initial points are the previous end points)
  end.arrow.x <- end.x + (cos((df$w.direction[i] + arrow.angle) * 0.0174532925) * arrow.length)
  end.arrow.y <- end.y - (sin((df$w.direction[i] + arrow.angle) * 0.0174532925) * arrow.length)
  
  end.xy.df <- rbind(end.xy.df,c(end.x,end.y,end.arrow.x,end.arrow.y)) 
}

end.xy <- end.xy.df[-1,]
df <- data.frame(df,end.xy) #df with observed and auxiliary variables

#Step 3 - Create an object of class `SpatialLinesDataFrame` to use within `leaflet`.

lines <- data.frame(cbind(lng=c(df$start.x,df$end.x,df$end.arrow.x),
                          lat=c(df$start.y,df$end.y,df$end.arrow.y),
                          id=c(rep(df$id,3))))

lines.list <- list()

for (i in c(1:max(lines$id))){
  line <- subset(lines,lines$id==i)
  line <- as.matrix(line[,c(1:2)])
  line <- Line(line) #object of class 'Line'
  lines.list[[i]] <- Lines(list(line), ID = i) #list of 'objects'Lines' 
}

sp.lines <- SpatialLines(lines.list) #object of class 'SpatialLines'

proj4string(sp.lines) <- CRS("+init=epsg:2193") # define CRS

#Convert CRS to geographic coordinates (http://spatialreference.org/ref/epsg/4326/)
#for overlaying on OpenStreetMaps tiles in Leaflet
sp.lines <- spTransform(sp.lines, CRS("+proj=longlat +datum=WGS84"))


rownames(df) = df$id
#Join wind variables (id, speed, direction and date) to object of class 'SpatialLines'
sp.lines.df <- SpatialLinesDataFrame(sp.lines, df[,c(1,4:6)]) #object of class 'SpatialLinesDataFrame'
str(sp.lines.df) #inspect object structure


ui <- fluidPage(
  titlePanel("9th August 2016, Rangiora"),
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

#task necessary for 'observer' within 'server' function
for (i in c(1:max(sp.lines.df@data$id))) {
  colnames(sp.lines.df@lines[[i]]@Lines[[1]]@coords) <- c("lng","lat")
}

server <- function(input,output) {
  
  subsetData <- reactive({
    new_data <- data[which(data$date_time3 == input$timeRange),]
    return(new_data)
  })
  
  filteredData <- reactive({
    sp.lines.df[sp.lines.df@data$w.date == input$timeRange,]
  })
  

  output$myMap <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      fitBounds(sp.lines.df@bbox[1,1], sp.lines.df@bbox[2,1], sp.lines.df@bbox[1,2], sp.lines.df@bbox[2,2]) %>%
      addLegend(position = "bottomleft", 
                pal = binpal, 
                values = data$PM2_5)
  })
  
  
  observe({
    leafletProxy('myMap') %>%
      clearGroup('A') %>%
      addCircleMarkers(data = subsetData(), group = 'A',
                       color = ~binpal(PM2_5), radius = ~PM2_5/5,
                       label = ~as.character(PM2_5),
                       stroke = FALSE, 
                       fillOpacity = 1) %>% clearShapes() %>%
      addPolylines(data = filteredData(), opacity=1, weigh = 3)
  })
}

shinyApp(ui, server)
