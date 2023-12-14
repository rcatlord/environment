# Greenhouse gas emissions by type

library(tidyverse)

# UK greenhouse gas emissions national statistics: 1990 to 2021
# Source: Department for Business, Energy & Industrial Strategy
# URL: https://beta.gss-data.org.uk/cube/explore?uri=http%3A%2F%2Fgss-data.org.uk%2Fdata%2Fclimate-change%2Fbeis-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021%2Fuk-greenhouse-gas-emissions-national-statistics-1990-to-2021%23dataset-catalog-entry&order-by-component=http%253A%252F%252Fgss-data.org.uk%252Fdata%252Fclimate-change%252Fbeis-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021%252Fuk-greenhouse-gas-emissions-national-statistics-1990-to-2021%2523dimension%252Fyear&order-direction=ASC

url <- "https://beta.gss-data.org.uk/downloads/live/193cdada-e603-55d9-8d94-e9bdb867b97a/gss-data-org-uk-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021.zip"
download.file(url, dest = "gss-data-org-uk-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021.zip")
unzip("gss-data-org-uk-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021.zip")
file.remove("gss-data-org-uk-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021.zip")

df <- read_csv("gss-data-org-uk-uk-greenhouse-gas-emissions-national-statistics-1990-to-2021/data.csv") %>% 
  filter(`Geographic Coverage` == "United Kingdom",
         `Greenhouse Gas` != "Total Greenhouse Gases",
         Breakdown == "Including net emissions and removals from LULUCF",
         `National Communication Sector` == "Grand Total") %>% 
  select(Year, Gas = `Greenhouse Gas`, Value = `Gas Emissions`) %>% 
  pivot_wider(names_from = Gas, values_from = Value) %>% 
  arrange(Year)

# Write results
write_csv(df, "data.csv")
