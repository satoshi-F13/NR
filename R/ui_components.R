# R/ui_components.R - UI components

# Create frequency input grid
frequency_input_grid <- function() {
  # Get example values
  example_values <- get_example_values()
  
  # Get frequencies
  frequencies <- get_input_frequencies()
  
  # Create a grid container
  div(
    style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;",
    
    # Create input fields for each frequency dynamically
    lapply(seq_along(frequencies), function(i) {
      freq <- frequencies[i]
      value <- example_values[i]
      
      div(
        numericInput(
          inputId = paste0("lwo_", freq),
          label = paste0(freq, " (dB):"),
          value = value,
          min = -20,
          max = 140
        )
      )
    })
  )
}

# Create NR result card
nr_result_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("Overall Noise Rating Results")),
        card_body(
          h2(textOutput("nr_result"), align = "center"),
          style = "padding: 20px; text-align: center;"
        ),
        full_screen = TRUE
      )
    )
  )
}

# Create noise values table card
noise_values_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("Noise Level Values")),
        card_body(
          div(style = "overflow-x: auto;", DTOutput("noise_values"), align = "center")
        ),
        full_screen = TRUE
      )
    )
  )
}

# Create NR plot card
nr_plot_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("Noise Rating Chart")),
        card_body(
          plotOutput("nr_plot", height = "500px")
        ),
        full_screen = TRUE
      )
    )
  )
}