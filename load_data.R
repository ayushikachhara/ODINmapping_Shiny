#load data
## Get DUST data
load('./dust_data.RData')
binpal <- colorBin(c("Green","Orange","Red"),data$PM2_5, 10, pretty = TRUE)
date_vec <- seq(from = min(data$date_time3), to = max(data$date_time3),by = 60)
load('./krigged_data.RData')
load('./raster_odin.RData')

# Get WIND data
load('./wind_data.RData')