library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(rvest)
library(stringr)

# Scrape data from Wikipedia
url <- "https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States"
webpage <- read_html(url)

# Extract the correct table as there are 4 Tables (Table 1)
table <- webpage %>%
  html_nodes("table") %>%
  .[[1]] %>%
  html_table(fill = TRUE)


# Clean and Prepare the Data from the Website
parks_data <- table %>%
  select(
    Name = 'Name',
    Location = 'Location',
    `Date established` = 'Date established as park[12]', 
    `Area` = 'Area (2023)[8]', 
    `Recreation visitors` = 'Recreation visitors (2022)[11]'
  ) %>%
  mutate(
    `Area` = as.numeric(gsub(",", "", gsub(" acres.*", "", `Area`))),
    `Recreation visitors` = as.numeric(gsub(",", "", `Recreation visitors`))
  )

# A Correction has to be made for the State Maine as it wouldnt show properly in the Dropdown as it had wierd text around it
parks_data <- parks_data %>%
  mutate(State = ifelse(grepl("Maine", Location), "Maine", str_extract(Location, "^[^0-9]+"))) %>%
  mutate(State = str_trim(gsub(".*\\.", "", State))) # Remove text before the last dot


# Coordinates data I had to get myself as I couldnt extract it correctly from the table
coordinates <- data.frame(
  Name = c("Acadia", "American Samoa", "Arches", "Badlands", "Big Bend", "Biscayne", 
           "Black Canyon of the Gunnison", "Bryce Canyon", "Canyonlands", "Capitol Reef", 
           "Carlsbad Caverns", "Channel Islands", "Congaree", "Crater Lake", "Cuyahoga Valley", 
           "Death Valley", "Denali", "Dry Tortugas", "Everglades", "Gates of the Arctic", 
           "Gateway Arch", "Glacier", "Glacier Bay", "Grand Canyon", "Grand Teton", 
           "Great Basin", "Great Sand Dunes", "Great Smoky Mountains", "Guadalupe Mountains", 
           "Haleakalā", "Hawaiʻi Volcanoes", "Hot Springs", "Indiana Dunes", "Isle Royale", 
           "Joshua Tree", "Katmai", "Kenai Fjords", "Kings Canyon", "Kobuk Valley", "Lake Clark", 
           "Lassen Volcanic", "Mammoth Cave", "Mesa Verde", "Mount Rainier", "New River Gorge", 
           "North Cascades", "Olympic", "Petrified Forest", "Pinnacles", "Redwood", 
           "Rocky Mountain", "Saguaro", "Sequoia", "Shenandoah", "Theodore Roosevelt", 
           "Virgin Islands", "Voyageurs", "White Sands", "Wind Cave", "Wrangell–St. Elias", 
           "Yellowstone", "Yosemite", "Zion"),
  Latitude = c(44.35, -14.25, 38.68, 43.75, 29.25, 25.65, 38.57, 37.57, 38.20, 38.20, 
               32.17, 34.01, 33.78, 42.94, 41.24, 36.24, 63.33, 24.63, 25.32, 67.78, 
               38.63, 48.80, 58.50, 36.06, 43.73, 38.98, 37.73, 35.68, 31.92, 20.72, 
               19.38, 34.51, 41.6533, 48.10, 33.79, 58.50, 59.92, 36.80, 67.55, 60.97, 
               40.49, 37.18, 37.18, 46.85, 38.07, 48.70, 47.97, 35.07, 36.48, 41.30, 
               40.40, 32.25, 36.43, 38.53, 46.97, 18.33, 48.50, 32.78, 43.57, 61.00, 
               44.60, 37.83, 37.30),
  Longitude = c(-68.21, -170.68, -109.57, -102.50, -103.25, -80.08, -107.72, -112.18, 
                -109.93, -111.17, -104.44, -119.42, -80.78, -122.10, -81.55, -116.82, 
                -150.50, -82.87, -80.93, -153.30, -90.19, -114.00, -137.00, -112.14, 
                -110.80, -114.30, -105.51, -83.53, -104.87, -156.17, -155.20, -93.05, 
                -87.0524, -88.55, -115.90, -155.00, -149.65, -118.55, -159.28, -153.42, 
                -121.51, -86.10, -108.49, -121.75, -81.08, -121.20, -123.50, -109.78, 
                -121.16, -124.00, -105.58, -110.50, -118.68, -78.35, -103.45, -64.73, 
                -92.88, -106.17, -103.48, -142.00, -110.50, -119.50, -113.05)
)

# Merge the data from the Table and the Data given by Me
parks_data <- merge(parks_data, coordinates, by = "Name")


# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "US National Parks"),
  dashboardSidebar(
    sliderInput("size", "Park Size (in acres)", 
                min = min(parks_data$Area, na.rm = TRUE), 
                max = max(parks_data$Area, na.rm = TRUE), 
                value = range(parks_data$Area, na.rm = TRUE)),
    selectInput("state", "Select State", 
                choices = c("All", sort(unique(parks_data$State))), 
                selected = "All")
  ),
  dashboardBody(
    leafletOutput("parkMap")
  )
)

# Define server logic
server <- function(input, output, session) {
  filteredData <- reactive({
    data <- parks_data
    if (input$state != "All") {
      data <- data %>% filter(State == input$state)
    }
    data <- data %>% filter(Area >= input$size[1] & Area <= input$size[2])
    data
  })
  
  output$parkMap <- renderLeaflet({
    leaflet(filteredData()) %>%
      addTiles() %>%
      addCircleMarkers(
        lat = ~Latitude, lng = ~Longitude, 
        popup = ~paste("<strong>", Name, "</strong><br>",
                       "Established: ", `Date established`, "<br>",
                       "Area: ", Area, " acres<br>",
                       "Visitors: ", `Recreation visitors`)
      )
  })
}

# Run the app
shinyApp(ui, server)
