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
#   environment_nr.csv # Environment types for NR ranges

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
      
      # Results cards that appear above the tabs
      nr_result_card(),
      br(),
      environment_card(),
      br(),
      
      # Tabset panel for organizing content
      tabsetPanel(
        id = "main_tabs",
        tabPanel(
          title = "Results Table",
          icon = icon("table"),
          br(),
          noise_values_card()
        ),
        tabPanel(
          title = "Chart",
          icon = icon("chart-line"),
          br(),
          nr_plot_card()
        ),
        tabPanel(
          title = "Environment Guide",
          icon = icon("building"),
          br(),
          environment_info_card()
        ),
        tabPanel(
          title = "About",
          icon = icon("info-circle"),
          br(),
          about_card()
        )
      )
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
  environment <- get_environment(calculate_nr, app_data)
  
  # Outputs
  # NR result output
  output$nr_result <- renderText({
    req(input$calculate)
    paste("Noise Rating: ", calculate_nr())
  })
  
  # Environment output
  output$environment_type <- renderText({
    req(input$calculate)
    environment()
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
  
  # Environment info table
  output$environment_info_table <- renderDT({
    datatable(
      app_data$environment_nr,
      options = list(
        dom = 't',
        paging = FALSE,
        searching = FALSE,
        ordering = TRUE,
        info = FALSE,
        columnDefs = list(
          list(className = 'dt-center', targets = "_all")
        )
      ),
      rownames = FALSE,
      colnames = c("NR Range" = "nr_range", "Suitable Environment" = "environment"),
      caption = htmltools::tags$caption(
        style = 'caption-side: top; text-align: center; font-size: 16px; font-weight: bold; color: #323172;',
        'Noise Rating Ranges and Associated Environments'
      )
    )
  })
  
  # When calculate button is pressed, switch to results tab
  observeEvent(input$calculate, {
    updateTabsetPanel(session, "main_tabs", selected = "Results Table")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)