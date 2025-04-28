# Project Structure:
#
# app.R             # Main application file
# R/                # Folder
#   utils.R         # Utility functions
#   data_prep.R     # Data preparation functions  
#   ui_components.R # UI components
#   plotting.R      # Plot creation functions
#data/
#   df_nr_full.rds  # Full values of each NR
#   df_nr.csv
#   nr_table.csv

# Contents of app.R:
# -----------------

#Try adding this line at the top of your app.R to set a user agent:
#apply fonts from googlefont 
options(HTTPUserAgent = "Mozilla/5.0")

# Load necessary libraries (only the ones actually used)
library(shiny)
library(bslib)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)

# Source helper files
source("R/utils.R")
source("R/data_prep.R")
source("R/ui_components.R")
source("R/plotting.R")

# Define UI for application
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(brand = "_brand.yml"),
  
    # Custom header with logo. For calling logo, "logos" folder must be under "www" folder.
    fluidRow(
      style = "display: flex; align-items: center; margin-bottom: 15px; padding: 10px 15px;",
      column(
        width = 8,
        h1("Noise Rating Calculator", style = "margin: 0;")
      ),
      column(
        width = 4,
        div(style = "text-align: right;",
            img(src = "logos/wide/satom-wide-color.png", height = "60px")
        )
      )
    ),
  
  # Sidebar with input controls
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Enter Noise Values"),
      
      # Frequency input grid from ui_components.R
      frequency_input_grid(),
      
      br(),
      actionButton("calculate", "Calculate NR", class = "btn-primary btn-lg btn-block", width = "100%")
    ),
    
    mainPanel(
      width = 9,
      
      # Cards from ui_components.R
      nr_result_card(),
      br(),
      noise_values_card(),
      br(),
      nr_plot_card()
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Load app data (from utils.R)
  app_data <- load_app_data()
  
  # Reactive functions (from data_prep.R)
  input_values <- get_input_values(input)
  df_nr <- get_df_nr(app_data)
  calculate_nr <- get_nr_calculation(input, app_data, input_values)
  results <- get_results(input, input_values, calculate_nr)
  
  # Outputs
  # NR result output
  output$nr_result <- renderText({
    req(input$calculate)
    paste("Noise Rating: ", calculate_nr())
  })
  
  # Table output
  output$noise_values <- renderDT({
    req(input$calculate)
    create_results_table(results())
  })
  
  # Plot output
  output$nr_plot <- renderPlot({
    req(input$calculate)
    create_nr_plot(df_nr(), input_values())
  })
}

# Run the application 
shinyApp(ui = ui, server = server)