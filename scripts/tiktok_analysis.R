library(arrow)
library(tidyverse)
library(scales)
library(ggrepel)
library(ggbeeswarm)
library(openxlsx)
library(readxl)


tiktok_data <- read_parquet("data/clean/clean_tiktok_data.parquet") |>
  mutate(video_id = row_number())

#======================================
# Hierarchal Category Dataset 
#======================================
# Data with Single Categories 
plot_data <- tiktok_data |>
  mutate(
    # Lower case column to search for categories 
    caption_lower = tolower(caption),
    
    # Hierarchical Classification  
    category = case_when(
      str_detect(caption_lower, "ceremonial") ~ "Traditional",
      str_detect(caption_lower, "strawberry|ube|vanilla|coconut|banana|fruit|berry|sugar|blueberry|mango|butter|lavender") ~ "Flavor Innovation",
      str_detect(caption_lower, "starbucks") ~ "Commercial",
      str_detect(caption_lower, "latte") ~ "Cafe Beverage",
      TRUE ~ "General Matcha"
    )
  ) |>
  # Remove new lower case column
  select(-caption_lower)

# Count number of items in category 
plot_data |>
  count(category)


#=================================
# Multi-tagged Dataset   
#=================================
plot_data_tags <- tiktok_data |>
  mutate(
    # Lower case column to search for categories 
    caption_lower = tolower(caption),
    
    # Multiple tags for each video
    commercial = str_detect(caption_lower, "starbucks"),
    traditional = str_detect(caption_lower, "ceremonial"),
    flavor_innovation = str_detect(caption_lower, "strawberry|ube|vanilla|coconut|banana|fruit|berry|sugar|blueberry|mango|butter|lavender"),
    cafe_beverage = str_detect(caption_lower, "latte")
  )

# Look at uncategorized videos
uncategorized_data <- plot_data_tags |>
  filter(
    !commercial &
      !traditional &
      !flavor_innovation &
      !cafe_beverage
  ) |>
  select(
    video_id,
    caption,
    commercial,
    traditional,
    flavor_innovation,
    cafe_beverage
  )

# Export excel file and manually categorize them
# write.xlsx(uncategorized_data, "data/process/uncategorized_videos.xlsx", overwrite = TRUE)

# Import the manually labeled file
manual_labels <- read_excel("data/process/uncategorized_videos.xlsx")

# Convert TRUE/FALSE text to bool
manual_labels <- manual_labels |>
  mutate(
    commercial = as.logical(commercial),
    traditional = as.logical(traditional),
    flavor_innovation = as.logical(flavor_innovation),
    cafe_beverage = as.logical(cafe_beverage),
    remove = as.logical(remove)
  )

# Update the original categorized dataset 
plot_data_tags_updated <- plot_data_tags |>
  rows_update(
    manual_labels |>
      select(
        video_id,
        commercial,
        traditional,
        flavor_innovation,
        cafe_beverage
      ),
    by = "video_id"
  )

# And remove videos
remove_ids <- manual_labels |>
  filter(remove) |>
  pull(video_id)

plot_data_tags_updated <- plot_data_tags_updated |>
  filter(!video_id %in% remove_ids)

# Save 
write_parquet(
  plot_data_tags_updated,
  "data/clean/clean_tiktok_data_tagged.parquet"
)

tagged_data <- read_parquet("data/clean/clean_tiktok_data_tagged.parquet")



#============================================
# Convert multi-tag to long data format 
#============================================
engagement_rates <- tagged_data |>
  select(
    engagement_rate,
    commercial,
    traditional,
    flavor_innovation,
    cafe_beverage
  ) |>
  pivot_longer(
    cols = c(
      commercial,
      traditional,
      flavor_innovation,
      cafe_beverage
    ),
    names_to = "theme",
    values_to = "present"
  ) |>
  # Only get when tags are TRUE
  filter(present) |>
  # Rename 
  mutate(
    theme = recode(
      theme,
      commercial = "Starbucks",
      traditional = "Powder Quality",
      flavor_innovation = "Flavors",
      cafe_beverage = "General Beverage"
    )
  )


#============================================
# Engagement Rate by Category Beeswarm Plot
#============================================
ggplot(engagement_rates, aes(x = reorder(theme, engagement_rate, FUN = median), y = engagement_rate, color = theme)) + 
  geom_quasirandom(alpha = 0.6, size = 2.5, width = 0.2) + 
  # Black point to show median
  stat_summary(fun = median, geom = "point", shape = 15, size = 3, color = "black") +
  scale_y_continuous(labels = label_percent()) + 
  coord_cartesian(ylim = c(0, 0.3)) + 
  labs(
    title = "Engagement Rate Distribution by Matcha Content Themes",
    subtitle = "Videos may belong to multiple themes. Black square indicates the median engagement rate. \nSample size varies per theme. \nEngagement is calculated by (Likes+Comments+Shares+Saves / Views)",
    x = "Content Theme",
    y = "Engagement Rate"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(size = 12)
  )


#============================================
# Category Frequency Bar Chart
#============================================
# Long data format for counts per tag 
tag_counts <- tagged_data |>
  summarise(
    Starbucks = sum(commercial),
    `Powder Quality` = sum(traditional),
    `Flavors` = sum(flavor_innovation),
    `General Matcha` = sum(cafe_beverage)
  ) |>
  pivot_longer(
    everything(),
    names_to = "category",
    values_to = "count"
  ) |>
  # Calculate frequency percentage 
  mutate(percentage = count / sum(count))

# Bar chart 
ggplot(tag_counts, aes(x = reorder(category, -percentage), y = percentage, fill = category)) + 
  geom_col(alpha = 0.8) + 
  scale_y_continuous(labels = label_percent()) +
  labs(
    title = "Content Theme Frequency on TikTok",
    subtitle = "Frequency of common matcha content themes across videos ",
    x = "Content Theme",
    y = "Percentage of Videos"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(size = 12)
  ) + 
  geom_text(
    aes(label = percent(percentage, accuracy = 1)),
    vjust = -0.7,
    size = 4, 
    fontface = "bold",
    color = "gray30"
  )
  

#============================================
# Category Frequency Pairing Stat
# Calculates the percentage of videos of a category that is also paired/overlapping with another category.
# How many of starbucks videos are about flavors of general matcha?
#============================================
paired_stats <- tagged_data |>
  # Calculates the sum of commercial videos and 
  # sum of commercial and another category 
  summarise(
    commercial_total = sum(commercial),
    overlap1 = sum(commercial & flavor_innovation),
    overlap2 = sum(commercial & cafe_beverage)
  ) |>
  mutate(
    # overlap of starbucks and flavors 
    pct_overlap1 = overlap1 / commercial_total * 100,
    # overlap of starbucks and general matcha content 
    pct_overlap2 = overlap2 / commercial_total * 100
  )

paired_stats


#============================================
# Powder quality engagement vs. Starbucks 
# Calculates how much more engagement a video 
# featuring powder quality get than a starbucks video
#============================================
powder <- engagement_rates |>
  group_by(theme) |>
  summarise(med_eng = median(engagement_rate, na.rm = TRUE), .groups = "drop") |>
  filter(theme %in% c("Powder Quality", "Starbucks")) |>
  pivot_wider(names_from = theme, values_from = med_eng) |>
  mutate(multiplier = `Powder Quality` / Starbucks) |>
  pull(multiplier)

powder


#============================================
# TikTok + Google Trends 
#============================================
# TBD

