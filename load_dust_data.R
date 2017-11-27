data <- readOGR(paste0(data_folder,dust_file))
data <- spTransform(data, CRS(latlon_CRS))
data$date_time3 <- as.POSIXct(as.character(data$date_time),format = "%d/%m/%y %H:%M")
data <- data[which(data$ODIN <=115),]
data <- data[order(data$date_time3),]
data_table <- as.data.frame(data)


# data_table <- dust_table1
save(data_table,file = './dust_datatable10min.RData')
save(data,file = './dust_data10min.RData')

## steps to convert csv to shapefile
a <- read.csv("./Data/ODIN_rollmean_long_withcoordinates.csv")
x <- data_table
coordinates(x) <- ~nztm_E+nztm_N
proj4string(x) <- CRS(NZTM_CRS)
y <- spTransform(x,CRS("+proj=longlat"))
y$nztm_E <- a$NZTM_E
y$nztm_N <- a$NZTM_N
#

data <- y
writeOGR(y, ".","dust_data10min", "ESRI Shapefile")
