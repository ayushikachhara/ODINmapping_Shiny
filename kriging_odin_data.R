source('./load_libraries.R')
source('./constants_and_paths.R')
#source('./load_dust_data.R')

load('./dust_data.RData')
data.forkrig <- spTransform(data,CRS(NZTM_CRS))
data.forkrig$ODIN <- NULL
data.forkrig$date_time <- NULL
# data.forkrig$date_time2 <- NULL
data.forkrig$date <- NULL
# data.forkrig$time <- NULL
# data.forkrig$hr <- NULL
# data.forkrig$min <- NULL

print("Starting the kriging")

#Setting the  prediction grid properties
cellsize <- 100 #pixel size in projection units (NZTM, i.e. metres)
min_x <- data.forkrig@bbox[1,1] - cellsize#minimun x coordinate
min_y <- data.forkrig@bbox[2,1] - cellsize #minimun y coordinate
max_x <- data.forkrig@bbox[1,2] + cellsize #mximum x coordinate
max_y <- data.forkrig@bbox[2,2] + cellsize #maximum y coordinate

x_length <- max_x - min_x #easting amplitude
y_length <- max_y - min_y #northing amplitude

ncol <- round(x_length/cellsize,0) #number of columns in grid
nrow <- round(y_length/cellsize,0) #number of rows in grid

grid <- GridTopology(cellcentre.offset=c(min_x,min_y),cellsize=c(cellsize,cellsize),cells.dim=c(ncol,nrow))

#Convert GridTopolgy object to SpatialPixelsDataFrame object.
grid <- SpatialPixelsDataFrame(grid,
                              data=data.frame(id=1:prod(ncol,nrow)),
                              proj4string=CRS(NZTM_CRS))

plot(grid)



data.forkrig <- data.forkrig[!is.na(data.forkrig$PM2_5),]
all_dates <- sort(unique(data.forkrig$date_time3))

i <- 0
j <- 0
for (d_slice in all_dates[1:5000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
names(raster_cat) <- all_dates[1:5000]

print("Done with the kriging")

save(raster_cat,file = './raster_odin_1.RData')
rm(raster_cat)

i <- 0
j <- 0
for (d_slice in all_dates[5001:10000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    #to_rast <- spTransform(surf$krige_output,CRS(latlon_CRS))
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    #to_rast <- spTransform(surf$krige_output,CRS(latlon_CRS))
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
names(raster_cat) <- all_dates[5001:10000]
print("Done with the kriging")

save(raster_cat,file = './raster_odin_2.RData')
rm(raster_cat)


i <- 0
j <- 0
for (d_slice in all_dates[10001:15000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
print("Done with the kriging")
names(raster_cat) <- all_dates[10001:15000]

save(raster_cat,file = './raster_odin_3.RData')
rm(raster_cat)


i <- 0
j <- 0
for (d_slice in all_dates[15001:20000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
names(raster_cat) <- all_dates[15001:20000]
print("Done with the kriging")

save(raster_cat,file = './raster_odin_4.RData')
rm(raster_cat)


i <- 0
j <- 0
for (d_slice in all_dates[20001:25000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
names(raster_cat) <- all_dates[20001:25000]
print("Done with the kriging")

save(raster_cat,file = './raster_odin_5.RData')
rm(raster_cat)


i <- 0
j <- 0
for (d_slice in all_dates[25001:28000]){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- addLayer(raster_cat,r)
  }
  i<-i+1
  j<-j+1
  if (j>20){
    print(paste0("Done with ",i," surfaces"))
    j<-0
  }
}
names(raster_cat) <- all_dates[25001:28000]
print("Done with the kriging")

save(raster_cat,file = './raster_odin_6.RData')
rm(raster_cat)


