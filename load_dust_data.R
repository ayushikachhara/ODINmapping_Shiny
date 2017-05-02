library(rgdal)
library(leaflet)

data <- readOGR(paste0(data_folder,dust_file))
data <- spTransform(data, CRS(latlon_CRS))
data$date_time3 <- as.POSIXct(as.character(data$date_time2),format = "%Y%m%d%H%M%S")
save(data,file = './dust_data.RData')
