library(rgdal)
library(sp)

data1 <- readOGR(paste0(data_folder, wind_file))
data1 <- spTransform(data1, CRS(latlon_CRS))
data1$date_time3 <- as.POSIXct(as.character(data1$date_time2),format = "%Y%m%d%H%M%S")

# Creating arrows for the wind

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

proj4string(sp.lines) <- CRS(NZTM_CRS) # define CRS

#Convert CRS to geographic coordinates (http://spatialreference.org/ref/epsg/4326/)
#for overlaying on OpenStreetMaps tiles in Leaflet
sp.lines <- spTransform(sp.lines, CRS(latlon_CRS))


rownames(df) = df$id
#Join wind variables (id, speed, direction and date) to object of class 'SpatialLines'
sp.lines.df <- SpatialLinesDataFrame(sp.lines, df[,c(1,4:6)]) #object of class 'SpatialLinesDataFrame'
str(sp.lines.df) #inspect object structure

# task necessary for 'observer' within 'server' function
for (i in c(1:max(sp.lines.df@data$id))) {
  colnames(sp.lines.df@lines[[i]]@Lines[[1]]@coords) <- c("lng","lat")
}
