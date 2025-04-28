# R/utils.R - Utility functions

library(readr)
library(shinyjs)

# Load app data
load_app_data <- function() {
  list(
    nr_chart = read_csv("data/nr_table.csv", show_col_types = FALSE),
    df_nr_full = readRDS("data/df_nr_full.rds"),
    df_nr = read_csv("data/df_nr.csv", show_col_types = FALSE)
  )
}

# Example values for reference
get_example_values <- function() {
  c(44, 42, 56, 31, 24, 20, 28, 41)
}

# Frequency definitions
get_frequency_labels <- function() {
  c("31.5Hz", "63Hz", "125Hz", "250Hz", "500Hz", "1000Hz", "2000Hz", "4000Hz", "8000Hz")
}

# Frequency for user inputs (excluding 31.5Hz)
get_input_frequencies <- function() {
  c("63Hz", "125Hz", "250Hz", "500Hz", "1000Hz", "2000Hz", "4000Hz", "8000Hz")
}