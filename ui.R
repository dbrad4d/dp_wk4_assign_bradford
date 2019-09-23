#  David Bradford
#  Data Products - Week 4 Assignment (ui.R)

library(shiny)
library(leaflet)

shinyUI(
  navbarPage("",
             tabPanel(p(icon("fas fa-globe-americas","fa-2x"), "United States Crime Statistics by County (2014)"),
                      sidebarPanel(
                        h2(icon("fas fa-user-secret","fa-1x"), " Crime Type", align = 'left'),
                        tags$hr(),
                        h5("Displays the number of ",tags$em('arrests'), "per capita by county"),
                        tags$ul(tags$li("Use the slider to filter by date, and use the radio boxes to select crime type."),
                                tags$li(tags$i("Note:  Data available for 2014 only.")),
                                tags$li("Click ", tags$em("Calculate"), "(below) to display the map.")),
                        tags$hr(),
                        sliderInput("range_a",
                                    "Years:",
                                    min=2014,
                                    max=2014,
                                    sep="",
                                    value = c(2014,2014)),
                        uiOutput("attackControls"),
                        actionButton("go","Calculate", class = "btn-primary")
                      ),
                      mainPanel(
                        h2("Number of Arrests per Capita"),
                        tags$hr(),
                        leafletOutput("leaflet_map")
                      )
             )
  )
)