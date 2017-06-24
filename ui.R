# User interface definition for the Shiny app

# Load libraries

source('./load_libraries.R')

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

# Load data
source('./load_data.R')

# The user interface
ui <- pageWithSidebar(
  headerPanel("Community Observations Network for Air - 2016"),
  sidebarPanel(
    
    sliderInput("timeRange", label = "Date/Time:",
                min = min(data$date_time3),
                max = max(data$date_time3),
                value = min(data$date_time3),
                step = 600,
                animate = animationOptions(interval = 500,
                                           loop = FALSE)),
    h6(textOutput("timeRange")),
    plotOutput("myPlot")
    ),
  mainPanel(plotlyOutput("plotly", height = "300px"),leafletOutput("myMap", height = "300px"))
  )
