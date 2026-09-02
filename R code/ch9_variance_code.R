library(gapminder)
library(ggplot2)
library(dplyr)

africa_2007 <- gapminder %>%
  filter(continent == "Africa", year == 2007)

mean_lifeExp <- mean(africa_2007$lifeExp)

x_range <- nrow(africa_2007)
y_range <- diff(range(africa_2007$lifeExp))
aspect <- x_range / y_range

highlight_countries <- "Rwanda" #c("Swaziland", "Kenya", "Libya", "Botswana")

africa_2007 <- africa_2007 %>%
  #arrange(lifeExp) %>%
  mutate(
    x         = row_number(),
    resid     = lifeExp - mean_lifeExp,
    size_x    = abs(resid) * aspect,
    highlight = country %in% highlight_countries
  )

# Build squares
squares <- africa_2007 %>%
  rowwise() %>%
  mutate(
    sq = list(data.frame(
      x_sq = c(x, x + size_x, x + size_x, x),
      y    = c(lifeExp, lifeExp, mean_lifeExp, mean_lifeExp)
    ))
  ) %>%
  tidyr::unnest(sq)


squares_grey   <- squares %>% filter(!highlight)
squares_orange <- squares %>% filter(highlight)

labels <- africa_2007 %>%
  filter(highlight) %>%
  mutate(label_x = x + size_x + 0.3)

plot <- ggplot(africa_2007, aes(x = x, y = lifeExp)) +
  geom_polygon(data = squares_grey,
               aes(x = x_sq, y = y, group = x),
               fill = "grey80", alpha = 0.5,
               colour = "grey60", linewidth = 0.2) +
  geom_polygon(data = squares_orange,
               aes(x = x_sq, y = y, group = x),
               fill = "#F37021", alpha = 0.5,
               colour = "#F37021", linewidth = 0.3) +
  geom_hline(yintercept = mean_lifeExp,
             colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 2) +
  geom_point(data = africa_2007 %>% filter(highlight),
             colour = "#F37021", size = 3) +
  geom_label(data = labels,
             aes(x = label_x, y = lifeExp, label = country),
             hjust = 0, size = 3, fill = "white",
             colour = "#F37021", label.size = 0.2) +
  coord_fixed(ratio = aspect) +
  # labs(
  #   title    = "Variance as the average squared distance from the mean",
  #   subtitle = "Each square's area is the squared distance from that country's life expectancy to the mean",
  #   x        = "Country (ordered by life expectancy)",
  #   y        = "Life expectancy (years)"
  # ) +
  theme_bw() +
  theme(
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank()
  )


#plotly::ggplotly(plot)



# for 1952 ========================================

library(gapminder)
library(ggplot2)
library(dplyr)

africa_2007 <- gapminder %>%
  filter(continent == "Africa", year == 1952)

mean_lifeExp <- mean(africa_2007$lifeExp)

x_range <- nrow(africa_2007)
y_range <- diff(range(africa_2007$lifeExp))
aspect <- x_range / y_range

#highlight_countries <- c("Swaziland", "Kenya", "Libya", "Benin")

africa_2007 <- africa_2007 %>%
  #arrange(lifeExp) %>%
  mutate(
    x         = row_number(),
    resid     = lifeExp - mean_lifeExp,
    size_x    = abs(resid) * aspect,
    highlight = country %in% highlight_countries
  )

# Build squares
squares <- africa_2007 %>%
  rowwise() %>%
  mutate(
    sq = list(data.frame(
      x_sq = c(x, x + size_x, x + size_x, x),
      y    = c(lifeExp, lifeExp, mean_lifeExp, mean_lifeExp)
    ))
  ) %>%
  tidyr::unnest(sq)


squares_grey   <- squares %>% filter(!highlight)
squares_orange <- squares %>% filter(highlight)

labels <- africa_2007 %>%
  filter(highlight) %>%
  mutate(label_x = x + size_x + 0.3)

plot2 <- ggplot(africa_2007, aes(x = x, y = lifeExp)) +
  geom_polygon(data = squares_grey,
               aes(x = x_sq, y = y, group = x),
               fill = "grey80", alpha = 0.5,
               colour = "grey60", linewidth = 0.2) +
  geom_polygon(data = squares_orange,
               aes(x = x_sq, y = y, group = x),
               fill = "#F37021", alpha = 0.5,
               colour = "#F37021", linewidth = 0.3) +
  geom_hline(yintercept = mean_lifeExp,
             colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 2) +
  geom_point(data = africa_2007 %>% filter(highlight),
             colour = "#F37021", size = 3) +
  geom_label(data = labels,
             aes(x = label_x, y = lifeExp, label = country),
             hjust = 0, size = 3, fill = "white",
             colour = "#F37021", label.size = 0.2) +
  coord_fixed(ratio = aspect) +
  theme_bw() +
  theme(
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank()
  )


#plotly::ggplotly(plot)

plot <- plot +
  ylim(28, 80) +
  labs(
    x        = NULL,
    y        = NULL,
    subtitle = "2007"
  )

plot2 <- plot2 +
  ylim(28, 80) +
  labs(
    x        = NULL,
    y        = NULL,
    subtitle = "1952"
  )


plot2 + plot +
  plot_annotation(
  title    = "Variance as the average squared distance from the mean",
  subtitle = "Each square's area is the squared distance from that country's life expectancy to the mean"
  #x        = "Country (ordered by life expectancy)",
  #y        = "Life expectancy (years)"
)



mean_1992 <- mean(gapminder %>% filter(continent == "Africa") %>% filter(year == 1992) %>% pull(lifeExp))
x <- gapminder %>% 
  filter(continent == "Africa") %>%
  filter(year %in% c(1952, 1992, 2007)) %>%
  dplyr::select(country, year, lifeExp) %>%
  pivot_wider(names_from = year, values_from = lifeExp) %>%
  mutate(diff = `2007` - `1952`) %>%
  mutate(var = (mean_1992 - `1992`)^2)

sum(x$var)/52
sum(x$var)/51

var(gapminder %>% filter(continent == "Africa") %>% filter(year == 1992) %>% pull(lifeExp))

gapminder %>%
  filter(continent == "Africa") %>%
  group_by(year) %>%
  summarise(var(lifeExp))




africa_2007 <- gapminder %>%
  filter(continent == "Africa", year == 1992)

mean_lifeExp <- mean(africa_2007$lifeExp)

x_range <- nrow(africa_2007)
y_range <- diff(range(africa_2007$lifeExp))
aspect <- x_range / y_range

#highlight_countries <- c("Swaziland", "Kenya", "Libya", "Benin")

africa_2007 <- africa_2007 %>%
  #arrange(lifeExp) %>%
  mutate(
    x         = row_number(),
    resid     = lifeExp - mean_lifeExp,
    size_x    = abs(resid) * aspect,
    highlight = country %in% highlight_countries
  )

# Build squares
squares <- africa_2007 %>%
  rowwise() %>%
  mutate(
    sq = list(data.frame(
      x_sq = c(x, x + size_x, x + size_x, x),
      y    = c(lifeExp, lifeExp, mean_lifeExp, mean_lifeExp)
    ))
  ) %>%
  tidyr::unnest(sq)


squares_grey   <- squares %>% filter(!highlight)
squares_orange <- squares %>% filter(highlight)

labels <- africa_2007 %>%
  filter(highlight) %>%
  mutate(label_x = x + size_x + 0.3)

plot3 <- ggplot(africa_2007, aes(x = x, y = lifeExp)) +
  geom_polygon(data = squares_grey,
               aes(x = x_sq, y = y, group = x),
               fill = "grey80", alpha = 0.5,
               colour = "grey60", linewidth = 0.2) +
  geom_polygon(data = squares_orange,
               aes(x = x_sq, y = y, group = x),
               fill = "#F37021", alpha = 0.5,
               colour = "#F37021", linewidth = 0.3) +
  geom_hline(yintercept = mean_lifeExp,
             colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 2) +
  geom_point(data = africa_2007 %>% filter(highlight),
             colour = "#F37021", size = 3) +
  geom_label(data = labels,
             aes(x = label_x, y = lifeExp, label = country),
             hjust = 0, size = 3, fill = "white",
             colour = "#F37021", label.size = 0.2) +
  coord_fixed(ratio = aspect) +
  theme_bw() +
  theme(
    axis.text.x  = element_blank(),
    axis.ticks.x = element_blank()
  )


#plotly::ggplotly(plot)

plot <- plot +
  ylim(20, 80) +
  labs(
    x        = NULL,
    y        = NULL,
    subtitle = "2007"
  )

plot2 <- plot2 +
  ylim(20, 80) +
  labs(
    x        = NULL,
    y        = NULL,
    subtitle = "1952"
  )

plot3 <- plot3 +
  ylim(20, 80) +
  labs(
    x        = NULL,
    y        = NULL,
    subtitle = "1992"
  )



plot2 + plot3 + plot +
  plot_annotation(
    title    = "Variance as the average squared distance from the mean",
    subtitle = "Each square's area is the squared distance from that country's life expectancy to the mean"
    #x        = "Country (ordered by life expectancy)",
    #y        = "Life expectancy (years)"
  )
