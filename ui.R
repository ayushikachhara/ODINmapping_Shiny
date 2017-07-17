# User interface definition for the Shiny app

# Load libraries
source('./load_libraries.R')

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

# Load data
source('./load_data.R')

# The user interface
ui <- fluidPage(
  titlePanel("Community Observations Network for Air - 2016"),
  sidebarLayout(
  sidebarPanel(id="sidebar",
      uiOutput("slider"),
      uiOutput("speed_value"), 
      uiOutput("step_size"), 
      plotOutput("myPlot", height = "300px")
      ),
  mainPanel(plotlyOutput("plotly", height = "300px"),
            a(href="https://cona-rangiora.blogspot.co.nz/", tags$b("CONA Blogspot")),
            h4(textOutput("selectedtime")),
            leafletOutput("myMap", height = "350px"),
            h6("The material provided on this website is either owned or licensed by NIWA and 
              Environment Canterbury and is subject to copyright.")
            )
  ),
  theme = shinytheme("superhero")
  )
