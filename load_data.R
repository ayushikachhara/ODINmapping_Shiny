#load data
## Get DUST data
load('./dust_data.RData')
data$date_time3 <- with_tz(data$date_time3, "UTC")
data$date_time3 <- data$date_time3 +43200
binpal <- colorBin(c("Green","Orange","Red"),c(0,140), 8, 
                   pretty = TRUE, na.color = "#00000000")

date_vec <- seq(from = min(data$date_time3), to = max(data$date_time3),by = 60)

## load raster
load('./raster_odin.RData')
rbrick <- brick(full_raster)
# Get WIND data
load('./wind_data1.RData')

sp.lines.df$w.date <- with_tz(sp.lines.df$w.date, "UTC")
sp.lines.df$w.date <- sp.lines.df$w.date +43200

#Get Ecan data
load('./ecan_data.RData')
data_ecan$DateTime<- with_tz(data_ecan$DateTime, "UTC")
data_ecan$DateTime <- data_ecan$DateTime +43200

minimum.slider <-  data$date_time3[1]
maximum.slider <-  data$date_time3[length(data$date_time3)]
