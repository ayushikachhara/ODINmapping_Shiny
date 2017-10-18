data_ecan <- read.csv("./Data/August_Ecan.csv")
data_ecan$NZTM_E <- rep(1571534, length(data_ecan$u))
data_ecan$NZTM_N <- rep(5204311, length(data_ecan$u))

x <- data_ecan
coordinates(x) <- ~NZTM_E+NZTM_N
proj4string(x) <- CRS(NZTM_CRS)
y <- spTransform(x,CRS("+proj=longlat"))
y$nztm_E <- data_ecan$NZTM_E
y$nztm_N <- data_ecan$NZTM_N
y$DateTime<- as.POSIXct(strptime(as.character(y$DateTime),
                                         format = "%d/%m/%y %H:%M", tz = "Pacific/Auckland"))

y <- y[which(y$DateTime>"2016-08-11 23:59:00"),]

writeOGR(y, ".","Data/data_ecan", "ESRI Shapefile")

data_ecan <- y
save(data_ecan,file = './ecan_data.RData')



