library(tidyverse) ; library(httr) ; library(readxl) ; library(showtext)

# Worry about climate change
# Source: ONS, Opinions and Lifestyle Survey (OPN)
# URL: https://www.ons.gov.uk/economy/environmentalaccounts/datasets/climatechangeinsightsfamiliesandhouseholdsukworriesaboutclimatechangeandchangestolifestyletohelptackleitgreatbritain14juneto9july2023
tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://www.ons.gov.uk/file?uri=/economy/environmentalaccounts/datasets/climatechangeinsightsfamiliesandhouseholdsukworriesaboutclimatechangeandchangestolifestyletohelptackleitgreatbritain14juneto9july2023/14juneto9july2023/climatechangeworriesandchangestolifestyle14juneto9july2023.xlsx", write_disk(tmp))
age <- read_xlsx(tmp, sheet = "1", range = "A14:F20") %>% 
  select(response = 1, `16 to 29` = 3, `30 to 49` = 4, `50 to 69` = 5, `70+` = 6) %>% 
  slice(-1) %>% 
  pivot_longer(-response, names_to = "group", values_to = "percent") %>% 
  mutate(response = fct_relevel(response, c("Very worried", "Somewhat worried", "Neither worried nor unworried", "Somewhat unworried", "Not at all worried")),
         background = 100)

font_add_google("Open Sans")
showtext_auto(enable = TRUE)
showtext_opts(dpi = 96)

ggplot(age, aes(x = fct_rev(group), y = percent)) +
  geom_col(aes(x = fct_rev(group), y = background), fill = "#E5E6E7", width = 0.9) +
  geom_col(aes(fill = response), width = 0.9) +
  geom_text(aes(label = scales::percent(percent/100), hjust = ifelse(percent > 30, 1.15, -0.1)), 
            colour = ifelse(age$percent > 30, "#FFFFFF", "#000000"), fontface = "bold") +
  scale_fill_manual(values = c("#871A5B", "#F66068", "#A8BD3A", "#27A0CC", "#206095")) +
  facet_wrap(~response, nrow = 1, labeller = label_wrap_gen(width = 10)) +
  coord_flip() +
  labs(title = "Level of worry about climate change by age group",
       subtitle = "Great Britain, 14 June to 9 July 2023",
       tag = "Q. In the past 12 months, how worried or unworried have you been about the impact of climate change?",
       caption = "Source: ONS, Opinions and Lifestyle Survey") +
  theme_minimal(base_size = 12) + 
  theme(text = element_text(family = "Open Sans"),
        plot.margin = unit(c(3,0.5,3,0.5),"cm"),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size = 12),
        legend.position = "none",
        plot.title.position = "plot",
        plot.title = element_text(size = 18, face = "bold"),
        plot.subtitle = element_text(size = 14, margin = margin(b = 15)),
        plot.tag = element_text(size = 10),
        plot.tag.position = c(0.45, 0.12),
        plot.caption = element_text(size = 12, colour = "grey60", margin = margin(t = 35)),
        strip.text.x = element_text(size = 12, face = "bold", hjust = 0, vjust = -0.15))

showtext_opts(dpi = 300)
ggsave("worry_about_climate_change.png", dpi = 300)
