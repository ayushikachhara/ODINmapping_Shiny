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
  # Variable to keep track of which layer to remove
  v <- reactiveValues(toggle = TRUE)
  # take data for the selected time only
  subsetData <- reactive({
    return(data[which(data$date_time3 == input$timeRange),])
  })
  subsetRaster <- reactive({
    idx <- which(date_vec == input$timeRange)
    return(raster_cat[[idx]])
  })
  #take winddata from the selected time only
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
  # take krigged data for the selected time only
  subset_K_Data <- reactive({
    new_K_data <- krigged_odin_data[which(krigged_odin_data$timestamp == input$timeRange),]
#    return(new_K_data)
  })

  # 'static' map definiton
  output$myMap <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      fitBounds(data@bbox[1,1],
                data@bbox[2,1],
                data@bbox[1,2],
                data@bbox[2,2]) %>%
      addLegend(position = "bottomleft", 
                pal = binpal, 
                values = data$PM2_5)
      
  })
  
  
  # 'user defined' map definiton

  observe({
    load(file = 'toggle.RData')
    if (toggle) {
      l_rast[1] <- 'D0'
      l_rast[2] <- 'D1'
      }
    else {
      l_rast[1] <- 'D1'
      l_rast[2] <- 'D0'
      }
    toggle <- !toggle
    save(toggle,file = './toggle.RData')
    leafletProxy('myMap',deferUntilFlush = FALSE) %>%
      addRasterImage(subsetRaster(),
                     group = l_rast[1],
                     color = binpal,
                     opacity = 0.5,
                     project = FALSE)
    print(paste('Added to',as.character(l_rast[1])))
    
    leafletProxy('myMap',deferUntilFlush = FALSE) %>%
      clearGroup('B') %>%
      addCircleMarkers(data = subsetData(),
                       group = 'B',
                       color = ~binpal(PM2_5),
                       radius = 5,
                       label = ~as.character(PM2_5),
                       stroke = FALSE,
                       fillOpacity = 0.5) %>%
      clearGroup('C') %>%
      addPolylines(data = filteredData(),
                   group = 'B',
                   opacity=1,
                   weigh = 3)
    
    print(paste('Cleared from',as.character(l_rast[2])))
    leafletProxy('myMap',deferUntilFlush = FALSE)  %>%
      clearGroup(l_rast[2])
  })
}
