# Atmospheric CO2
# Source: NOAA
# URL: https://gml.noaa.gov/ccgg/trends/data.html

library(tidyverse) ; library(showtext) ; library(ggtext) ; library(ggrepel)

df <- read_csv("https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.csv",
               skip = 40) %>% 
  filter(year >= 1960) %>% 
  mutate(date = as.Date(date_decimal(`decimal date`, tz = "UTC"))) %>% 
  select(date, average)

ggplot(df, aes(x = date, y = average, group = 1)) +
  geom_ribbon(aes(ymin = 280, ymax = average), fill = "#CBFFA9") +
  geom_line(linewidth = 1, colour = "#3EA303") +
  scale_x_date(expand = c(0.005, 0.005),
               breaks = seq.Date(as.Date("1960-01-01"), as.Date("2020-01-01"), by = "10 years"),
               date_labels = "%Y") + 
  scale_y_continuous(expand = c(0.005, 0.005), 
                     limits = c(280, 450)) +
  labs(x = NULL, y = NULL,
       title = "<span>Atmospheric CO<sub>2</sub>",
       subtitle = "Monthly average, Mauna Loa Observatory",
       tag = "Chart baseline is 280ppm - the preindustrial average",
       caption = "Source: NOAA") +
  theme_minimal(base_size = 12) +
  theme(plot.margin = unit(rep(1.5, 4), "cm"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(colour = "#000000"),
        plot.title.position = "plot",
        plot.title = element_markdown(face = "bold", size = 18),
        plot.subtitle = element_text(margin = margin(b = 25)),
        plot.caption = element_text(colour = "grey60", margin = margin(t = 20, b = -10), size = 12),
        plot.tag = element_text(size = 10),
        plot.tag.position = c(0.2, 0.01)) +
  annotate("text", x = as.Date("1963-01-01"), y = 450, label = "Parts per million", size = 3) +
  geom_text(data = filter(df, date == last(date)),
            aes(label = paste0(format(date, "%b %Y"), "\n", round(average, 1), "ppm")),
            hjust = -0.1, size = 3, fontface = "bold") +
  coord_cartesian(clip = "off")

ggsave("plot.png")
