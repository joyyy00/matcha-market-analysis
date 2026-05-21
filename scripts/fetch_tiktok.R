library(httr2)
library(jsonlite)

# Paste your exact link from Apify here
test_req <- request("https://api.apify.com/v2/datasets/9fg6S2BgTvZXxAlqu/items?token=apify_api_acO3hV5fb9FRSacjDDkI6TmeOCaQ4C0VZ2Kd") |>
  req_perform()

# Parse the JSON response (flattening it into a clean dataframe)
test_data <- resp_body_json(test_req, simplifyVector = TRUE)

# Print the column names to verify everything loaded
print(names(test_data))