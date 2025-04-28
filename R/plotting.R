# R/plotting.R - Plot creation functions

library(ggrepel)

# Create NR plot
create_nr_plot <- function(df_nr, input_values) {
  # Define frequency labels
  frequency_labels <- get_frequency_labels()
  
  # Create labels for the rightmost points
  df_nr_labels <- df_nr %>%
    mutate(noise_rating_labels = paste0(noise_rating)) %>%
    filter(frequency == last(frequency))
  
  # Create the base plot
  nr_plot <- ggplot(df_nr, aes(x = frequency, y = value, group = noise_rating)) +
    geom_line(linewidth = 1, color = "gray60") +
    geom_point(size = 1.2, color = "gray60") +
    geom_text_repel(
      data = df_nr_labels,
      aes(label = noise_rating_labels),
      family = "PT Sans",
      fontface = "bold",
      color = "gray60",
      size = 3,
      direction = "x",
      hjust = 0,
      segment.size = 0.7,
      segment.alpha = 0.5,
      segment.linetype = "dotted",
      box.padding = -1.7,
    ) +
    coord_cartesian(
      clip = "off",
      ylim = c(-15, 140)
    ) +
    theme_minimal(base_size = 12) +
    labs(
      title = "Noise Ratings at Input Noise Values ",
      x = "",
      y = "",
    ) +
    theme(
      plot.title = element_text(size = 15, face = "bold", margin = margin(b = 10, l = 30)),
      legend.position = "none",
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      axis.title = element_text(face = "bold", size = 10),
      axis.text.x = element_text(angle = 18, hjust = 0.5, size = 11),
      axis.text.y = element_text(size = 12),
      panel.background = element_rect(fill = "#E3EBF3", linewidth = 0),
      plot.background = element_rect(fill = "#E3EBF3", linewidth = 0),
      plot.margin = margin(r = 20, t = 20, b = 20, l = 20, unit = "pt")
    ) +
    scale_x_discrete(labels = frequency_labels) +
    scale_y_continuous(
      breaks = seq(-10, 140, by = 20),
      labels = function(x) paste0(x, " dB")
    )
  
  # Create df_lwo from user inputs
  df_lwo <- data.frame(
    frequency = input_values$Frequency,
    value = as.numeric(input_values$Lwo)
  ) %>%
    mutate(frequency = factor(
      frequency, 
      levels = get_input_frequencies(), 
      ordered = TRUE
    ))
  
  # Add Lwo values to the chart
  nr_plot <- nr_plot +
    geom_line(
      data = df_lwo, 
      aes(x = frequency, y = value, group = 1), 
      color = "#323172", 
      linewidth = 1.5
    ) +
    geom_point(
      data = df_lwo, 
      aes(x = frequency, y = value, group = 1), 
      shape = 21, 
      color = "#323172", 
      fill = "white", 
      size = 1.5, 
      stroke = 1.5
    )
  
  return(nr_plot)
}