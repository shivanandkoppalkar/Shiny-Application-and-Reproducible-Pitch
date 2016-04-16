#      Coursera Developing Data Products course project
#
#      This is the Server-side script for the shiny application built as part of the
#      project. This script filters the list of cities based on the user input and
#      also builds the output map and tables.
#      
#      Date            Developer           Comments
#      2016 Apr 16     Shamik Mitra        Initial Version

library(shiny)
library(leaflet)


# Read the data for the list of cities and countries. This is executed once at the beginning of the server
DataCities <- read.csv("/cities.csv",stringsAsFactors=FALSE)
DataCountries <- read.csv("/countries.csv",stringsAsFactors=FALSE)
DataCountries <- DataCountries[order(DataCountries$Country),]



# This function takes the user input and creates a subset of cities to be displayed
# with the calculated Quality of Life index.
FilterData <- function(input) {
    
    # Create a subset of the data based on whether the user has selected a region and country
    if(input$ShowRegion != "World") {
        if(input$ShowCountry != "All countries") {
            ChartCities <- DataCities[DataCities$Country == input$ShowCountry,]
        } else {
            ChartCities <- DataCities[DataCities$Region == input$ShowRegion,]
        }
    } else {
        ChartCities <- DataCities
    }
    
    # Calculate the Quality of Life index based on the user input weights
    ChartCities$QualityOfLife <- round(100 + (input$PurchasingPowerWeight * ChartCities$PurchasingPower / 100) 
                                           + (input$SafetyWeight * ChartCities$Safety / 100) 
                                           + (input$HealthCareWeight * ChartCities$HealthCare / 100) 
                                           - (input$CostOfLivingWeight * ChartCities$CostOfLiving / 100) 
                                           - (input$PropertyToIncomeWeight * ChartCities$PropertyToIncome / 100) 
                                           - (input$TrafficCommuteWeight * ChartCities$TrafficCommute / 100) 
                                           - (input$PollutionWeight * ChartCities$Pollution / 100) 
                                           + (input$ClimateWeight * ChartCities$Climate / 100),1)
    
    # Create the description field, which will be used as popup description for the cities
    ChartCities$Description <- paste(paste(ChartCities$City, ChartCities$Country, sep = ", "),paste("Population:", round(ChartCities$Population/1000000,1), "million", sep = " "),paste("Quality of Life", ChartCities$QualityOfLife, sep = ": "), sep = "  |  ")
    
    # Sort the cities with the highest Quality of Life index first
    ChartCities <- ChartCities[order(-ChartCities$QualityOfLife),]
    
    # Return the filtered list of cities
    ChartCities
}

# This function takes in the list of filtered cities created by the function above and returns a map
FormOutputMap <- function(ChartCities) {

    # Create a gradient color pallette based on the value of Quality of Life index
    pal <- colorNumeric(
        palette = c("firebrick1", "orange", "yellow", "yellowgreen", "limegreen"),
        domain = ChartCities$QualityOfLife
    )

                # Create a leaflet map with the list of cities    
    OutputMap <- leaflet(ChartCities) %>%
        
                # Add the tiles from Thunderforest
                 addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/transport/{z}/{x}/{y}.png", 
                          attribution = '&copy; <a href="http://www.thunderforest.com/">Thunderforest</a>, &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>%
        
                # Add the Circle markers for the cities
                 addCircleMarkers(lng=~Longitude,
                                   lat=~Latitude,
                                   radius=7,
                                   color = ~pal(QualityOfLife),
                                   fillOpacity = 0.8,
                                   weight=1,
                                   popup=~Description,
                                   stroke=TRUE) %>%
                # Add a legend
                 addLegend("bottomright", pal = pal, values = ~QualityOfLife,
                           title = "Quality of Life", opacity = 0.8)

    # Return the map
    OutputMap
}



# This function takes in the filtered list of cities returned by the function above and returns a
# table with the best and worst 3 cities. If total  number of cities filtered by the user is less
# than 6 then it will return only one list of cities.
FormOutputCities <- function(ChartCities) {
    
    # Create a copy of the list of cities with fewer columns
    ChartCities <- ChartCities[,c("City","Country","Population","QualityOfLife")]
    
    # If there are multiple countries in the list of cities, then append that to the city
    if(length(unique(ChartCities$Country))>1) {
        ChartCities$City <- paste(ChartCities$City, ChartCities$Country, sep=", ")
    }
    
    # Drop the country column
    ChartCities <- ChartCities[,-2]
    
    # Conver the population column into millions
    ChartCities$Population <- paste(round(ChartCities$Population/1000000,1),"million",sep=" ")
    
    if(nrow(ChartCities)<6) {
        
        # If there are less than 6 cities, then the output is just the filtered list of cities
        OutputTable <- ChartCities[order(-ChartCities$QualityOfLife),]
        
    } else {
        
        # If there are more than 6 cities, then sort by the index descending and take the top 3 cities
        ChartCities <- ChartCities[order(-ChartCities$QualityOfLife),]
        Top3 <- ChartCities[1:3,]
        
        # Then sort by the index ascending and take the bottom 3 cities
        ChartCities <- ChartCities[order(ChartCities$QualityOfLife),]
        Bottom3 <- ChartCities[1:3,]
        
        # The output is the list of top and bottom 3 cities joined together
        OutputTable <- cbind(Top3, Bottom3)
        
        # Update the list of names - the City column is renamed to Best and Worst cities
        names(OutputTable) <- c("Best Cities", "Population", "QualityOfLife", "Worst Cities", "Population", "QualityOfLife")
    }
    
    # Return the output table
    OutputTable
}



# This function returns a subset of countries for the input region. This function is
# called by the script below that is executed when the user selects a region
CountrySubset <- function(InputRegion){
    c("All countries",DataCountries[DataCountries$Region==InputRegion,]$Country)
}



# This is the main server function that calls the functions above to form the output
shinyServer(
    function(input, output, session) {
        
        # This function observes if the user has changed the region field, and if yes, returns a subset of countries
        observe({
            if(input$ShowRegion != "World") {
                updateSelectInput(session, "ShowCountry", choices = CountrySubset(input$ShowRegion), selected = "All countries")
            }
        })
        
        # Call the functions to form the map and table outputs based on the user input
        output$QoLMap <- renderLeaflet(FormOutputMap(FilterData(input)))
        output$QoLTable <- renderTable(FormOutputCities(FilterData(input)))
    }
)
