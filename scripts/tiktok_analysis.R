library(arrow)
library(tidyverse)
library(scales)


tiktok_data <- read_parquet("data/clean/clean_tiktok_data.parquet")

plot_data <- tiktok_data |>
  mutate(
    caption_lower = tolower(caption),
    
    category = case_when(
      str_detect(caption_lower, "starbucks") ~ "Starbucks",
      str_detect(caption_lower, "ceremonial") ~ "Ceremonial",
      str_detect(caption_lower, "latte") ~ "Latte",
      TRUE ~ "General Matcha"
    )
  ) |>
  select(-caption_lower)



# Intent-to-Purchase Scatterplot
ggplot(plot_data, aes(x = views, y = saves, color = category)) +
  geom_point(alpha = 0.6, size = 2.5) +
  scale_x_log10(labels = label_comma()) + 
  scale_y_log10(labels = label_comma()) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) + 
  labs(
    title = "Intent to Purchase: Saves vs. Views",
    subtitle = "Comparing engagement behavior across matcha market segments",
    x = "Total Views (Log Scale)",
    y = "Total Saves (Log Scale)",
    color = "Market Segment"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))



# Engagement Rate by Category Boxplot
ggplot(plot_data, aes(x = reorder(category, engagement_rate, FUN = median), 
                      y = engagement_rate, 
                      fill = category)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.3) +
  scale_y_continuous(labels = label_percent(), limits = c(0, 0.3)) + 
  labs(
    title = "Which Matcha Niche Drives the Most Engagement?",
    subtitle = "Ceremonial vs. Commercial engagement rates",
    x = "Market Segment",
    y = "Engagement Rate (Likes+Comments+Shares+Saves / Views)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )
