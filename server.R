#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
data_ecan <- as.data.frame(data_ecan)
##### define a function to generate slider at each radiobutton input. #######
sliderType <- function(type, steps) {
  switch(type,
         Slow = sliderInput("timeRange", label = "Date/Time:", width = '600px',
                            min = minimum.slider,
                            max = maximum.slider,
                            value = minimum.slider,
                            step = 60*steps,
                            timezone = "UTC",
                            animate = animationOptions(interval = 3000,
                                                       playButton = tags$img(height = 40,width = 45,
                                                                             src = "https://png.icons8.com/color/1600/circled-play",
                                                                             tags$p(tags$b("PLAY"))),
                                                       pauseButton = tags$img(height = 40, width = 45,
                                                                              src = "https://cdn2.iconfinder.com/data/icons/perfect-flat-icons-2/512/Pause_button_play_stop_blue.png",
                                                                              tags$p(tags$b("PAUSE"))))
         ),
         Medium = sliderInput("timeRange", label = "Date/Time:", width = '600px',
                              min = minimum.slider,
                              max = maximum.slider,
                              value = minimum.slider,
                              step = 60*steps,
                              timezone = "UTC",
                              animate = animationOptions(interval = 1000,
                                                         playButton = tags$img(height = 40,width = 45,
                                                                               src = "https://png.icons8.com/color/1600/circled-play",
                                                                               tags$p(tags$b("PLAY"))),
                                                         pauseButton = tags$img(height = 40, width = 45,
                                                                                src = "https://cdn2.iconfinder.com/data/icons/perfect-flat-icons-2/512/Pause_button_play_stop_blue.png",
                                                                                tags$p(tags$b("PAUSE"))))
         ),
         Fast = sliderInput("timeRange", label = "Date/Time:", width = '600px',
                            min = minimum.slider,
                            max = maximum.slider,
                            value = minimum.slider,
                            step = 60*steps,
                            timezone = "UTC",
                            animate = animationOptions(interval = 500,
                                                       playButton = tags$img(height = 40,width = 45,
                                                                             src = "https://png.icons8.com/color/1600/circled-play",
                                                                             tags$p(tags$b("PLAY"))),
                                                       pauseButton = tags$img(height = 40, width = 45,
                                                                              src = "https://cdn2.iconfinder.com/data/icons/perfect-flat-icons-2/512/Pause_button_play_stop_blue.png",
                                                                              tags$p(tags$b("PAUSE"))))
         ))
  }


#### Define server logic #######
server <- function(input,output,session) {
  ### update sliderinput based on the various other inputs ####
  observeEvent(input$speed,{
      val <- input$timeRange
      updateSliderInput(session, "timeRange",value=val)
      })
  observeEvent(input$`3hour_f`,{
    val <- input$timeRange + 10800
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$`6hour_f`,{
    val <- input$timeRange + 21600
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$`12hour_f`,{
    val <- input$timeRange + 43200
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$day_f,{
    val <- input$timeRange + 86400
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$`3hour_b`,{
    val <- input$timeRange - 10800
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$`6hour_b`,{
    val <- input$timeRange - 21600
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$`12hour_b`,{
    val <- input$timeRange - 43200
    updateSliderInput(session, "timeRange",value=val)
  })
  
  observeEvent(input$day_b,{
    val <- input$timeRange - 86400
    updateSliderInput(session, "timeRange",value=val)
  })
  
  
  observeEvent(input$step_size,{
    val <- input$timeRange
    updateSliderInput(session, "timeRange",value=val)
  })
# #
### datetime slider definition.######
  output$slider <- renderUI({
  sliderType(input$speed, input$step_size)
    })
  
  ##### subset raster #####
  subsetRaster <- reactive({
    req(input$timeRange)
    idx <- which(date_vec == input$timeRange)
    # print(idx)
    projected.raster <- projectRaster(rbrick[[idx]], crs = latlon_CRS)
    return(projected.raster)
  })
  
  ##subsetting dust data ######
  subsetData <- reactive({
    x <- data[which(data$date_time3 == input$timeRange & !is.na(data$PM2_5)),]
    order.x <- c(103,110,107,115,114,104,113,106,102,101,109,112,100,105,108)
    x <- x[order(match(x$ODIN,order.x)),]
    x$ODIN <- as.character(x$ODIN)
    return(x)
  
  })
  

  #subsetting wind_data #####
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
  
############### OUTPUTS ############################
  
  # ODIN static map.#########
  output$myMap <- renderLeaflet({
    leaflet() %>% 
      fitBounds(data@bbox[1,1],
                data@bbox[2,1],
                data@bbox[1,2],
                data@bbox[2,2]) %>%
      leaflet::addLegend(position = "bottomleft",
                pal = binpal,
                values = data$PM2_5, na.label = "not active") %>%
      addLayersControl(baseGroups = c("Toner", "Toner Lite", "Open Street Map"),
        overlayGroups = c("ODIN_sites","PM2.5(interpolated)","Wind", "show labels"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup("show labels")
  })
  
  # output$myMap <- renderUI({
  #   
  #   m1 <-mapview(subsetData(),
  #                zcol = "PM2_5", 
  #                col.regions = binpal(50), 
  #                layer.name = "ODIN sites", legend = T)
  # 
  #   m2 <- mapview(subsetRaster(), map = m1,
  #                 col.regions = binpal(50),
  #                 layer.name ="interpolated PM2.5")
  #   
  #   m3 <- mapview(filteredData(),
  #                 layer.name ="Wind Sites")
  #   sync(m2,m3)
  # })
  ### barplot ######
  output$myPlot <- renderPlot({
    invalidateLater(5000,session)
    
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
  
  
  ###### plotly output ####
  output$plotly <-renderPlotly({
    invalidateLater(5000,session)


    ##secondary y-axis definition.
    second_axis <- list(
      tickfont = list(color = "#636363"),
      overlaying = "y",
      side = "right",
      title = "WSpeed",
      showgrid = F
    )

    ## creating the plotly line plot.
    p <- plot_ly(data_ecan) %>%
      add_lines(x = ~DateTime, y = ~PM10, name = "PM10", color = I("#F39C12")) %>%
      add_lines(x = ~DateTime, y = ~u, name = "WSpeed",  yaxis = "y2", color =I("#2471A3")) %>%
      layout(
        shapes = list(
          list(type = "line",
               fillcolor = "black", line = list(color = "black"), opacity = 1,
               x0 = input$timeRange, x1 = input$timeRange, xref = "x",
               y0 = 0, y1 = 140, yref = "y")),
        title = "ECAN_Rangiora Site", yaxis2 = second_axis,
        xaxis = list(range = c(input$timeRange -129600,input$timeRange +129600),
                     rangeslider = list(type = "date"), title = "")) %>%
      config(displayModeBar = FALSE)
	p$elementId <- NULL
	p
  })
  
  ### datetime output: #####
  output$selectedtime <- renderText({
    paste(format(input$timeRange))
  })

  
  ## ODIN dynamic map.####
    observe({
     
      leafletProxy('myMap', deferUntilFlush = FALSE) %>%
        addProviderTiles(providers$Stamen.Toner, group = "Toner",
                         options = providerTileOptions(opacity = 1)) %>%
        addTiles(group = "Open Street Map",
                 options = tileOptions(opacity = 1)) %>%
        addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite",
                         options = providerTileOptions(opacity = 1)) %>%
        clearGroup('Wind') %>%
        addRasterImage(subsetRaster(),
                       group = "PM2.5(interpolated)",
                       colors = binpal,
                       project = FALSE,
                       opacity = 0.70) %>%
        addCircleMarkers(data = subsetData(),
                       group = 'ODIN_sites',
                       color = "black",
                       weight = 2,
                       fillColor = ~binpal(PM2_5),
                       radius = 7,
                       label = ~paste("ODIN",as.character(ODIN)),
                       stroke = TRUE,
                       fillOpacity = 1) %>%
        addPolylines(data = filteredData(),
                     group = 'Wind',
                     opacity=1,
                     weight = 3,
                     color = "black") %>%
        addLabelOnlyMarkers(data=subsetData(),
                            group = "show labels",
                            label=~paste("ODIN",as.character(ODIN)),
                            labelOptions = labelOptions(noHide = T,
                                                         direction = 'auto'))
  })
}