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
  useShinyjs(),
  titlePanel("Community Observations Network for Air - 2016"),
  sidebarLayout(
    
  sidebarPanel(width = 6,id="sidebar", 
      
      uiOutput("slider"),
      
      radioButtons("speed", tags$b(h4("Animation Speed:")),
                   list("Slow", "Medium", "Fast"), selected = "Medium", inline = T, width = '300px'),
      
      sliderInput("step_size",tags$b(h4("Time Steps (in minutes:)")),
                  min = 10, max = 60, value = 1, step = 10, width = '300px'), 
    
      plotOutput("myPlot", height = "300px")
      ),
  
  mainPanel(width = 6,
            plotlyOutput("plotly", height = "300px"),
            a(href="https://cona-rangiora.blogspot.co.nz/", tags$b("CONA Blogspot")),
            h4(textOutput("selectedtime")),
            leafletOutput("myMap", height = "350px"),
            h6("The material provided on this website is either owned or licensed by NIWA and 
              Environment Canterbury and is subject to copyright.")
            )
  ),
  theme = shinytheme("superhero")
  )
