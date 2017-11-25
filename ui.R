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
    
  sidebarPanel(width = 6,id="sidebar", 
      
      uiOutput("slider"),
      
      radioButtons("speed", tags$b(h4("Animation Speed:")),
                   list("Slow", "Medium", "Fast"), 
                   selected = "Medium", inline = T, width = '300px'),
      
      sliderInput("step_size",tags$b(h4("Time Steps (in minutes:)")),
                  min = 10, max = 60, value = 1, step = 10, width = '300px'),

      plotOutput("myPlot", height = "300px"),
                 tags$style(type="text/css", "#myPlot.recalculating { opacity: 1 !important;}")
      ),
  
  mainPanel(width = 6,
            plotlyOutput("plotly", height = "300px"),
                         tags$style(type="text/css", "#plotly.recalculating { opacity: 1.0; }"),
            hr(),
            h4("Forward by:"),
            actionButton("3hour_f", "3 hours", class="btn btn-primary btn-sm"),
            actionButton("6hour_f", "6 hours", class="btn btn-primary btn-sm"),
            actionButton("12hour_f", "12 hours", class="btn btn-primary btn-sm"),
            actionButton("day_f", "1 day", class="btn btn-primary btn-sm"),
            p(),
            h4("Rewind by:"),
            actionButton("3hour_b","3 hours", class="btn btn-primary btn-sm"),
            actionButton("6hour_b","6 hours", class="btn btn-primary btn-sm"),
            actionButton("12hour_b","12 hours", class="btn btn-primary btn-sm"),
            actionButton("day_b", "1 day", class="btn btn-primary btn-sm"),
            hr(),
            h4(textOutput("selectedtime")),
            tags$style(type="text/css", "#selectedtime.recalculating { opacity: 1.0; }"),
      
            uiOutput("myMap", height = "350px"),
            tags$style(type="text/css","#myMap.recalculating { opacity: 1 !important;}"),
            p(),
            a(href="https://cona-rangiora.blogspot.co.nz/", tags$b("CONA Blogspot")),
            
            h6("The material provided on this website is either owned or licensed by NIWA and 
              Environment Canterbury and is subject to copyright.")
            )
  ),
  theme = shinytheme("flatly")
  )
