# User interface definition for the Shiny app

# Load libraries

source('./load_libraries.R')

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

# Load data
source('./load_data.R')

ui <- fluidPage(
  titlePanel("CONA: August 2016"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("slider"),
      uiOutput("speed_value"), p("The smaller the number, the greater the speed"),
      uiOutput("step_size"), p("Please enter step size in seconds (minimum is 1 seconds")
      ), mainPanel(verbatimTextOutput("value"))
    )
)

                

server <- function(input,output) {
  output$slider <- renderUI({
    sliderInput("timeRange", label = "Date/Time:",
                min = min(data$date_time3),
                max = max(data$date_time3),
                value = min(data$date_time3),
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
  #take winddata from the selected time only
  filteredData <- reactive({
    return(sp.lines.df[sp.lines.df@data$w.date == input$timeRange,])
  })
}


shinyApp(ui, server)
