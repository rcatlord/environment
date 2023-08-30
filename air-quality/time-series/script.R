library(openair) 
library(tidyverse) 
library(scales)
library(ggtext)

# inspect sites on Air Quality England network
meta <- importMeta(source = "aqe", all = TRUE) 

# import data from Trafford A56 site
trf2 <- importAQE(site = "TRF2", year = 2020:2023, data_type = "daily")

# plot results
timePlot(trf2, pollutant = "pm10")

ggplot(trf2, aes(date, pm10)) + 
  geom_line(colour = "#756bb1", linewidth = 0.5) +
  geom_hline(aes(yintercept = 45), color = "#000000", linewidth = 0.5, linetype = "dotted") +
  annotate(geom = "text", x = as.POSIXct(Sys.Date()-80), y = 47, 
           label = "WHO limit", fontface = "italic") +
  scale_x_datetime(expand = c(0,0), labels = date_format("%Y-%m"), date_breaks = "6 months") +
  scale_y_continuous(expand = c(0,0), limits = c(0,60), position = "right") +
  labs(x = NULL, y = expression(paste(mu, "g/",m^3)),
       title = "Daily mean concentration of PM<sub>10</sub>",
       subtitle = paste0("<span style = 'color:#757575;'>Trafford A56, 2020-2023</span>"),
       caption = "Source: Air Quality England") +
  coord_cartesian(clip = "off") +
  theme_minimal(base_size = 12) +
  theme(text = element_text(family = "Lato"),
        plot.margin = unit(rep(1.5,4), "cm"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(colour = "#bdbdbd"),
        plot.title.position = "plot",
        plot.title = element_markdown(family = "Merriweather", face = "bold", size = 18, margin = margin(b = 0)),
        plot.subtitle = element_markdown(margin = margin(b = 40)),
        plot.caption = element_text(colour = "grey60", margin = margin(t = 20, b = -10)),
        axis.title.y.right = element_text(size = 12, angle = 0, vjust = 1.1, margin = margin(r = 10)))

ggsave("plot.jpeg")


