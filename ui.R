#      Coursera Developing Data Products course project
#
#      This is the UI script for the shiny application built as part of the course 
#      project. The UI uses a fluidPage layout with a fixed panel on the left that 
#      has the sliders for changing the weights for calculating the Quality of Life 
#      index. It has a map display in the middle section which is rendered using 
#      leaflet. The right had side has a floating panel which has the controls to 
#      filter the list of cities. On the bottom of the screen, there is a table with
#      the list of best and worst cities.
#      
#      Date            Developer                    Comments
#      2016 Apr 16     Shivanand R Koppalkar        Initial Version

library(shiny)
library(leaflet)

# Load the list of regions, which will be used to populate the drop down list for regions
DataRegions <- read.csv("/regions.csv",stringsAsFactors=FALSE)

# Set the default region
ShowRegion <- "World"

shinyUI(fluidPage(
    title="Quality of Living",
    
    # Set the style
    tags$head(
        tags$style(HTML("
                        body {
                            background-color: #ADDEFF;
                        }

                        h2 {
                            font-family: 'Verdana';
                            font-weight: bold;
                            font-size: large;
                            color: black;
                        }

                        h4 {
                            font-family: 'Trebuchet MS';
                            font-weight: normal;
                            font-size: xsmall;
                            color: black;
                        }
                        
                        table {
                            font-family: 'Arial';
                            font-weight: bold;
                            font-size: small;
                            color: black;
                        }

                        td {
                            padding: 0px 0px 0px 10px;
                        }

                        #HeaderPanel {
                            background-color: transparent;
                            border-style: hidden;
                            font-family: 'Trebuchet MS';
                        }
                        
                        #OutputPanel {
                            background-color: #ADDEFF;
                            border-style: hidden;
                            padding: 5px;
                            font-family: 'Verdana';
                            font-weight: normal;
                            font-size: small;
                            color: black;
                            opacity: 0.4;
                        }

                        #OutputPanel:hover {
                            opacity: 1;
                            box-shadow: 2px 2px 5px #888888;
                        }
                        
                        #HelpPanel {
                            background-color: white;
                            border-style: hidden;
                            padding: 5px;
                            font-family: 'Verdana';
                            font-weight: normal;
                            font-size: small;
                            color: black;
                            opacity: 0.4;
                        }
                        
                        #HelpPanel:hover {
                            opacity: 1;
                            box-shadow: 2px 2px 5px #888888;
                        }
                                                
                        #TopCitiesPanel {
                            background-color: white;
                            border-style: hidden;
                            padding: 5px;
                            font-family: 'Verdana';
                            font-weight: normal;
                            font-size: small;
                            color: black;
                            opacity: 0.4;
                        }
                        
                        #TopCitiesPanel:hover {
                            opacity: 1;
                            box-shadow: 2px 2px 5px #888888;
                        }
                        
                        #QoLTable {
                            font-family: 'Arial';
                            font-weight: normal;
                            font-size: small;
                            color: black;
                            border: '0';
                        }

                        "))
        ),
    
    fluidRow(
        
        # The first column has the panel for the slider inputs for the weights
        column(width = 2,
               h2("Select weights"),
               tags$table(
                   tags$tr(
                       tags$td("Purchasing Power", 
                               align="right", 
                               valign="top", 
                               width="30%"),
                       tags$td(sliderInput(inputId="PurchasingPowerWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 40, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Cost of Living",
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="CostOfLivingWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 20, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Property to Income", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="PropertyToIncomeWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 100, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Safety", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="SafetyWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 50, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Health Care", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="HealthCareWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 40, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Traffic Commute", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="TrafficCommuteWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 50, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Pollution", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="PollutionWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 67, 
                                           width = "100%"))
                   ),
                   tags$tr(
                       tags$td("Climate", 
                               align="right", 
                               valign="top"),
                       tags$td(sliderInput(inputId="ClimateWeight", 
                                           label=NULL,
                                           min = 0, 
                                           max = 100, 
                                           value = 50, 
                                           width = "100%"))
                   )
               )
        ),
        
        # The second column acts as the main section containing the leaflet output
        column(width = 10,
               leafletOutput('QoLMap', 
                             height=600)
        ),
        
        # A fixed panel is created on top of the map containing the title of the website
        absolutePanel(id = "HeaderPanel", 
                      class = "panel panel-default", 
                      fixed = TRUE,
                      draggable = FALSE, 
                      top = "0%", 
                      left = "22%", 
                      right = "auto", 
                      bottom = "auto",
                      width = 800, 
                      height = 60,
                      
                      h1("Quality of Life in major cities"),
                      h4("By Shamik Mitra")
                      
        ),
        
        # A fixed panel is created on top-right with the help link
        absolutePanel(id = "HelpPanel", 
                      class = "panel panel-default", 
                      fixed = TRUE,
                      draggable = FALSE, 
                      top = "0%", 
                      left = "auto", 
                      right = "1%", 
                      bottom = "auto",
                      width = 150, 
                      height = "auto",
                      
                      a("Help documentation", href="https://shivanandkoppalkar.shinyapps.io/Help/", target="_blank")
                      
        ),
        
        # An additional floating panel is created on top of the map that contains the drop
        # down lists for filtering the cities by region and country
        absolutePanel(id = "OutputPanel", 
                      class = "panel panel-default", 
                      fixed = TRUE,
                      draggable = TRUE, 
                      top = "10%", 
                      left = "auto", 
                      right = "1%", 
                      bottom = "auto",
                      width = 150, 
                      height = "auto",
                      
                      h2("Filter cities"),
                      
                      selectInput(inputId="ShowRegion", 
                                  label="Region", 
                                  choices = DataRegions$Region, 
                                  selected = "World"),
                      conditionalPanel(condition="input.ShowRegion != 'World'",
                                       selectInput(inputId="ShowCountry", 
                                                   label="Country", 
                                                   choices = c("All countries"), 
                                                   selected = "All countries"))
        ),

        # Lastly, a floating panel is created at the bottom of the map with the 
        # list of best and worst cities
        absolutePanel(id = "TopCitiesPanel", 
                      class = "panel panel-default", 
                      fixed = TRUE,
                      draggable = TRUE, 
                      top = "auto", 
                      left = "22%", 
                      right = "auto", 
                      bottom = "5%",
                      width = "auto", 
                      height = "auto",

                      tableOutput("QoLTable")

        )
    )
))
