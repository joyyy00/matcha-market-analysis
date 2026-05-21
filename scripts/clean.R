library(tidyverse)
library(dplyr)
library(readr)
library(skimr)
library(janitor)
library(corrplot)


###############################################
#
#     0. Google Trends Data - Matcha
#
###############################################
rising_queries <- read_csv("data/raw/gtrends_rising-queries_US.csv")
top_queries <- read_csv("data/raw/gtrends_top-queries_US.csv")
time_series <- read_csv("data/raw/gtrends_time_series_US.csv")

head(rising_queries)
summary(rising_queries)
head(top_queries)
summary(top_queries)
head(time_series)
summary(time_series)



# Clean time series 
clean_time_series <- time_series |>
  rename_with(tolower) |>
  mutate(
    matcha = str_replace(matcha, "<1", "0"),
    matcha = as.numeric(matcha),
    time = as.Date(time) 
  )

View(clean_time_series)


# Clean top queries
clean_top_queries <- top_queries |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_top_queries)
  

# Clean rising queries
clean_rising_queries <- rising_queries |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>  
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_rising_queries)
  
# Save cleaned data to clean folder
write_csv(clean_time_series, "data/clean/clean_time_series_US.csv")
write_csv(clean_top_queries, "data/clean/clean_top_queries_US.csv")
write_csv(clean_rising_queries, "data/clean/clean_rising_queries_US.csv")


#################################################
#
#     1. Google Trends Data - Matcha Latte
#
#################################################
rising_queries_1 <- read_csv("data/raw/gtrends_rising-queries_US_1.csv")
top_queries_1 <- read_csv("data/raw/gtrends_top-queries_US_1.csv")
time_series_1 <- read_csv("data/raw/gtrends_time_series_US_1.csv")

View(time_series_1)

# Clean time series 
clean_time_series_1 <- time_series_1 |>
  rename_with(tolower) |>
  rename(matcha_latte = "matcha latte") |>
  mutate(
    matcha_latte = str_replace(matcha_latte, "<1", "0"),
    matcha_latte = as.numeric(matcha_latte),
    time = as.Date(time) 
  )

View(clean_time_series_1)


# Clean top queries
clean_top_queries_1 <- top_queries_1 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_top_queries_1)


# Clean rising queries
clean_rising_queries_1 <- rising_queries_1 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>  
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_rising_queries_1)

# Save cleaned data to clean folder
write_csv(clean_time_series, "data/clean/clean_time_series_US_1.csv")
write_csv(clean_top_queries, "data/clean/clean_top_queries_US_1.csv")
write_csv(clean_rising_queries, "data/clean/clean_rising_queries_US_1.csv")


#################################################
#
#     1. Google Trends Data - CHai
#
#################################################



###########################################
#
#     Apify TikTok 
# 
###########################################







