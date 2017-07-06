library(rgdal)
library(sp)

data1 <- readOGR(paste0(data_folder, wind_file))
data1 <- spTransform(data1, CRS(latlon_CRS))
data1$date_time3 <- as.POSIXct(as.character(data1$DateTime),format = "%d/%m/%y %H:%M")
data1 <- data1[which(as.character(data1$site) != "EWS"),]
# Creating arrows for the wind
coords <- as.data.frame(data1@coords)
#Starting x and y coordinates
start.x <-  data1$nztm_E #longitude
start.y <- data1$nztm_N  #latitude

#Wind variables (speed, direction and date)

w.speed <- data1$u #wind speed
w.direction <- data1$dd #wind azimuth angle (degrees)
w.date <- data1$date_time3 #datetime of data collection (yyyy-mm-dd)
id <- c(1:length(start.x)) #id of sample data

#Dataframe with georeferenced wind data
df <- data.frame(id=id,start.x=start.x,start.y=start.y,w.speed=w.speed,w.direction=w.direction,w.date=w.date)

#------------------------------
#Step 2 - Complement `df` with auxiliary coordinates for representing wind as arrowhead lines.

#Line parameters
line.length <- 50+300*w.speed  #length of polylines representing wind in the map (meters)
arrow.length <- 0.2*line.length #length of arrowhead leg (meters) ## note: this length is from the 'end' point. So the length is actually 1000+-800cos/sin120.
arrow.angle <- 30 #angle of arrowhead leg (degrees azimuth)

#Generate data frame with auxiliary coordinates
end.xy.df <- data.frame(end.x=NA,end.y=NA,end.arrow.x1=NA,end.arrow.y1=NA,end.arrow.x2=NA,end.arrow.y2 = NA)

for (i in c(1:nrow(df))){
  
  #coordinates of end points for wind lines (the initial points are the ones where data was observed)
  if (df$w.direction[i] <= 90) {
    end.x <- df$start.x[i] + (cos((90 - df$w.direction[i]) * 0.0175) * line.length[i])
  } else if (df$w.direction[i] > 90 & df$w.direction[i] <= 180) {
    end.x <- df$start.x[i] + (cos((df$w.direction[i] - 90) * 0.0175) * line.length[i])
  } else if (df$w.direction[i] > 180 & df$w.direction[i] <= 270) {
    end.x <- df$start.x[i] - (cos((270 - df$w.direction[i]) * 0.0175) * line.length[i])
  } else {end.x <- df$start.x[i] - (cos((df$w.direction[i] - 270) * 0.0175) * line.length[i])}
  
  if (df$w.direction[i] <= 90) {
    end.y <- df$start.y[i] + (sin((90 - df$w.direction[i]) * 0.0175) * line.length[i])
  } else if (df$w.direction[i] > 90 & df$w.direction[i] <= 180) {
    end.y <- df$start.y[i] - (sin((df$w.direction[i] - 90) * 0.0175) * line.length[i])
  } else if (df$w.direction[i] > 180 & df$w.direction[i] <= 270) {
    end.y <- df$start.y[i] - (sin((270 - df$w.direction[i]) * 0.0175) * line.length[i])
  } else {end.y <- df$start.y[i] + (sin((df$w.direction[i] - 270) * 0.0175) * line.length[i])}
  
  #coordinates of end points for arrowhead leg lines (the initial points are the previous end points)

  end.arrow.x1 <- df$start.x[i] + (arrow.length[i]/line.length[i])*((end.x - df$start.x[i])*cos(arrow.angle*0.0175) + 
                                                                (end.y - df$start.y[i]) *sin(arrow.angle*0.0175))
  end.arrow.y1 <- df$start.y[i] + (arrow.length[i]/line.length[i])*((end.y - df$start.y[i])*cos(arrow.angle*0.0175) -
                                                                (end.x - df$start.x[i]) *sin(arrow.angle*0.0175))
  
  end.arrow.x2 <- df$start.x[i] + (arrow.length[i]/line.length[i])*((end.x - df$start.x[i])*cos(arrow.angle*0.0175) - 
                                                                (end.y - df$start.y[i]) *sin(arrow.angle*0.0175))
  end.arrow.y2 <- df$start.y[i] + (arrow.length[i]/line.length[i])*((end.y - df$start.y[i])*cos(arrow.angle*0.0175) +
                                                                (end.x - df$start.x[i]) *sin(arrow.angle*0.0175))
  
  

  end.xy.df <- rbind(end.xy.df,c(end.x,end.y,end.arrow.x1,
                                 end.arrow.y1,end.arrow.x2,end.arrow.y2)) 
  
  print(i)
}

end.xy <- end.xy.df[-1,]
df <- data.frame(df,end.xy) #df with observed and auxiliary variables

## Create an object of class `SpatialLinesDataFrame` to use within `leaflet`

lines <- data.frame(cbind(lng=c(df$end.x,df$start.x,df$end.arrow.x1,df$start.x,df$end.arrow.x2),
                          lat=c(df$end.y,df$start.y,df$end.arrow.y1,df$start.y,df$end.arrow.y2),
                          id=c(rep(df$id,5))))

lines.list <- list()

for (i in c(1:max(lines$id))){
  line <- subset(lines,lines$id==i)
  line <- as.matrix(line[,c(1:2)])
  line <- Line(line) #object of class 'Line'
  lines.list[[i]] <- Lines(list(line), ID = i) #list of 'objects'Lines' 
  print(i)
}

#object of class 'SpatialLines'2

sp.lines <- SpatialLines(lines.list, proj4string = CRS(NZTM_CRS)) 
#for overlaying on OpenStreetMaps tiles in Leaflet
sp.lines <- spTransform(sp.lines, CRS(latlon_CRS))


rownames(df) = df$id
#Join wind variables (id, speed, direction and date) to object of class 'SpatialLines'
sp.lines.df <- SpatialLinesDataFrame(sp.lines, df[,c(1,4:6)]) #object of class 'SpatialLinesDataFrame'


# task necessary for 'observer' within 'server' function
for (i in c(1:max(sp.lines.df@data$id))) {
  colnames(sp.lines.df@lines[[i]]@Lines[[1]]@coords) <- c("lng","lat")
  print(i)
}
#writeOGR(sp.lines.df, ".","Data/windPH2_line", "ESRI Shapefile")
save(sp.lines.df,file = './wind_data1.RData')

