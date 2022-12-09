#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(datateachr)
library(lubridate)
library(tidyverse)
library(leaflet)
library(scales)
library(dplyr)
library(shinythemes)
library(emojifont)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)

## Clean data
# Decrease the granularity of the date_planted timestamp to year, otherwise there will be too many data points crowded together explore the relationship.
vancouver_trees_clean <- vancouver_trees  %>%
  mutate(year = year(date_planted))

# Select relevant column from vancouver_trees table, and also filter those genus whose occurence are less than 1000
vancouver_trees_clean <- vancouver_trees_clean %>%
  select(tree_id, genus_name, neighbourhood_name, height_range_id, diameter, longitude, latitude, year) %>%
  group_by(genus_name) %>%
  filter(n()>2000)

# Focus on data after 2010
vancouver_trees_20s <- vancouver_trees_clean %>%
  filter(year >= 2010)

# Choices for map color-by/size-by drop-downs
color_vars <- c(
  "Diameter" = "diameter",
  "Height" = "height_range_id",
  "Year" = "year",
  "Genus Name" = "genus_name"
)
size_vars <- c(
  "Diameter" = "diameter",
  "Height" = "height_range_id"
)

ui <- navbarPage(paste0("Explore Vancouver Trees", emoji("deciduous_tree")), id="nav", theme = shinytheme("sandstone"),
            ## Feature 1: Create seperate tabs for map and data explorer, in order for better display
             tabPanel("Map",
                      div(class="outer",
                          tags$head(
                            ## Feature 2: Include custom css for better map display
                            includeCSS("styles.css"),
                          ),
                          ## Feature 3: Add a map using leaflet packages, which enables the user find the relationship between geo-location and other variable at first glance.
                          leafletOutput("map", width="100%", height="100%"),

                          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                        width = 330, height = "auto",

                                        h2("Trees Explorer"),
                                        h4("Change the marker's color/size by:"),
                                        ## Feature 4: Add parameters to the map, so that user can control which variable controls the circle's color and size in the map.
                                        selectInput("color", "Color", color_vars, selected = "genus_name"),
                                        selectInput("size", "Size", size_vars, selected = "diameter")
                          )
                      )
             ),

             tabPanel("Data Explorer",
                      fluidRow(
                        ## Feature 5: Add a select box, which allows the user to search for multiple categorical entries simultaneously. So, user could search multiple categorical data at the same time.
                        column(3,
                               selectInput("neighbourhood", "Neighbourhood Name", c("All neighbourhood"="", unique(vancouver_trees_clean$neighbourhood_name)), multiple=TRUE)
                        ),
                        column(3,
                               selectInput("genus", "Genus", c("All genus"="", unique(vancouver_trees_clean$genus_name)), multiple=TRUE)
                        )
                      ),
                      fluidRow(
                        ## Feature 6: Add a slider bar, which allows the user to select the range of the numerical data. This may enable the user explore the data relationship at first glance.
                        column(1,
                               sliderInput("year", "Year Range", min = 1990,
                                           max = 2020, value = c(1990, 2020), step = 1)
                        ),
                        column(1,
                               sliderInput("diameter", "Diameter Range", min = 0,
                                           max = 400, value = c(0, 400), step = 40)
                        ),
                        column(1,
                               sliderInput("height", "Height ID Range", min = 0,
                                           max = 10, value = c(0, 10), step = 1)
                        )
                      ),
                      hr(),
                      ## Feature 7: Use the DT package to turn a static table into an interactive table. In this way, user could sort, search, filter the table in a more convenient way.
                      DT::dataTableOutput("table")
             )
)


server <- function(input, output) {
  ## Feature 3: Add a map using leaflet packages, which enables the user find the relationship between geo-location and other variable at first glance.
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -123.1207, lat = 49.2580, zoom = 13)
  })

  ## Feature 4: Add parameters to the map, so that user can control which variable controls the circle's color and size in the map.
  # This observer is responsible for maintaining the circles and legend according to the variables the user has chosen to map to color and size.
  observe({
    colorBy <- input$color
    sizeBy <- input$size

    colorData <- vancouver_trees_20s[[colorBy]]
    if (colorBy %in% c("year", "genus_name")) {
      pal <- colorFactor(viridis_pal(option = "plasma")(length(unique(colorData))), colorData)
    } else {
      pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
    }

    if (sizeBy == "height_range_id") {
      radius <- vancouver_trees_20s[[sizeBy]] / max(vancouver_trees_20s[[sizeBy]]) * 500
    } else {
      radius <- vancouver_trees_20s[[sizeBy]] / max(vancouver_trees_20s[[sizeBy]]) * 1000
    }


    leafletProxy("map", data = vancouver_trees_20s) %>%
      clearShapes() %>%
      addCircles(~longitude, ~latitude, radius=radius, layerId=~tree_id,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
  })

  ## Feature 7: Use the DT package to turn a static table into an interactive table. In this way, user could sort, search, filter the table in a more convenient way.
  output$table <- DT::renderDataTable({
    df <- vancouver_trees_clean %>%
      filter(
        ## Feature 6: Add a slider bar, which allows the user to select the range of the numerical data. This may enable the user explore the data relationship at first glance.
        year >= input$year[1],
        year <= input$year[2],
        diameter >= input$diameter[1],
        diameter <= input$diameter[2],
        height_range_id >= input$height[1],
        height_range_id <= input$height[2],
        ## Feature 5: Add a select box, which allows the user to search for multiple categorical entries simultaneously. So, user could search multiple categorical data at the same time.
        is.null(input$neighbourhood) | neighbourhood_name %in% input$neighbourhood,
        is.null(input$genus) | genus_name %in% input$genus)
    DT::datatable(df, escape = FALSE)
  })

}

# Run the application
shinyApp(ui = ui, server = server)
