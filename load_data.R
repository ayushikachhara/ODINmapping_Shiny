#load data
## Get DUST data
load('./dust_data.RData')
binpal <- colorBin(c("Green","Orange","Red"),c(0,100), 10, pretty = TRUE)
date_vec <- seq(from = min(data$date_time3), to = max(data$date_time3),by = 60)
load('./krigged_data.RData')
load('./raster_odin.RData')
xi <- FALSE
# Get WIND data
load('./wind_data.RData')