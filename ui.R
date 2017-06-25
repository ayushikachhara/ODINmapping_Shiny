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
      uiOutput("slider"),
      uiOutput("speed_value"), 
      uiOutput("step_size"), 
      h6(textOutput("selectedtime")),
      plotOutput("myPlot", height = "300px")
      ),
  mainPanel(plotlyOutput("plotly", height = "300px"),
            leafletOutput("myMap", height = "300px"),
            a(href="https://www.niwa.co.nz/atmosphere/research-projects/CommunityObservationNetworksforAir", "Find out more about CONA")
            )
  )
