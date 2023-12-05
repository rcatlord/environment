# Woodland cover by local authority
## United Kingdom, 2021

### Datasets
- [National Forest Inventory Woodland GB 
(2021)](https://data-forestry.opendata.arcgis.com/datasets/5b91b7041f8b46e099f64aa6d2013e9d_0/explore), Forest Research    
- [Northern Ireland Woodland Register (2021)](https://www.daera-ni.gov.uk/publications/woodland-register), Department of Agriculture, Environment and Rural Affairs   
- [Local Authority Districts (2021)](https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-december-2021-gb-bgc-1), Office for National Statistics' Open Geography Portal    
- [Standard Area Measurements (2021) for Administrative Areas in the United Kingdom](https://geoportal.statistics.gov.uk/datasets/standard-area-measurements-2021-for-administrative-areas-in-the-united-kingdom-v2/about), Office for National Statistics' Open Geography Portal    

### Method
The percentage of local authority area covered by woodland was calculated following the method presented in [Office for National Statistics 2021](https://www.ons.gov.uk/economy/environmentalaccounts/articles/carbondioxideemissionsandwoodlandcoveragewhereyoulive/2021-10-21#measuring).

1. Clip the National Forest Inventory (NFI) woodland map by Great Britain's Local Authority District boundaries and calculate the total area of woodland they contain.
2. Combine the results with the Northern Ireland Woodland Register which provides the woodland area of each Local Government District.
3. Calculate the percentage of woodland cover for each administrative area using the land area measurement (`AREALHECT`) in the Standard Area Measurements.

### R code
```r
library(tidyverse) ; library(readxl) ; library(sf) ; library(units) 

# Standard Area Measurements (2021) for Administrative Areas in the United Kingdom
# Source: Open Geography Portal, Office for National Statistics
# URL: https://geoportal.statistics.gov.uk/datasets/standard-area-measurements-2021-for-administrative-areas-in-the-united-kingdom-v2/about
sam <- read_csv("data/SAM_LAD_DEC_2021_UK.csv") %>% 
  # excluding areas of inland water
  select(AREACD = LAD21CD, AREANM = LAD21NM, AREALHECT) %>% 
  mutate(AREALM2 = AREALHECT*10000) # to m2

# Vector boundary of local authority districts (GB)
# Source: Open Geography Portal, Office for National Statistics
# URL: https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-december-2021-gb-bgc-1
ltla <- read_sf("data/Local_Authority_Districts_December_2021_GB_BGC_2022_4485095093561745628.geojson") %>% 
  select(AREACD = LAD21CD)

# Woodland in Great Britain (2021)
# Source: National Forest Inventory, Forest Research
# URL: https://data-forestry.opendata.arcgis.com/datasets/5b91b7041f8b46e099f64aa6d2013e9d_0/explore
gb <- read_sf("data/National_Forest_Inventory_Woodland_GB_2021.shp") %>% 
  filter(CATEGORY == "Woodland") %>% 
  st_transform(27700) %>% 
  # clip polygons to ltla boundary
  st_intersection(ltla) %>%
  # calculate area (sq/m) of woodland
  mutate(area = as.numeric(set_units(st_area(.), m^2))) %>%
  group_by(AREACD) %>%
  # calculate total area (sq/m) of woodland by local authority district
  summarise(area = sum(area)) %>%
  ungroup()

# Woodland in Northern Ireland (2021)
# Source: Northern Ireland Woodland Register, DAERA
# URL: http://web.archive.org/web/20220711091853/https://www.daera-ni.gov.uk/sites/default/files/publications/daera/NI%20Woodland%20Register%202021%20v1_0.xlsx
ni <- read_xlsx("data/NI Woodland Register 2021 v1_0.xlsx",
                sheet = 1,
                range = "B39:X49") %>% 
  filter(...1 == "Council total") %>% 
  select(-matches("[0-9]")) %>% 
  pivot_longer(cols = everything(), names_to = "AREANM", values_to = "area") %>% 
  mutate(AREACD = 
           case_when(AREANM == "North Down and Ards" ~ "N09000011",
                     AREANM == "Antrim and Newtownabbey" ~ "N09000001",
                     AREANM == "Armagh Banbridge and Craigavon" ~ "N09000002",
                     AREANM == "Belfast" ~ "N09000003",
                     AREANM == "Causeway Coast and Glens" ~ "N09000004",
                     AREANM == "Derry and Strabane" ~ "N09000005",
                     AREANM == "Fermanagh and Omagh" ~ "N09000006",
                     AREANM == "Lisburn and Castlereagh" ~ "N09000007",
                     AREANM == "Mid and East Antrim" ~ "N09000008",
                     AREANM == "Mid Ulster" ~ "N09000009",
                     AREANM == "Newry Mourne and Down" ~ "N09000010"),
         area = as.numeric(area)*10000) %>% # to m2
  select(AREACD, area)

# Join datasets and calculate woodland coverage
uk <- gb %>% 
  st_drop_geometry(gb) %>% 
  bind_rows(ni) %>% 
  left_join(sam, by = "AREACD") %>% 
  mutate(percent = round((area/AREALM2)*100,1)) %>% 
  select(AREACD, AREANM, percent)

# Write results
write_csv(uk, "../data/data.csv")
```
