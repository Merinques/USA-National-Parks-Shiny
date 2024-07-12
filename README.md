# US National Parks Dashboard

This Shiny app provides an interactive dashboard displaying information about the national parks of the United States. The data is scraped from Wikipedia and includes details such as the park's name, location, date of establishment, area, and the number of recreational visitors. Additionally, the app includes a Leaflet map to visualize the parks' locations. The Coordinates had to be given by it Manualy as I could not figure out how to extract it from location.

## Features

- **Interactive Leaflet Map**: Visualize the locations of US national parks.
- **Reactivity**: 
  - Slider to filter parks by size.
  - Dropdown to filter parks by state.
- **Data Scraping**: The app scrapes data from Wikipedia and combines it with provided coordinates for accurate location representation.

## Data Sources

- The data about the national parks is scraped from the Wikipedia page: [List of national parks of the United States](https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States).
- Coordinates for the parks were manually added to ensure accuracy.

## Setup and Running

To run this app, make sure you have the necessary packages installed:

```r
install.packages(c("shiny", "shinydashboard", "leaflet", "dplyr", "rvest", "stringr"))
