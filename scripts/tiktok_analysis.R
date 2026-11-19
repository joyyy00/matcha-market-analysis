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
      str_detect(caption_lower, "ceremony|ceremonial|whisk|chawan") ~ "Ceremonial/Traditional",
      str_detect(caption_lower, "strawberry|ube|vanilla|coconut|banana|berry|blueberry|mango|lavender") ~ "Flavors",
      str_detect(caption_lower, "starbucks") ~ "Starbucks",
      str_detect(caption_lower, "latte") ~ "General",
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
    starbucks = str_detect(caption_lower, "starbucks"),
    traditional = str_detect(caption_lower, "ceremony|ceremonial|whisk|chawan"),
    # Specific flavor words only. Broad tokens (sugar, fruit, butter) are excluded.
    flavor_innovation = str_detect(caption_lower, "strawberry|ube|vanilla|coconut|banana|berry|blueberry|mango|lavender"),
    cafe_beverage = str_detect(caption_lower, "latte")
  )

# Look at uncategorized videos
uncategorized_data <- plot_data_tags |>
  filter(
    !starbucks &
      !traditional &
      !flavor_innovation &
      !cafe_beverage
  ) |>
  select(
    video_id,
    caption,
    starbucks,
    traditional,
    flavor_innovation,
    cafe_beverage
  )

# Export excel file and manually categorize them
# write.xlsx(uncategorized_data, "data/process/uncategorized_videos.xlsx", overwrite = TRUE)

# Import the manually labeled file.
# The workbook still calls the Starbucks flag "commercial".
manual_labels <- read_excel("data/process/uncategorized_videos.xlsx") |>
  rename(starbucks = commercial) |>
  mutate(
    starbucks = as.logical(starbucks),
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
        starbucks,
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
    views,
    engagement_rate,
    starbucks,
    traditional,
    flavor_innovation,
    cafe_beverage
  ) |>
  pivot_longer(
    cols = c(
      starbucks,
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
      starbucks = "Starbucks",
      traditional = "Ceremonial/Traditional",
      flavor_innovation = "Flavors",
      cafe_beverage = "General"
    )
  )

# Engagement rates use videos with at least 1,000 views so a few
# very small videos do not set the median.
engagement_rates <- engagement_rates |>
  filter(views >= 1000)


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
    subtitle = "Videos with at least 1,000 views. A video may belong to more than one theme.\nBlack square indicates the median. Rates above 30% are outside the axis.\nEngagement = (likes + comments + shares + saves) / views",
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
    Starbucks = sum(starbucks),
    `Ceremonial/Traditional` = sum(traditional),
    `Flavors` = sum(flavor_innovation),
    `General` = sum(cafe_beverage)
  ) |>
  pivot_longer(
    everything(),
    names_to = "category",
    values_to = "count"
  ) |>
  # Share of videos, not share of tags. A video can carry more than one tag.
  mutate(percentage = count / nrow(tagged_data))

# Bar chart 
ggplot(tag_counts, aes(x = reorder(category, -percentage), y = percentage, fill = category)) + 
  geom_col(alpha = 0.8) + 
  scale_y_continuous(labels = label_percent()) +
  labs(
    title = "Content Theme Frequency on TikTok",
    subtitle = "Share of videos carrying each tag. A video can carry more than one tag.",
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
  # Calculates the sum of starbucks videos and 
  # sum of starbucks and another category 
  summarise(
    starbucks_total = sum(starbucks),
    overlap1 = sum(starbucks & flavor_innovation),
    overlap2 = sum(starbucks & cafe_beverage)
  ) |>
  mutate(
    # overlap of starbucks and flavors 
    pct_overlap1 = overlap1 / starbucks_total * 100,
    # overlap of starbucks and general matcha content 
    pct_overlap2 = overlap2 / starbucks_total * 100
  )

paired_stats


#============================================
# Ceremonial/Traditional engagement vs. Starbucks
# Rate, sample size, and median views. Videos under
# 1,000 views are already excluded from engagement_rates.
#============================================
theme_reach <- engagement_rates |>
  group_by(theme) |>
  summarise(
    n = n(),
    med_eng = median(engagement_rate, na.rm = TRUE),
    med_views = median(views, na.rm = TRUE),
    .groups = "drop"
  )

theme_reach

ceremonial_vs_starbucks <- theme_reach |>
  filter(theme %in% c("Ceremonial/Traditional", "Starbucks")) |>
  select(theme, med_eng) |>
  pivot_wider(names_from = theme, values_from = med_eng) |>
  mutate(multiplier = `Ceremonial/Traditional` / Starbucks) |>
  pull(multiplier)

ceremonial_vs_starbucks


#============================================
# TikTok + Google Trends 
#============================================
# TBD

