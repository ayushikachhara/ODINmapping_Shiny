#load data
## Get DUST data
load('./dust_data10min.RData')
data$date_time3 <- as.POSIXct(as.character(data$date_time3), format = "%Y-%m-%d %H:%M:%S")
data$date_time3 <- with_tz(data$date_time3, "UTC")
data$date_time3 <- data$date_time3 +43200

date_vec <- seq(from = min(data$date_time3), to = max(data$date_time3),by = 600)


## load raster
#load('./raster_odin.RData')
load('./raster_odinbrick.RData')

# Get WIND data
load('./wind_data10min.RData')

sp.lines.df$w.date <- with_tz(sp.lines.df$w.date, "UTC")
sp.lines.df$w.date <- sp.lines.df$w.date +43200

#Get Ecan data
load('./ecan_datatable.RData')

#data_ecan <- data_ecan.table

data_ecan$DateTime<- with_tz(data_ecan$DateTime, "UTC")
data_ecan$DateTime <- data_ecan$DateTime #+43200

minimum.slider <-  data$date_time3[1]
maximum.slider <-  data$date_time3[length(data$date_time3)]

