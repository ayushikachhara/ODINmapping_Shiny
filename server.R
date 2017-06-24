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
    return(data[which(data$date_time3 == input$timeRange & !is.na(data$PM2_5)),])
  })
  

  #take winddata from the selected time only
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
  
  output$timeRange <- renderText({
    paste("Animation running from ", input$timeRange, "to 2016-08-31 10:39:00")
  })
  
  output$myPlot <- renderPlot({
    barplot(subsetData()$PM2_5,
            main = "ODIN Readings",
            xlab = "ODIN ID",
            ylab = "PM2.5 [ug/m3]",
            ylim=c(min(data$PM2_5, na.rm = T), max(data$PM2_5, na.rm = T)),
            names.arg = subsetData()$ODIN,
            col = "#2ca25f",
            border = "black")
  })
  
  output$plotly <-renderPlotly({
    second_axis <- list(
      tickfont = list(color = "#636363"),
      overlaying = "y",
      side = "right",
      title = "WSpeed",
      showgrid = F
    )
    plot_ly(data_ecan) %>%
      add_lines(x = ~DateTime, y = ~PM10, name = "PM10", color = I("#2ca25f")) %>%
      add_lines(x = ~DateTime, y = ~u, name = "WSpeed",  yaxis = "y2", color =I("#2b8cbe")) %>%
      layout(
        title = "Ecan_Data", yaxis2 = second_axis,
        xaxis = list(rangeslider = list(type = "date"), title = ""))
  })

  output$myMap <- renderLeaflet({
    leaflet() %>% addTiles(group = "Open Street Map") %>%
      addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
      fitBounds(sp.lines.df@bbox[1,1],
                sp.lines.df@bbox[2,1],
                sp.lines.df@bbox[1,2],
                sp.lines.df@bbox[2,2]) %>%
      addLegend(position = "bottomleft", 
                pal = binpal, 
                values = data$PM2_5, na.label = "not active") %>%
      addLayersControl(baseGroups = c("Open Street Map", "Toner", "Toner Lite"),
        overlayGroups = c("labels"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  
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
                   weight = ~as.numeric(w.speed)) %>%
        addLabelOnlyMarkers(data=subsetData(),
                            group = "labels",
                            label=~paste("ODIN",as.character(ODIN)),
                            labelOptions = labelOptions(noHide = T,
                                                        direction = 'auto'))
  })
  
}

