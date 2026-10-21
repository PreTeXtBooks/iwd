# Figures for the Chapter 8 practice section (africa_indicators).
library(statsdata)
library(dplyr)
library(ggplot2)
library(naniar)

out <- "pretext/assets/images"
orange <- "#F37021"
teal <- "#44575E"

data(africa_indicators)

# Missingness heatmap: every row is one country-year
p1 <- vis_miss(africa_indicators) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0),
        plot.margin = margin(t = 10, r = 80, b = 5, l = 5))
ggsave(file.path(out, "ch-missing-vis-miss.png"), p1,
       width = 8, height = 5, dpi = 200)

# Number of missing values per variable
p2 <- gg_miss_var(africa_indicators) + theme_bw()
ggsave(file.path(out, "ch-missing-gg-miss-var.png"), p2,
       width = 7, height = 4, dpi = 200)

# Share of primary enrolment values missing, by year
p3 <- africa_indicators %>%
  group_by(year) %>%
  summarise(pct_missing = mean(is.na(primary_enrolment)) * 100) %>%
  ggplot(aes(x = year, y = pct_missing)) +
  geom_col(fill = orange) +
  scale_x_continuous(breaks = 2010:2023) +
  labs(x = "Year", y = "Countries with no value (%)",
       title = "Primary school enrolment: how many countries are missing?") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(out, "ch-missing-enrolment-year.png"), p3,
       width = 7, height = 4, dpi = 200)
