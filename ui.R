# User interface definition for the Shiny app

# Load libraries
source('./load_libraries.R')

# Load helper functions
# Constants and paths
source('./constants_and_paths.R')

# Load data
source('./load_data.R')

ui <-navbarPage(
  
  title = "Community Observations Network for Air - 2016",
  tabPanel(tags$b("About"), 
           h2("NIWA is adopting small towns to test networks of new low-cost air and 
              emission monitoring sensor technologies."),
           p("The aim of the CONA projects is to accelerate the reduction
             of emissions and improvement of air quality. The hypothesis is 
             that this can be achieved by producing more timely monitoring 
             data, for more locations in a form that encourages citizen 
             participation and engagement in the issues. New technologies 
             offer a chance for citizens, businesses and agencies to work 
             together to solve air quality problems. This work has a particular 
             focus on low-cost monitoring, integration of such devices into 
             adaptive monitoring networks, data sharing and ‘data interventions’."),
           h2("The Problem"),
           p("The air in most towns (airsheds) is monitored at only one location, 
             but we know that air quality usually varies within a town. Air quality 
             monitoring has historically been too expensive to measure at multiple 
             locations. This prevents regulators and researchers to adequately diagnose 
             air quality problems, understand the links between air quality and health, 
             and develop effective policy."),
           h2("New Sensor Technology"),
           p("NIWA air quality scientist Dr Ian Longley said the new sensor technology 
             trialled last year has the potential to provide lots of new and valuable 
             information."), 
           p("This year we are planning to do some follow up testing with our existing 
             participants as well as recruit more people in Rangiora to help us out. What 
             we learn this year will then enable us to progress to a much larger study, 
             perhaps in other towns, in 2017, he said."),
           p("NIWA has developed the indoor state-of-the-art monitoring technology contained 
             in small and low cost units. These units contain sensors for particles (dust, smoke 
             or soot) and carbon dioxide and can detect sudden increases in the levels of 
             particles in the air."),
           p("The indoor data was combined with data from temporary weather stations set up 
             around Rangiora, and from 6 of NIWA’s experimental outdoor air quality sensors 
             placed around the town to determine whether different parts of the town had different 
             air quality and how that varies from day to day and place to place. Dr Longley says 
             the units could make a huge difference to our understanding of what causes air quality problems.
             “We suspect this could be a game changer in being able to identify problems and their causes and 
             enable communities to work more constructively with councils on devising solutions.”"),
           a(href="https://cona-rangiora.blogspot.co.nz/", tags$b(h3("CONA Blogspot"))),
           hr(),
           tags$img(align="right",
                    src="http://gfs.sourceforge.net/wiki/images/e/ef/Niwa-logo.jpg",
                    height="50px")
           ),
  tabPanel(tags$b("Data Visualization"),
           sidebarLayout(
             
             sidebarPanel(width = 6,id="sidebar", 
                          
                          dateInput("date","Start Date:", value = as.Date(minimum.slider),
                                    min = minimum.slider, max = maximum.slider),
                          uiOutput("slider"),
                        
                          fluidRow(
                            column(5,
                                   h4("Forward by:"),
                                   actionButton("3hour_f", "3 hours", class="btn btn-primary btn-sm"),
                                   actionButton("6hour_f", "6 hours", class="btn btn-primary btn-sm"),
                                   actionButton("12hour_f", "12 hours", class="btn btn-primary btn-sm"),
                                   actionButton("day_f", "1 day", class="btn btn-primary btn-sm")),
                            column(5,
                                   h4("Rewind by:"),
                                   actionButton("3hour_b","3 hours", class="btn btn-primary btn-sm"),
                                   actionButton("6hour_b","6 hours", class="btn btn-primary btn-sm"),
                                   actionButton("12hour_b","12 hours", class="btn btn-primary btn-sm"),
                                   actionButton("day_b", "1 day", class="btn btn-primary btn-sm"))
                          ),
                          HTML("<br><br>"),
                          fluidRow(
                            column(5,
                                   radioButtons("speed", tags$b(h4("Animation Speed:")),
                                                list("Slow", "Medium", "Fast"), 
                                                selected = "Medium", inline = T, width = '300px')),
                            column(5,
                                   sliderInput("step_size",tags$b(h4("Time Steps (in minutes:)")),
                                               min = 10, max = 60, value = 1, step = 10, width = '300px'))
                          ),
                          hr(),
                          HTML("<br><br><br>"),
                          plotOutput("myPlot", height = "300px"),
                          tags$style(type="text/css", "#myPlot.recalculating { opacity: 1 !important;}")
             ),
            
             
             mainPanel(width = 6,
                       plotlyOutput("plotly", height = "300px"),
                       tags$style(type="text/css", "#plotly.recalculating { opacity: 1.0; }"),
                       hr(),
                       
                       h4(textOutput("selectedtime")),
                       tags$style(type="text/css", "#selectedtime.recalculating { opacity: 1.0; }"),
                       
                       leafletOutput("myMap", height = "350px"),
                       tags$style(type="text/css","#myMap.recalculating { opacity: 1 !important;}"),
                       p(),
                       a(href="https://cona-rangiora.blogspot.co.nz/", tags$b("CONA Blogspot")),
                       
                       h6("The material provided on this website is either owned or licensed by NIWA and 
                          Environment Canterbury and is subject to copyright.")
                       )
             ),
           hr(),
           tags$img(align="right",
                    src="http://gfs.sourceforge.net/wiki/images/e/ef/Niwa-logo.jpg",
                    height="50px")
           ),
  tabPanel(
    tags$b("Animated Videos"),
    tags$video(src = "19212016August.mp4", type = "video/mp4", 
               width = "1080px", height = "480px", controls = NA,
               autoplay = NA),
    tags$img(align="right",
             src="http://gfs.sourceforge.net/wiki/images/e/ef/Niwa-logo.jpg",
             height="50px"),
    
    hr()
  ),
  theme = shinytheme("united")
)