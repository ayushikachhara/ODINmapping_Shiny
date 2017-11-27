# This is to centralize the path and constants defined in the app
data_folder <- "./Data/"
dust_file <- "ODIN_Roll_Phase2.shp"
wind_file <- "windPH2.shp"

latlon_CRS <- "+proj=longlat +datum=WGS84"
NZTM_CRS <- "+init=epsg:2193"

binpal <- colorBin(c("Green","Orange","Red"),c(0,140), 8, 
                   pretty = TRUE, na.color = "#00000000")