# Greenhouse gas emissions

library(tidyverse) ; library(readODS) ; library(httr) ; library(readxl)

# Territorial emissions
# Source: Department for Energy Security and Net Zero and Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistics/provisional-uk-greenhouse-gas-emissions-national-statistics-2022
tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/media/642588293d885d000cdadf45/2022-provisional-emissions-data-tables.xlsx", write_disk(tmp))
territorial <- read_xlsx(tmp, sheet = "Table1", skip = 4) %>% 
  filter(`NC Sector` == "Total greenhouse gases") %>% 
  select(-`NC Sector`) %>% 
  pivot_longer(everything(), names_to = "Year", values_to = "value") %>% 
  mutate(Year = as.numeric(Year),
         measure = "Territorial")

# Residence emissions
# Source: Office for National Statistics
# URL: https://www.ons.gov.uk/economy/environmentalaccounts/datasets/ukenvironmentalaccountsatmosphericemissionsgreenhousegasemissionsbyeconomicsectorandgasunitedkingdom
tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://www.ons.gov.uk/file?uri=/economy/environmentalaccounts/datasets/ukenvironmentalaccountsatmosphericemissionsgreenhousegasemissionsbyeconomicsectorandgasunitedkingdom/current/atmoshpericemissionsghg.xlsx", write_disk(tmp))
residence <- read_xlsx(tmp, sheet = "GHG total ", range = "A4:AI27") %>% 
  filter(...3 == "Total greenhouse gas emissions") %>% 
  select(4:last_col()) %>% 
  pivot_longer(everything(), names_to = "Year", values_to = "value") %>% 
  mutate(Year = as.numeric(Year),
         value = value/1000, # Mt CO2e
         measure = "Residence")

# Carbon footprint emissions
# Source: Department for Environment, Food & Rural Affairs
# URL: https://www.gov.uk/government/statistics/uks-carbon-footprint
tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/media/64ca46236ae44e001311b3df/2020_Defra_results_UK_rev.ods", write_disk(tmp))
consumption <- read_ods(tmp, sheet = "Dashboard_2020", range = "B3:C34") %>% 
  rename(Year = 1, value = 2) %>% 
  mutate(Year = as.numeric(Year),
         value = value/1000, # Mt CO2e
         measure = "Consumption")

# Write results
bind_rows(territorial, residence, consumption) %>% 
  pivot_wider(names_from = measure, values_from = value) %>% 
  write_csv("data.csv")
