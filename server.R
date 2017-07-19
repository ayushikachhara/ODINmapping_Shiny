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
  
  ##datetime slider definition.
  output$slider <- renderUI({
    
    sliderInput("timeRange", label = "Date/Time:", width = '300px',
                min = min(data$date_time3),
                max = max(data$date_time3),
                value = min(data$date_time3),
                step = (60*input$step_size),
                animate = animationOptions(interval = 3200 - (input$speed*300),
                                           playButton = tags$img(height = 40,width = 45,
                                                                 src = "https://png.icons8.com/color/1600/circled-play", 
                                                                 tags$p(tags$b("PLAY"))),
                                           pauseButton = tags$img(height = 40, width = 45,
                                                                  src = "https://cdn2.iconfinder.com/data/icons/perfect-flat-icons-2/512/Pause_button_play_stop_blue.png",
                                                                  tags$p(tags$b("PAUSE"))))
                )
    
  })
  
  ##animation speed control
  output$speed_value <- renderUI({
    sliderInput("speed",
                label = div(style='width:300px;',
                            div(style='float:left;', 'slower'),
                            div(style='float:right;', 'faster')),
                min = 1, 
                max = 10, 
                value = 6, 
                width = '300px')
                
  })
  
  ##time step definition by user
  output$step_size <- renderUI({
    sliderInput("step_size","Time Steps (minutes):",
                min = 10, max = 60, value = 1, width = '300px')
  })
  
  ##subsetting dust data
  subsetData <- reactive({
    x <- data[which(data$date_time3 == "2016-08-12 NZST" & !is.na(data$PM2_5)),]
    order.x <- c(107,103,104,114,113,102,112,100,101,108,106)
    x <- x[order(match(x$ODIN,order.x)),]
    x$ODIN <- as.character(x$ODIN)
    return(x)
  
  })
  
  ##subsetting dust data
  subsetRaster <- reactive({
    idx <- which(date_vec == input$timeRange)
    return(full_raster[[idx]])
  })
  
  #subsetting wind_data
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
  
  ###datetime output
  output$selectedtime <- renderText({
       paste("Animation running from:   ", strftime(input$timeRange, "%d-%m-%Y  %H:%M:%S"))
  })
  
  ### barplot
  output$myPlot <- renderPlot({
    barplot(subsetData()$PM2_5,
            main = "ODIN Readings",
            xlab = "ODIN ID",
            ylab = "PM2.5 [ug/m3]",
            ylim=c(min(data$PM2_5, na.rm = T), 
                   max(data$PM2_5, na.rm = T)),
            names.arg = subsetData()$ODIN,
            col = "#F39C12",
            border = "black")
  })
  
  ##output with plotly data
  
  ##secondary y-axis definition.
  output$plotly <-renderPlotly({
    
    ##need to modify data_ecan here since .RData when read in, does not 
    ##remember the Datetime format and notes the time as UTC.
    
    data_ecan$DateTime <- as.POSIXct(strptime(as.character(data_ecan$DateTime),
                        format = "%d/%m/%y %H:%M", tz = "Pacific/Auckland"))
    
    data_ecan <- data_ecan[which(data_ecan$DateTime>"2016-08-11 23:59:00"),]
    ## defining the timezone for plot_ly
    second_axis <- list(
      tickfont = list(color = "#636363"),
      overlaying = "y",
      side = "right",
      title = "WSpeed",
      showgrid = F
    )
    
    ##creating the plotly line plot.
    plot_ly(data_ecan) %>%
      add_lines(x = ~DateTime, y = ~PM10, name = "PM10", color = I("#F39C12")) %>%
      
      add_lines(x = ~DateTime, y = ~u, name = "WSpeed",  yaxis = "y2", color =I("#2471A3")) %>%
      layout(
        title = "Ecan_Data", yaxis2 = second_axis,
        xaxis = list(range = c(input$timeRange,max(data_ecan$DateTime)),
                     rangeselector = list(buttons = list(
                       list(count = 7, label = "last week",step = "day", stepmode = "forward"),
                       list(count = 14,label = "last 2 weeks",step = "day", stepmode = "forward"),
                       list(step = "all"))),
                     rangeslider = list(type = "date"), title = "")) %>% 
      config(displayModeBar = FALSE)
  })
  
  ## ODIN static map.
  output$myMap <- renderLeaflet({
    leaflet() %>% addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addTiles(group = "Open Street Map") %>%
      addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
      fitBounds(data@bbox[1,1],
                data@bbox[2,1],
                data@bbox[1,2],
                data@bbox[2,2]) %>%
      addLegend(position = "bottomleft", 
                pal = binpal, 
                values = data$PM2_5, na.label = "not active") %>%
      addLayersControl(baseGroups = c("Toner", "Toner Lite", "Open Street Map"),
        overlayGroups = c("show labels"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup("show labels")
  })
  
  ## ODIN dynamic map.
    observe({
      leafletProxy('myMap') %>%
      clearGroup('B') %>%
      addCircleMarkers(data = subsetData(),
                       group = 'B',
                       color = ~binpal(PM2_5),
                       radius = 5,
                       label = ~paste("ODIN",as.character(ODIN)),
                       stroke = FALSE,
                       fillOpacity = 1) %>%
      addPolylines(data = filteredData(),
                   group = 'B',
                   opacity=1,
                   weight = 3,
                   color = "black") %>%
        addLabelOnlyMarkers(data=subsetData(),
                            group = "show labels",
                            label=~paste("ODIN",as.character(ODIN)),
                            labelOptions = labelOptions(noHide = T,
                                                        direction = 'auto')) %>%
        addRasterImage(data = subsetRaster(),
                       group = 'R',
                       color = binpal,
                       opacity = 0.75,
                       project = FALSE)
      

  })
}