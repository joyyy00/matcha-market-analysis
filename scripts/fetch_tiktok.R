library(httr2)
library(jsonlite)
library(dplyr)
library(arrow)

apify_urls_str <- Sys.getenv("APIFY_URL")

# Check if api url exists
if (apify_urls_str == "") {
  stop("Error: APIFY_URL is missing. Check your .Renviron file.")
}

apify_urls <- strsplit(apify_urls_str, ",")[[1]]
apify_urls <- trimws(apify_urls)
# Remove any leftover literal quotes or hidden newlines that might cause the bad IPv6 error
apify_urls <- gsub("[\"'\r\n]", "", apify_urls)

print(paste("Fetching TikTok data from", length(apify_urls), "Apify dataset(s)..."))

all_data_list <- list()

for (url in apify_urls) {
  req <- request(url) |> req_perform()
  raw_data <- resp_body_json(req, simplifyVector = TRUE)
  
  # Flatten the nested tables into normal columns with dots
  flat_data <- jsonlite::flatten(as.data.frame(raw_data))
  all_data_list[[length(all_data_list) + 1]] <- flat_data
}

# Combine all fetched datasets
combined_flat_data <- bind_rows(all_data_list)

print("Data fetched and flattened successfully! Cleaning columns...")

# Cleaning
clean_tiktok <- combined_flat_data |>
  select(
    timestamp = createTimeISO,
    caption = text,
    views = playCount,
    likes = diggCount,
    shares = shareCount,
    comments = commentCount,
    saves = collectCount,            
    duration_sec = `videoMeta.duration`, 
    author_name = `authorMeta.name`,
    music_name = `musicMeta.musicName`
  ) |>
  mutate(
    timestamp = as.Date(timestamp),
    views = as.numeric(views),
    likes = as.numeric(likes),
    shares = as.numeric(shares),
    comments = as.numeric(comments),
    saves = as.numeric(saves),
    duration_sec = as.numeric(duration_sec),
    engagement_rate = (likes + comments + shares + saves) / views
  ) |>
  filter(!is.na(views))

View(clean_tiktok)

print(paste("Cleaning complete. Rows processed:", nrow(clean_tiktok)))

# Save
write_parquet(clean_tiktok, "data/clean/clean_tiktok_data.parquet")

print("Finished.")