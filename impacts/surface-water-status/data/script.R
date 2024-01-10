# Surface water status

library(tidyverse) ; library(readODS) ; library(httr) ; library(lubridate)

# Status of surface waters in England, 2019
# Source: Environment Agency
# URL: https://www.gov.uk/government/statistics/england-biodiversity-indicators/21-surface-water-status
tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/media/654a1caebdb7ef00124af950/Eng_BDI_21_surface_water_status.ods", write_disk(tmp))
df <- read_ods(tmp, sheet = "1", range = "A5:W10") %>% 
  select(Classification = 1, Value = `Percentage of WBs in 2019 (cycle 2)`)

# Write results
write_csv(df, "data.csv")
