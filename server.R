#  David Bradford
#  Data Products - Week 4 Assignment (server.R)

library(shiny)
library(leaflet)
library(dplyr)
library(rgdal)

crime_dat <- read.csv("crime_data_2014.csv", stringsAsFactors = FALSE)
crime_dat$GEOID <- formatC(crime_dat$GEOID, width = 5, format = "d", flag = "0")


# Download county shape file from Tiger.
# https://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html
us.map <- readOGR(dsn = ".", layer = "cb_2013_us_county_20m", stringsAsFactors = FALSE)

#  Keep Alaska(2), Hawaii(15), 
#  Remove Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60)
#  Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map <- us.map[!us.map$STATEFP %in% c("72", "66", "78", "60", "69", "64", "68", "70", "74"),]

# Make sure other outling islands are removed.
us.map <- us.map[!us.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76", "95", "79"),]

unique_attacks <- as.data.frame(unique(crime_dat$crime))
names(unique_attacks) <- "Attacks"
unique_attacks$Attacks <- as.character(unique_attacks$Attacks)
unique_attacks$Attacks <- sort(unique_attacks$Attacks)


shinyServer(function(input, output) {

    output$attackControls <- renderUI({
        radioButtons('unique_attacks', 'Attacks:', unique_attacks$Attacks, selected = "All Crime")
    })
    
    filtered_c <- eventReactive(input$go,{
        
        crime_temp <- filter(crime_dat, year >= input$range_a[1] & year <= input$range_a[2] & crime == input$unique_attacks)
        crime_temp
        
    })
        
        output$leaflet_map <- renderLeaflet({
            
            crime_data = filtered_c()
            crime_data <- merge(us.map, crime_data, by=c("GEOID"))
            
            bins <- c(0, 10, 50, 100, 250, 500, 750, 1000, Inf)
            pal <- colorBin("YlOrRd", domain = crime_data$value, bins = bins)
            
            labels <- sprintf(
                "<strong>%s</strong><br/>%s<br/>%g arrests per capita", 
                crime_data$crime, crime_data$NAME, crime_data$value
            ) %>%
                lapply(htmltools::HTML)
            
            leaflet(data = crime_data) %>% addTiles() %>%
                addPolygons(data = crime_data,
                            layerId = ~GEOID,
                            fillColor = ~pal(value), 
                            fillOpacity = 0.7,
                            color = "#BDBDC3",
                            weight = 1,
                            label = labels,
                            labelOptions = labelOptions(
                                style = list("font-weight" = "normal", padding = "3px 8px"),
                                textsize = "15px",
                                direction = "auto")) %>%
                addLegend(pal = pal, values = ~value, opacity = 0.7,
                          title = "Legend:",
                          position = "bottomright")
               
        })

})  
        