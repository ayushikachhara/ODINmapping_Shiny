#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)

# Define server logic 
server <- function(input,output) {
  
  subsetData <- reactive({
    new_data <- data[which(data$date_time3 == input$timeRange),]
    return(new_data)
  })
  
  filteredData <- reactive({
    sp.lines.df[sp.lines.df@data$w.date == input$timeRange,]
  })
  
  
  output$myMap <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      fitBounds(sp.lines.df@bbox[1,1], sp.lines.df@bbox[2,1], sp.lines.df@bbox[1,2], sp.lines.df@bbox[2,2]) %>%
      addLegend(position = "bottomleft", 
                pal = binpal, 
                values = data$PM2_5)
  })
  
  
  observe({
    leafletProxy('myMap') %>%
      clearGroup('A') %>%
      addCircleMarkers(data = subsetData(), group = 'A',
                       color = ~binpal(PM2_5), radius = ~PM2_5/5,
                       label = ~as.character(PM2_5),
                       stroke = FALSE, 
                       fillOpacity = 1) %>% clearShapes() %>%
      addPolylines(data = filteredData(), opacity=1, weigh = 3)
  })
}


# task necessary for 'observer' within 'server' function
for (i in c(1:max(sp.lines.df@data$id))) {
  colnames(sp.lines.df@lines[[i]]@Lines[[1]]@coords) <- c("lng","lat")
}