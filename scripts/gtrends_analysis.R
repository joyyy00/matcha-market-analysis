library(tidyverse)
library(dplyr)
library(skimr)
library(ggplot2)
library(zoo)


# CSV files to dataframes
matcha_df <- read_csv("data/clean/clean_time_series_US.csv")
ml_df <- read_csv("data/clean/clean_time_series_US_1.csv")
strawberry_ml_df <- read_csv("data/clean/clean_time_series_US_2.csv")
boba_df <- read_csv("data/clean/clean_time_series_US_3.csv")
psl_df <- read_csv("data/clean/clean_time_series_US_4.csv")
all_df <- read_csv("data/clean/clean_time_series_US_5.csv")


# Convert to tidy format
tidy_df <- all_df |>
  pivot_longer(
    cols = c(matcha, matcha_latte, strawberry_ml, boba, psl),
    names_to = "keyword",
    values_to = "interest"
  )

# Rename keywords values
tidy_df <- tidy_df |>
  mutate(
    keyword = recode(
      keyword,
      matcha = "Matcha",
      matcha_latte = "Matcha Latte",
      strawberry_ml = "Strawberry Matcha Latte",
      boba = "Boba",
      psl = "Pumpkin Spice Latte"
    )
  )



# Filter time to start at 2016 and remove Strawberry Matcha Latte
trends_recent <- tidy_df |>
  filter(time >= as.Date("2016-01-01"), keyword != "Strawberry Matcha Latte")

# Faceted Line Plot
ggplot(trends_recent, aes(x = time, y = interest, color = keyword)) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1.2) + 
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") + 
  facet_wrap(~keyword, scales = "free_y") + 
  labs(
    title = "Smoothed Google Search Interest by Beverage", 
    subtitle = "Monthly Google Trends data (2016 - 2026)",
    x = "Year", 
    y = "Search Interest") + 
  theme(
    legend.position = "none", 
    strip.text = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 16)) 


  
# Rolling Average Line plot
rol_avg <- trends_recent |>
  group_by(keyword) |>
  arrange(time) |>
  mutate(rolling_avg = rollmean(interest, k = 6, fill = NA))

ggplot(rol_avg, aes(x = time, y = rolling_avg, color = keyword)) +
  geom_line(linewidth = 1.2) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") + 
  labs(
    title = "6-Month Rolling Average of Beverage Search Interest",
    subtitle = "Smoothed Google Trends data",
    x = "Year",
    y = "Rolling Average Interest") + 
  theme_minimal() + 
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 16)
  )



# Matcha (Umbrella term) and Matcha Drinks 
matcha_beverages <- tidy_df %>%
  filter( keyword %in% c(
      "Matcha Latte",
      "Strawberry Matcha Latte"
    ),
    time >= as.Date("2016-01-01"))

ggplot(matcha_beverages, aes(x = time, y = interest, color = keyword)) +
  geom_smooth( method = "loess", se = FALSE, linewidth = 1.3) +
  scale_x_date( date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Emerging Matcha Beverage Trends",
    subtitle = "Search interest in matcha-based beverages",
    x = "Year",
    y = "Search Interest") +
  theme_minimal()

matcha_beverages_plot


# Monthly Average Seasonal Plot
monthly_avg <- tidy_df |>
  mutate(month = month(time, label = TRUE)) |>
  group_by(keyword, month) |>
  summarise(avg_interest = mean(interest))

ggplot(monthly_avg, aes(x = month, y = avg_interest, color = keyword, group = keyword)) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  labs(
    title = "Average Monthly Search Interest",
    x = "Month",
    y = "Average Interest") + 
  theme_minimal()



# Growth Rate Plot
growth_df <- tidy_df |>
  group_by(keyword) |>
  arrange(time) |>
  mutate(pct_change = ((interest / lag(interest)) - 1) * 100)

ggplot(growth_df, aes(x = time, y = pct_change, color = keyword)) +
  geom_smooth(se = FALSE) +
  labs(
    title = "Search Interest Growth Rates",
    y = "Percent Change") +
  theme_minimal()

