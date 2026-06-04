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
write_csv(clean_time_series_1, "data/clean/clean_time_series_US_1.csv")
write_csv(clean_top_queries_1, "data/clean/clean_top_queries_US_1.csv")
write_csv(clean_rising_queries_1, "data/clean/clean_rising_queries_US_1.csv")


#################################################
#
#     2. Google Trends Data - Strawberry Matcha Latte 
#
#################################################
rising_queries_2 <- read_csv("data/raw/gtrends_rising-queries_US_2.csv")
top_queries_2 <- read_csv("data/raw/gtrends_top-queries_US_2.csv")
time_series_2 <- read_csv("data/raw/gtrends_time_series_US_2.csv")

View(time_series_2)

# Clean time series 
clean_time_series_2 <- time_series_2 |>
  rename_with(tolower) |>
  rename(strawberry_ml = "strawberry matcha latte") |>
  mutate(
    strawberry_ml = str_replace(strawberry_ml, "<1", "0"),
    strawberry_ml = as.numeric(strawberry_ml),
    time = as.Date(time) 
  )

View(clean_time_series_2)


# Clean top queries
clean_top_queries_2 <- top_queries_2 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_top_queries_2)


# Clean rising queries
clean_rising_queries_2 <- rising_queries_2 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>  
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_rising_queries_2)

# Save cleaned data to clean folder
write_csv(clean_time_series_2, "data/clean/clean_time_series_US_2.csv")
write_csv(clean_top_queries_2, "data/clean/clean_top_queries_US_2.csv")
write_csv(clean_rising_queries_2, "data/clean/clean_rising_queries_US_2.csv")




#################################################
#
#     3. Google Trends Data - Boba
#
#################################################
rising_queries_3 <- read_csv("data/raw/gtrends_rising-queries_US_3.csv")
top_queries_3 <- read_csv("data/raw/gtrends_top-queries_US_3.csv")
time_series_3 <- read_csv("data/raw/gtrends_time_series_US_3.csv")

View(time_series_3)

# Clean time series 
clean_time_series_3 <- time_series_3 |>
  rename_with(tolower) |>
  rename(boba = "boba") |>
  mutate(
    boba = str_replace(boba, "<1", "0"),
    boba = as.numeric(boba),
    time = as.Date(time) 
  )


# Clean top queries
clean_top_queries_3 <- top_queries_3 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_top_queries_3)


# Clean rising queries
clean_rising_queries_3 <- rising_queries_3 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>  
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )

View(clean_rising_queries_3)

# Save cleaned data to clean folder
write_csv(clean_time_series_3, "data/clean/clean_time_series_US_3.csv")
write_csv(clean_top_queries_3, "data/clean/clean_top_queries_US_3.csv")
write_csv(clean_rising_queries_3, "data/clean/clean_rising_queries_US_3.csv")


#################################################
#
#     4. Google Trends Data - Pumpkin Spice Latte
#
#################################################
rising_queries_4 <- read_csv("data/raw/gtrends_rising-queries_US_4.csv")
top_queries_4 <- read_csv("data/raw/gtrends_top-queries_US_4.csv")
time_series_4 <- read_csv("data/raw/gtrends_time_series_US_4.csv")


# Clean time series 
clean_time_series_4 <- time_series_4 |>
  rename_with(tolower) |>
  rename(psl = "pumpkin spice latte") |>
  mutate(
    psl = str_replace(psl, "<1", "0"),
    psl = as.numeric(psl),
    time = as.Date(time) 
  )


# Clean top queries
clean_top_queries_4 <- top_queries_4 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )


# Clean rising queries
clean_rising_queries_4 <- rising_queries_4 |>
  rename(
    search_interest = "search interest",
    increase_percent = "increase percent"
  ) |>  
  mutate(
    search_interest = as.numeric(search_interest),
    increase_percent = str_replace(increase_percent, "%", ""),
    increase_percent = as.numeric(increase_percent)
  )


# Save cleaned data to clean folder
write_csv(clean_time_series_4, "data/clean/clean_time_series_US_4.csv")
write_csv(clean_top_queries_4, "data/clean/clean_top_queries_US_4.csv")
write_csv(clean_rising_queries_4, "data/clean/clean_rising_queries_US_4.csv")


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





