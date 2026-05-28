library(httr2)
library(jsonlite)
library(dplyr)
library(arrow)

apify_url <- Sys.getenv("APIFY_URL")

# Check if api url exists
if (apify_url == "") {
  stop("Error: APIFY_URL is missing. Check your .Renviron file.")
}

print("Fetching TikTok data from Apify...")

# Fetch and parse the data from URL
req <- request(apify_url) |> req_perform()
raw_data <- resp_body_json(req, simplifyVector = TRUE)

# Force R to flatten the nested tables into normal columns with dots
flat_data <- jsonlite::flatten(as.data.frame(raw_data))

print("Data fetched and flattened successfully! Cleaning columns...")

# Cleaning
clean_tiktok <- flat_data |>
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