# Explore Vancouver Trees

### Check this out!

[Explore Vancouver Trees - shinyapps.io](https://slinger25.shinyapps.io/explore_van_trees/)

![Running screenshot](/images/screenshot.png)

​                                                            **Map**

![screenshot_data_explorer](/images/screenshot_data_explorer.png)

​                                                    **Data Explorer**

**Explore Vancouver trees** is a interactive shiny app, which allows the user to explore *vancouver trees* dataset, and analyze the relationship between tree's genus, geo-location, size (height and diameter), year planted, etc.

There are two tabs in the app.

The first tab is **Map**, which enables the user find the relationship between geo-location and other variable at first glance. And user can control which variable controls the circle's color and size in the map.

The second tab is **Data Explorer**, where user could sort, search, filter the table in a very convenient way. To filter the table, user can not only search for multiple categorical entries simultaneously, but also select the range of the numerical data.

## About the data

*vancouver trees* dataset comes from the `datateachr` package by Hayley Boyce and Jordan Bourak currently composed of 7 semi-tidy datasets for educational purposes. And its originally acquired courtesy of **The City of Vancouver’s Open Data Portal**. It currently has 146611 rows and 20 columns.

## Features

### Option B: Create your own shiny app with three features, and deploy it.

- **Feature 1**: Create seperate tabs for map and data explorer, in order for better display
- **Feature 2**: Include custom css for better map display
- **Feature 3**: Add a map using leaflet packages, which enables the user find the relationship between geo-location and other variable at first glance.
- **Feature 4**: Add parameters to the map, so that user can control which variable controls the circle's color and size in the map.
- **Feature 5**: Add a select box, which allows the user to search for multiple categorical entries simultaneously. So, user could search multiple categorical data at the same time.
- **Feature 6**: Add a slider bar, which allows the user to select the range of the numerical data. This may enable the user explore the data relationship at first glance.
- **Feature 7**: Use the DT package to turn a static table into an interactive table. In this way, user could sort, search, filter the table in a more convenient way.
