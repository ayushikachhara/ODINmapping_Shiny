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
                                                                 src = "https://png.icons8.com/color/1600/circled-play"),
                                           pauseButton = tags$img(height = 40, width = 45,
                                                                  src = "https://cdn2.iconfinder.com/data/icons/perfect-flat-icons-2/512/Pause_button_play_stop_blue.png"))
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
  
  ##dust data
  subsetData <- reactive({
    return(data[which(data$date_time3 == input$timeRange & !is.na(data$PM2_5)),])
  })
  
  #take winddata from the selected time only
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
  
  ###datetime output
  output$selectedtime <- renderText({
  paste("", input$timeRange)
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
  
  ##output with ecan data
  output$plotly <-renderPlotly({
    second_axis <- list(
      tickfont = list(color = "#636363"),
      overlaying = "y",
      side = "right",
      title = "WSpeed",
      showgrid = F
    )
    plot_ly(data_ecan) %>%
      add_lines(x = ~DateTime, y = ~PM10, name = "PM10", color = I("#F39C12")) %>%
      add_lines(x = ~DateTime, y = ~u, name = "WSpeed",  yaxis = "y2", color =I("#2471A3")) %>%
      layout(
        title = "Ecan_Data", yaxis2 = second_axis,
        xaxis = list(range = c(min(data_ecan$DateTime),max(data_ecan$DateTime)),
                     rangeselector = list(buttons = list(
                       list(count = 1,label = "1st week",step = "7 days"),
                       list(count = 2,label = "2nd week",step = "14 days"),
                       list(step = "all"))),
                     rangeslider = list(type = "date"), title = ""))
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
                                                        direction = 'auto'))
  })
}

