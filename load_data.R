#load data
## Get DUST data
load('./dust_data.RData')
binpal <- colorBin(c("Green","Orange","Red"),c(0,140), 8, pretty = TRUE, na.color = "Black")
date_vec <- seq(from = min(data$date_time3), to = max(data$date_time3),by = 60)
load('./krigged_data.RData')
load('./raster_odin.RData')
#l_rast <- c('D0','D1')
# Get WIND data
load('./wind_data.RData')

#Get Ecan data
load('./ecan_data.RData')
