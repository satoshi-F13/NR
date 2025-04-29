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

# Create environment type card
environment_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("Suitable Environment Type")),
        card_body(
          h3(textOutput("environment_type"), align = "center"),
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
          div(DTOutput("noise_values"), align = "center"),
          style = "overflow-x: auto; width: 100%;"
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

# Create environment info card
environment_info_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("NR Ranges and Environment Types")),
        card_body(
          DTOutput("environment_info_table"),
          style = "padding: 20px;"
        ),
        full_screen = TRUE
      )
    )
  )
}

# Create about card
about_card <- function() {
  fluidRow(
    column(
      width = 12,
      card(
        card_header(h4("About Noise Rating (NR)")),
        card_body(
          p("Noise Rating (NR) is a standard that represents the levels of noise in different frequency bands."),
          p("It's used to specify acceptable indoor environment and noise levels in buildings."),
          p("The NR rating is determined by plotting the octave band levels for a given noise spectrum 
            against a family of NR curves. The NR value is the highest curve that is reached by the noise spectrum."),
          p("Common applications include:"),
          tags$ul(
            tags$li("Building design and acoustics"),
            tags$li("HVAC system noise evaluation"),
            tags$li("Office and workspace noise assessment"),
            tags$li("Determining appropriate environments for different activities")
          ),
          style = "padding: 20px;"
        ),
        full_screen = TRUE
      )
    )
  )
}