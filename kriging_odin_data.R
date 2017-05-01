source('./load_libraries.R')
source('./constants_and_paths.R')
source('./load_dust_data.R')

data.forkrig <- spTransform(data,CRS(NZTM_CRS))
data.forkrig$ODIN <- NULL
data.forkrig$date_time <- NULL
data.forkrig$date_time2 <- NULL
data.forkrig$date <- NULL
data.forkrig$time <- NULL
data.forkrig$hr <- NULL
data.forkrig$min <- NULL

print("Starting the kriging")

c_data <- subset(data.forkrig,subset = (date_time3==min(data.forkrig$date_time3)))
#Setting the  prediction grid properties
cellsize <- 100 #pixel size in projection units (NZTM, i.e. metres)
min_x <- c_data@bbox[1,1] - cellsize#minimun x coordinate
min_y <- c_data@bbox[2,1] - cellsize #minimun y coordinate
max_x <- c_data@bbox[1,2] + cellsize #mximum x coordinate
max_y <- c_data@bbox[2,2] + cellsize #maximum y coordinate

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


i <- 0
j <- 0

for (d_slice in sort(unique(data.forkrig$date_time3))){
  c_data <- subset(data.forkrig,subset = (date_time3==d_slice))
  surf <- autoKrige(PM2_5 ~ 1,
                    data=c_data,
                    new_data = grid,
                    input_data=c_data)
  surf$krige_output$timestamp <-as.POSIXct(d_slice,origin = '1970-01-01 NZST')
  if (i==0){
    x_data <- surf$krige_output@data
    x_bbox <- surf$krige_output@bbox
    x_coords <- surf$krige_output@coords
    x_coords.nrs <- c(1,2)
    #to_rast <- spTransform(surf$krige_output,CRS(latlon_CRS))
    to_rast <- surf$krige_output
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- NZTM_CRS
    r <- projectRasterForLeaflet(r0)
    raster_cat <- r
    
  }
  else {
    x_data <- rbind(x_data,surf$krige_output@data)
    x_coords <- rbind(x_coords,surf$krige_output@coords)
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
print("Done with the kriging")
x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
krigged_odin_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)


krigged_odin_data@proj4string <- CRS(NZTM_CRS)
krigged_odin_data <- spTransform(krigged_odin_data,CRS(latlon_CRS))
krigged_odin_data$PM2_5 <- krigged_odin_data$var1.pred
save(krigged_odin_data,file='./krigged_data.RData')

save(raster_cat,file = './raster_odin.RData')
