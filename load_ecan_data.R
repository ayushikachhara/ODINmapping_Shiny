data_ecan <- read.csv("./Data/August_Ecan.csv")
# data_ecan$DateTime<- as.POSIXct(strptime(as.character(data_ecan$DateTime),
#                                          format = "%d/%m/%y %H:%M", tz = "Pacific/Auckland"))
data_ecan <- data_ecan[which(data_ecan$DateTime>"2016-08-11 23:59:00"),]
save(data_ecan,file = './ecan_data.RData')


#data_ecan$DateTime2<- as.POSIXct(as.character(data_ecan$DateTime),format = "%d/%m/%y %H:%M")
