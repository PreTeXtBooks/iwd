# No variability
height <- seq(150, 195, by = 5)
weight <- rep(65, 10)

df0 <- data.frame(height, weight)

ggplot(df0, aes(x = height, y = weight)) +
  geom_point(size = 2.5) +
  geom_line() +
  coord_cartesian(ylim = c(40, 110)) +
  labs(
    title = "No variability",
    subtitle = "Everyone weighs 65 kg",
    x = "Height (cm)",
    y = "Weight (kg)"
  ) +
  theme_bw()

# Accounted for variability

height <- seq(150, 195, by = 5)
weight <- 65 + 0.8 * (height - 170)

df1 <- data.frame(height, weight)

ggplot(df1, aes(x = height, y = weight)) +
  geom_point(size = 2.5) +
  geom_line() +
  coord_cartesian(ylim = c(40, 110)) +
  labs(
    title = "Accounted-for variability only",
    subtitle = "Weight is completely determined by height",
    x = "Height (cm)",
    y = "Weight (kg)"
  ) +
  theme_bw()
