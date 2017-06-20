library(rgdal)
library(leaflet)

data <- readOGR(paste0(data_folder,dust_file))
data <- spTransform(data, CRS(latlon_CRS))
data$date_time3 <- as.POSIXct(as.character(data$date_time),format = "%d/%m/%y %H:%M")
data <- data[which(data$ODIN <=115),]
save(data,file = './dust_data.RData')

# ## steps to convert csv to shapefile
# a <- read.csv("./Data/windPH2.csv")
# x <- a
# coordinates(x) <- ~NZTM_E+NZTM_N
# proj4string(x) <- CRS(NZTM_CRS)
# y <- spTransform(x,CRS("+proj=longlat"))
# y$nztm_E <- a$NZTM_E
# y$nztm_N <- a$NZTM_N
# # 
# writeOGR(y, ".","Data/windPH2", "ESRI Shapefile")
