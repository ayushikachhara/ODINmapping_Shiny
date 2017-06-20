# User interface definition for the Shiny app

# Load libraries

source('./load_libraries.R')

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

# Load data
source('./load_data.R')

ui <- fluidPage(
  titlePanel("9th August 2016"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("slider"),
      uiOutput("speed_value"), p("The smaller the number, the greater the speed"),
      uiOutput("step_size"), p("Please enter step size in seconds (minimum is 1 seconds")
      ), mainPanel(verbatimTextOutput("value"), leafletOutput("myMap"))
    )
)

                

server <- function(input,output) {
  output$slider <- renderUI({
    sliderInput("timeRange", label = "Date/Time:",
                min = min(as.POSIXct(as.character(data$date_time2),
                                     format = "%Y%m%d%H%M%S")),
                max = max(as.POSIXct(as.character(data$date_time2),
                                     format = "%Y%m%d%H%M%S")),
                value = min(as.POSIXct(as.character(data$date_time2),
                                       format = "%Y%m%d%H%M%S")),
                step = input$step_size,
                animate = animationOptions(interval = input$speed)
                
  )
  })
  
  output$speed_value <- renderUI({
    numericInput("speed","Speed Value :",value = 60)
  })
  
  output$step_size <- renderUI({
    numericInput("step_size","Step Size :",value = 60)
  })
  
  output$value <- renderText({
    input$timeRange
    class(input$timeRange)
  })
  
  # take data for the selected time only
  subsetData <- reactive({
    time1 <- parse(timeRange = input$timeRange)
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
    
    leafletProxy('myMap') %>%
      clearGroup('B') %>%
      addCircleMarkers(data = subsetData(),
                       group = 'B',
                       color = ~binpal(PM2_5),
                       radius = 8,
                       label = ~as.character(PM2_5),
                       stroke = FALSE,
                       fillOpacity = 0.5) %>%
      clearGroup('C') %>%
      addPolylines(data = filteredData(),
                   group = 'C',
                   opacity=1,
                   weigh = 3) %>%
      clearGroup('D') %>%
      addRasterImage(subsetRaster(),
                     group = 'D',
                     color = binpal,
                     opacity = 0.8,
                     project = FALSE)
  })
}


shinyApp(ui, server)
