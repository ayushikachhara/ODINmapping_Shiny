library(rgdal)
library(leaflet)
# Data path
data <- readOGR(paste0(data_folder,dust_file))
data <- spTransform(data, CRS(latlon_CRS))
data$date_time3 <- as.POSIXct(as.character(data$date_time2),format = "%Y%m%d%H%M%S")
binpal <- colorBin(c("Green","Orange","Red"),data$PM2_5, 10, pretty = TRUE)
