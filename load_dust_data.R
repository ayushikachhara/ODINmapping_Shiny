library(rgdal)
library(leaflet)

data <- readOGR(paste0(data_folder,dust_file))
data <- spTransform(data, CRS(latlon_CRS))
data$date_time3 <- as.POSIXct(as.character(data$date_time),format = "%d/%m/%y %H:%M")
data <- data[which(data$ODIN <=115),]
data <- data[order(data$date_time3),]
data_table <- as.data.frame(data)

save(data_table,file = './dust_datatable.RData')
save(data,file = './dust_data.RData')

## steps to convert csv to shapefile
a <- read.csv("./Data/ODIN_rollmean_long_withcoordinates.csv")
x <- a
coordinates(x) <- ~NZTM_E+NZTM_N
proj4string(x) <- CRS(NZTM_CRS)
y <- spTransform(x,CRS("+proj=longlat"))
y$nztm_E <- a$NZTM_E
y$nztm_N <- a$NZTM_N
#
writeOGR(y, ".","Data/ODIN_Roll_Phase2", "ESRI Shapefile")
