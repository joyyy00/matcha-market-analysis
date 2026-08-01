library(tidyverse)
library(dplyr)
library(readr)
library(skimr)
library(janitor)
library(corrplot)

#################################################
#
#     5. Google Trends Data - all (ignore)
#
#################################################
time_series_5 <- read_csv("data/raw/gtrends_time_series_US_5.csv")

# Clean time series 
clean_time_series_5 <- time_series_5 |>
  rename_with(tolower) |>
  rename(matcha_latte = "matcha latte", strawberry_ml = "strawberry matcha latte", psl = "pumpkin spice latte") |>
  mutate(
    across(
      c(matcha, matcha_latte, strawberry_ml, boba, psl),
      ~ as.numeric(str_replace(.x, "<1", "0"))
    ),
    time = as.Date(time) 
  )
View(clean_time_series_5)


# Save cleaned data to clean folder
write_csv(clean_time_series_5, "data/clean/clean_time_series_US_5.csv")


#####################################################################
#
#     6. Google Trends Data - all (used dataset)
#
#####################################################################
time_series_6 <- read_csv("data/raw/gtrends_time_series_US_6.csv")

# Clean time series 
clean_time_series_6 <- time_series_6 |>
  rename_with(tolower) |>
  rename(psl = "pumpkin spice latte", cold_brew = "cold brew") |>
  mutate(
    across(
      c(matcha, psl, cold_brew, smoothie, mocha, refresher, chai),
      ~ as.numeric(str_replace(.x, "<1", "0"))
    ),
    time = as.Date(time) 
  )
View(clean_time_series_6)


# Save cleaned data to clean folder
write_csv(clean_time_series_6, "data/clean/clean_time_series_US_6.csv")





