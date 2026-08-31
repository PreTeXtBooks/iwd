library(gapminder)
library(ggplot2)
library(dplyr)
library(gganimate)
library(tidyr)

kenya <- gapminder %>%
  dplyr::filter(country == "Kenya")

x_range <- diff(range(kenya$year))
y_range <- diff(range(kenya$pop))
aspect_correction <- x_range / y_range

# Best fit coefficients
model_good <- lm(pop ~ year, data = kenya)
intercept_best <- coef(model_good)[1]
slope_best     <- coef(model_good)[2]

# Flat line coefficients
intercept_flat <- mean(kenya$pop)
slope_flat     <- 0

# Number of animation frames
n_frames <- 40

# Interpolate between flat line and best fit line
frames <- tibble(
  frame     = 1:n_frames,
  intercept = seq(intercept_flat, intercept_best, length.out = n_frames),
  slope     = seq(slope_flat,     slope_best,     length.out = n_frames)
)

# For each frame, compute predicted values and residuals for each country
animated_data <- frames %>%
  rowwise() %>%
  mutate(
    points = list(
      kenya %>%
        mutate(
          predicted = intercept + slope * year,
          residual  = pop - predicted,
          size_x    = abs(residual) * aspect_correction
        )
    )
  ) %>%
  unnest(points)

# Build squares for each frame
squares_animated <- animated_data %>%
  rowwise() %>%
  mutate(
    sq = list(data.frame(
      x = c(year, year + size_x, year + size_x, year),
      y = c(pop, pop, predicted, predicted)
    ))
  ) %>%
  unnest(sq)

# Also compute the total sum of squares per frame for subtitle
sse_by_frame <- animated_data %>%
  group_by(frame, intercept, slope) %>%
  summarise(sse = sum(residual^2), .groups = "drop")

squares_animated <- squares_animated %>%
  left_join(sse_by_frame, by = "frame")

# Build line data for each frame
line_data <- frames %>%
  mutate(
    x1 = min(kenya$year),
    x2 = max(kenya$year),
    y1 = intercept + slope * x1,
    y2 = intercept + slope * x2
  )

# Add SSE directly to animated_data so it travels with the squares
animated_data <- animated_data %>%
  group_by(frame) %>%
  mutate(sse = sum(residual^2)) %>%
  ungroup()

# Rebuild squares with SSE attached
squares_animated <- animated_data %>%
  rowwise() %>%
  mutate(
    sq = list(data.frame(
      x = c(year, year + size_x, year + size_x, year),
      y = c(pop, pop, predicted, predicted)
    ))
  ) %>%
  unnest(sq)

# Now use closest_state in the subtitle instead of indexing
# Make sure line_data has the sse attached so it transitions with the same variable
line_data <- frames %>%
  mutate(
    x1  = min(kenya$year),
    x2  = max(kenya$year),
    y1  = intercept + slope * x1,
    y2  = intercept + slope * x2,
    sse = map2_dbl(intercept, slope, ~sum((kenya$pop - (.x + .y * kenya$year))^2))
  )

p_anim <- ggplot(kenya, aes(x = year, y = pop)) +
  geom_polygon(data = squares_animated,
               aes(x = x, y = y,
                   group = year,
                   fill  = sse),
               alpha = 0.5, colour = "#F37021", linewidth = 0.3) +
  scale_fill_gradient(low = "#F37021", high = "#F37021",
                      guide = "none") +
  geom_segment(data = line_data,
               aes(x = x1, xend = x2,
                   y = y1,  yend = y2,
                   group = frame),
               colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 3) +
  coord_fixed(ratio = aspect_correction) +
  labs(
    title    = "Finding the line of best fit",
    subtitle = "Total squared error: {round(filter(line_data, frame == as.integer(closest_state))$sse, 1)}",
    x        = "Year",
    y        = "Population"
  ) +
  theme_bw() +
  transition_states(frame,
                    transition_length = 2,
                    state_length      = 0) +
  ease_aes("cubic-in-out")

animate(p_anim,
        nframes   = n_frames * 4,
        fps       = 20,
        width     = 800,
        height    = 500,
        renderer  = gifski_renderer("ch9_least_squares.gif"))
