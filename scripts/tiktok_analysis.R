library(arrow)
library(tidyverse)
library(scales)
library(ggrepel)
library(ggbeeswarm)


tiktok_data <- read_parquet("data/clean/clean_tiktok_data.parquet")

# Prepare data
plot_data <- tiktok_data |>
  mutate(
    # Lower case column to search for categories 
    caption_lower = tolower(caption),
    
    # Hierarchical Classification  
    category = case_when(
      str_detect(caption_lower, "ceremonial") ~ "Traditional",
      str_detect(caption_lower, "starbucks") ~ "Commercial",
      str_detect(caption_lower, "strawberry") ~ "Flavor Innovation",
      str_detect(caption_lower, "latte") ~ "Cafe Beverage",
      TRUE ~ "General Matcha"
    )
  ) |>
  # Remove new lower case column
  select(-caption_lower)

View(plot_data)


#==============================================================
# Consumer Engagement Patterns: Saves vs Views Scatterplot 
#==============================================================
ggplot(plot_data, aes(x = views, y = saves, color = category)) +
  geom_point(alpha = 0.4, size = 2.5) +
  scale_x_log10(labels = label_comma()) + 
  scale_y_log10(labels = label_comma()) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) + 
  labs(
    title = "Consumer Engagement Patterns: Saves vs Views",
    subtitle = "Comparing engagement across distinct consumer personas (Commercial vs. Traditional)",
    x = "Total Views (Log Scale)",
    y = "Total Saves (Log Scale)",
    color = "Market Segment"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))


#============================================
# Engagement Rate by Category Beeswarm Plot
#============================================
ggplot(plot_data, aes(x = reorder(category, engagement_rate, FUN = median), 
                      y = engagement_rate, 
                      color = category)) +
  geom_quasirandom(alpha = 0.6, size = 2.5, width = 0.2) +
  # Black point to show median
  stat_summary(fun = median, geom = "point", shape = 15, size = 3, color = "black") +
  scale_y_continuous(labels = label_percent()) + 
  coord_cartesian(ylim = c(0, 0.3)) + 
  labs(
    title = "Engagement Rate Distribution by Matcha Content Segment",
    subtitle = "Black square indicate the median engagement rate. Each dot is a video.",
    x = "Market Segment",
    y = "Engagement Rate (Likes+Comments+Shares+Saves / Views)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(size = 12, face = "bold")
  )


#============================================
# TikTok + Google Trends 
#============================================
tiktok_summary <- plot_data |>
  group_by(category) |>
  # calculate intent ratio and summarize by category
  summarise(intent_ratio = median(saves / views, na.rm = TRUE)) |>
  # Standardize names to match Google Trends
  mutate(category = case_when(
    category == "General Matcha" ~ "Matcha",
    category == "Latte" ~ "Matcha Latte",
    TRUE ~ category
  ))

View(tiktok_summary)

google_summary <- trends_recent |>
  filter(time >= as.Date("2025-01-01")) |>
  group_by(keyword) |>
  summarise(search_volume = mean(interest, na.rm = TRUE))

View(google_summary)

# Combine tiktok and google trends data on matcha and matcha latte 
matrix_df <- inner_join(tiktok_summary, google_summary, by = c("category" = "keyword"))
View(matrix_df)

# Calculate medians 
median_search <- median(matrix_df$search_volume)
median_intent <- median(matrix_df$intent_ratio)



