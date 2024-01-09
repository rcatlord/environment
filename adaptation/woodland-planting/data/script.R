# New planting of UK woodlands

library(tidyverse) ; library(lubridate)

# New planting in the United Kingdom, 1971 - 2022
# Source: Forest Research
# URL: https://beta.gss-data.org.uk/download/live/20ef0579-3a2d-5010-a7ba-71d1b9978aad/gss-data-org-uk-forestry-statistics-2022-new-planting.zip?job%2Ftype=mut.download%2Fjob&job%2Fid=mut.cube%2Fcsv&uri=http%3A%2F%2Fgss-data.org.uk%2Fdata%2Fclimate-change%2Fforestry-research-forestry-statistics-2022-new-planting%2Fforestry-statistics-2022-new-planting%23dataset-catalog-entry
url <- "https://beta.gss-data.org.uk/downloads/live/20ef0579-3a2d-5010-a7ba-71d1b9978aad/gss-data-org-uk-forestry-statistics-2022-new-planting.zip"
download.file(url, dest = "gss-data-org-uk-forestry-statistics-2022-new-planting.zip")
unzip("gss-data-org-uk-forestry-statistics-2022-new-planting.zip")
file.remove("gss-data-org-uk-forestry-statistics-2022-new-planting.zip")

df <- read_csv("gss-data-org-uk-forestry-statistics-2022-new-planting/data.csv") %>% 
  select(Year, Conifers = `New Conifers`, Broadleaves = `New Broadleaves`) %>% 
  pivot_longer(-Year, names_to = "group", values_to = "value") %>% 
  filter(!is.na(value)) %>% 
  pivot_wider(names_from = group, values_from = value) %>% 
  arrange(Year)

# Write results
df %>% 
  pivot_longer(-Year, names_to = "Group", values_to = "Value") %>%
  mutate(Year = ymd(Year, truncated = 2L)) %>%
  write_csv("data.csv")