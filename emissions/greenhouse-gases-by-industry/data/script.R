# Greenhouse gas emissions by industry

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

# Atmospheric emissions: greenhouse gases by industry and gas
# Source: Office for National Statistics
# URL: https://www.ons.gov.uk/economy/environmentalaccounts/datasets/ukenvironmentalaccountsatmosphericemissionsgreenhousegasemissionsbyeconomicsectorandgasunitedkingdom

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://www.ons.gov.uk/file?uri=/economy/environmentalaccounts/datasets/ukenvironmentalaccountsatmosphericemissionsgreenhousegasemissionsbyeconomicsectorandgasunitedkingdom/current/atmoshpericemissionsghg.xlsx", write_disk(tmp))
df <- read_xlsx(tmp, sheet = "GHG total ", range = "A4:AI161") %>% 
  filter(...3 %in% c("Manufacturing", "Electricity, gas, steam and air conditioning supply",
                    "Transport and storage", "Consumer expenditure",
                    "Agriculture, forestry and fishing", 
                    "Water supply; sewerage, waste management and remediation activities")) %>% 
  select(-c(1,2)) %>% 
  rename(Industry = 1) %>% 
  pivot_longer(-Industry, names_to = "Year", values_to = "Value") %>% 
  mutate(Year = ymd(Year, truncated = 2L),
         Industry = case_when(
           Industry == "Electricity, gas, steam and air conditioning supply" ~ "Energy supply",
           Industry == "Consumer expenditure" ~ "Households",
           Industry == "Agriculture, forestry and fishing" ~ "Agriculture",
           Industry == "Water supply; sewerage, waste management and remediation activities" ~ "Water supply",
           TRUE ~ Industry
         ),
         Value = Value/1000) %>% 
  select(Year, Industry, Value)

# Write results
write_csv(df, "data.csv")

