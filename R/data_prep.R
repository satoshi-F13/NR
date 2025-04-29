# R/data_prep.R - Data preparation functions

# Reactive function to collect input values
get_input_values <- function(input) {
  reactive({
    req(input$calculate)
    
    # Get frequencies and create the data frame
    frequencies <- get_input_frequencies()
    
    # Collect Lwo values from inputs dynamically
    lwo_values <- sapply(frequencies, function(freq) {
      input_name <- paste0("lwo_", freq)
      input[[input_name]]
    })
    
    # Create results data frame
    data.frame(
      Frequency = frequencies,
      Lwo = lwo_values,
      stringsAsFactors = FALSE
    )
  })
}

# Load and prepare NR database
get_df_nr <- function(app_data) {
  reactive({
    app_data$df_nr %>%
      mutate(frequency = factor(frequency, 
                                levels = get_frequency_labels(), 
                                ordered = TRUE))
  })
}

# Calculate NR rating
get_nr_calculation <- function(input, app_data, input_values) {
  reactive({
    req(input$calculate)
    
    # Convert to long format
    df_nr_long <- app_data$df_nr_full %>% 
      gather(key = frequency, value = value, -Noise_Rating) %>% 
      rename(noise_rating = Noise_Rating, level = value) %>% 
      mutate(frequency = factor(frequency, levels = get_frequency_labels(), ordered = TRUE)) %>% 
      filter(frequency != "31.5Hz")
    
    # Get Lwo values
    df_lwo_long <- input_values() %>%
      select(Frequency, Lwo) %>%
      rename(level = Lwo, frequency = Frequency)
    
    # Calculate NR
    nr_values <- df_nr_long %>%
      inner_join(df_lwo_long, by = "frequency", suffix = c("_nr", "_lwo")) %>%
      filter(level_nr > level_lwo) %>%
      group_by(frequency) %>%
      summarize(min_exceeded_nr = min(noise_rating), .groups = "drop")
    
    if(nrow(nr_values) > 0) {
      max(nr_values$min_exceeded_nr, na.rm = TRUE)
    } else {
      "NR 0"
    }
  })
}

# Get environment type based on NR value
get_environment <- function(calculate_nr, app_data) {
  reactive({
    req(calculate_nr())
    
    # Extract numeric value from NR string (e.g., "NR 45" -> 45)
    nr_value <- as.numeric(gsub("NR ", "", calculate_nr()))
    
    # Check if NR is below 25 or above 70
    if (is.na(nr_value) || nr_value < 25 || nr_value > 70) {
      return("NA")
    }
    
    # Find matching environment from the environment_nr data
    env_match <- app_data$environment_nr %>%
      filter(
        # Extract numeric ranges from nr_range (e.g., "NR 25-30" -> c(25, 30))
        nr_value >= as.numeric(gsub("NR ([0-9]+)-.*", "\\1", nr_range)),
        nr_value <= as.numeric(gsub("NR [0-9]+-([0-9]+)", "\\1", nr_range))
      )
    
    if (nrow(env_match) > 0) {
      return(env_match$environment[1])
    } else {
      return("NA")
    }
  })
}

# Prepare results data
get_results <- function(input, input_values, calculate_nr) {
  reactive({
    req(input$calculate)
    
    # Get the base input values and NR value
    base_results <- input_values()
    nr_value <- calculate_nr()
    
    # Create the row with frequencies as columns
    base_results %>%
      pivot_wider(
        names_from = Frequency,
        values_from = Lwo
      ) %>%
      # Add NR rating as a new column
      mutate(NR_Rating = nr_value)
  })
}

# Format the results table
create_results_table <- function(results_data) {
  # Get frequency names for formatting
  freq_cols <- get_input_frequencies()
  
  # Create a more responsive table that doesn't require horizontal scrolling
  datatable(
    results_data,
    options = list(
      pageLength = 1,
      lengthChange = FALSE,
      searching = FALSE,
      paging = FALSE,
      info = FALSE,
      dom = 't',
      columnDefs = list(
        list(className = 'dt-center', targets = "_all")
      ),
      scrollX = FALSE,  # Disable horizontal scrolling
      autoWidth = TRUE
    ),
    rownames = FALSE,
    selection = "none",
    class = "cell-border stripe hover display compact", # Add compact class for narrower cells
    caption = htmltools::tags$caption(
      style = 'caption-side: top; text-align: center; font-size: 16px; font-weight: bold; color: #323172;',
      'Noise Values by Frequency (dB)'
    )
  ) %>%
    formatRound(columns = freq_cols, digits = 0)
}