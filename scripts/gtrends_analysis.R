library(tidyverse)
library(dplyr)
library(skimr)
library(ggplot2)
library(zoo)
library(lubridate)
library(scales)
library(ggrepel)

df <- read_csv("data/clean/clean_time_series_US_6.csv")

# Convert to tidy format
tidy_df1 <- df |>
  pivot_longer(
    cols = c(matcha, chai, cold_brew, mocha, refresher, psl, smoothie),
    names_to = "keyword",
    values_to = "interest"
  )

# Rename keywords values
tidy_df1 <- tidy_df1 |>
  mutate(
    keyword = recode(
      keyword,
      matcha = "Matcha",
      chai = "Chai",
      cold_brew = "Cold Brew",
      mocha = "Mocha",
      refresher = "Refresher",
      psl = "Pumpkin Spice Latte",
      smoothie = "Smoothie"
    )
  )


#====================================
# Growth rate average stat:
# Calculate the yearly average interest for each drink(keyword)
# and then calculates the growth in percentage from the first
# year to the most recent year (2021 - 2026).
#====================================
growth_stats <- tidy_df1 |>
  mutate(year = year(time)) |>
  group_by(keyword, year) |>
  # Get the yearly average 
  summarise(
    yearly_avg = mean(interest, na.rm = TRUE)
  ) |>
  group_by(keyword) |>
  # Calculations 
  summarise(
    first_year = first(year),
    last_year = last(year),
    first_avg = first(yearly_avg),
    last_avg = last(yearly_avg),
    # Conditional statement for percent calculation
    pct_growth = if_else(
      first_avg > 0,
      ((last_avg - first_avg) / first_avg) * 100,
      NA_real_
    )
  ) |>
  # Arrange in descending order 
  arrange(desc(pct_growth))

growth_stats


#====================================
# Monthly average seasonal pattern line plot
#====================================
seasonal <- tidy_df1 |>
  # Get each month 
  mutate(month = month(time, label = TRUE, abbr = TRUE)) |>
  group_by(keyword, month) |>
  # Get the average each month for each keyword 
  summarise(
    avg_interest = mean(interest, na.rm = TRUE),
  )

# Data point for the label
label_data <- monthly_avg |> 
  filter(keyword == "Matcha", month == "Apr")

# Line plot
ggplot(seasonal, aes(x = month, y = avg_interest, color = keyword, group = keyword)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(
    title = "Average Monthly Search Interest by Beverage",
    subtitle = "Seasonality patterns across beverage trends",
    x = "Month",
    y = "Average Search Interest",
    color = "Beverage"
  ) +
  geom_text_repel(
    data = label_data,
    aes(label = "Growth in Matcha \ninterest during Spring"),
    nudge_y = 13,
    color = "gray20",
    size = 4,
    fontface = "italic",
    box.padding = 0.5
  ) + 
  theme_minimal() + 
  theme(
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(angle = 45, hjust = 0.7)  
  )
  

#====================================
# Average Interest vs Volatility Scatter plot
#====================================
cv <- tidy_df1 |>
  group_by(keyword) |>
  # Get the average, standard deviation, and coefficient variance of search interest 
  summarise(
    mean_interest = mean(interest, na.rm = TRUE),
    sd_interest = sd(interest, na.rm = TRUE),
    cv_interest = sd_interest / mean_interest,
    .groups = "drop"
  )

ggplot(cv, aes(x = mean_interest, y = cv_interest, label = keyword)) +
  geom_point(size = 3) +
  geom_text_repel(size = 4) +
  labs(
    title = "Beverage Steadiness",
    subtitle = "Average search interest vs. relative volatility",
    x = "Average Search Interest",
    y = "Volatility (Coefficient Variation)"
  ) +
  theme_minimal() + 
  theme(plot.title = element_text(face = "bold", size = 16))
  
  
#====================================
# Growth stability matrix
#====================================
# Calculate growth and volaility 
matrix_info <- tidy_df1 |>
  group_by(keyword) |>
  summarise(
    volatility = sd(interest, na.rm = TRUE) / mean(interest, na.rm = TRUE),
    
    # Compare the last 12 months of data to the first 12 months
    first_year_avg = mean(head(interest, 12), na.rm = TRUE),
    last_year_avg = mean(tail(interest, 12), na.rm = TRUE),
    growth_rate = (last_year_avg - first_year_avg) / first_year_avg,
    .groups = 'drop'
  )

# Calculate median 
median_growth <- median(matrix_info$growth_rate, na.rm = TRUE)
median_volatility <- median(matrix_info$volatility, na.rm = TRUE)

# Matrix plot
ggplot(matrix_info, aes(x = growth_rate, y = volatility, label = keyword)) +
  # Quadrant Lines
  geom_hline(yintercept = median_volatility, linetype = "dashed", color = "gray45") +
  geom_vline(xintercept = median_growth, linetype = "dashed", color = "gray45") +
  
  geom_point(size = 5, color = "#0e288e", alpha = 0.8) +
  geom_text_repel(size = 5, point.padding = 0.5, box.padding = 0.8, min.segment.length = 0) + 
  
  labs(
    title = "Growth-Stability of Beverages",
    subtitle = "Comparing long-term growth vs. search volume volatility",
    x = "Long-Term Growth Rate (First Year vs. Last Year)",
    y = "Volatility (Coefficient of Variation)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 16))
