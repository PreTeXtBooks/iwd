# Figure for the Chapter 6 malaria T3 example.
# Data: Table 1 of Mbuli et al. (2016), East African Medical Journal 93(10),
# Supplement. Outpatient malaria cases reported in Kenya's government health
# facilities, from DHIS2.
library(dplyr)
library(tidyr)
library(ggplot2)

malaria_t3 <- tribble(
  ~year, ~all_malaria, ~confirmed,
  2012,  8474945,      1969868,
  2013,  7871171,      3185007,
  2014,  8774354,      4091494,
  2015,  6852506,      4922574
)

orange <- "#F37021"
teal <- "#44575E"

malaria_t3 %>%
  select(year, `All malaria cases` = all_malaria,
         `Confirmed cases` = confirmed) %>%
  pivot_longer(-year, names_to = "series", values_to = "cases") %>%
  ggplot(aes(x = year, y = cases / 1e6, colour = series)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_colour_manual(values = c("All malaria cases" = teal,
                                 "Confirmed cases" = orange)) +
  scale_x_continuous(breaks = 2012:2015) +
  scale_y_continuous(limits = c(0, 10)) +
  labs(x = "Year", y = "Outpatient cases (millions)", colour = NULL) +
  theme_bw() +
  theme(legend.position = "top")

ggsave("pretext/assets/images/ch6_malaria_t3.png",
       width = 7, height = 4, dpi = 200)
