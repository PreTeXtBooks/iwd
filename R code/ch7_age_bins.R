# Chapter 7: how the number of groups changes the story (simulated ages)
library(dplyr)
library(ggplot2)
library(jsonlite)

# 1. Simulate ages of 600 clinic visitors -----------------------------------
set.seed(2024)
n <- 600
type <- sample(c("young child", "adult", "older adult", "other"), n,
               replace = TRUE, prob = c(0.22, 0.38, 0.20, 0.20))

age <- case_when(
  type == "young child" ~ runif(n, 0, 5),
  type == "adult"       ~ rnorm(n, 28, 6),
  type == "older adult" ~ rnorm(n, 66, 6),
  TRUE                  ~ runif(n, 5, 80)
)
clinic_visits <- tibble(age = floor(pmin(pmax(age, 0), 89.99)))

# 2. The same numbers, cut into different numbers of groups -----------------
cut_ages <- function(k) {
  cut(clinic_visits$age, breaks = seq(0, 90, length.out = k + 1),
      include.lowest = TRUE, right = FALSE)
}
for (k in c(2, 3, 6, 9, 18, 90)) {
  cat("k =", k, ":", as.vector(table(cut_ages(k))), "\n")
}

# 3. Static figure ----------------------------------------------------------
panels <- c(2, 6, 9, 90)
plot_data <- bind_rows(lapply(panels, function(k) {
  width <- 90 / k
  tibble(group = as.integer(cut_ages(k))) %>%
    count(group) %>%
    mutate(k = k, lo = (group - 1) * width, hi = group * width)
})) %>%
  mutate(panel = factor(k, levels = panels,
                        labels = paste(panels, "groups")))

ggplot(plot_data, aes(xmin = lo, xmax = hi, ymin = 0, ymax = n)) +
  geom_rect(fill = "#F37021", colour = "white", linewidth = 0.3) +
  facet_wrap(~ panel, scales = "free_y") +
  labs(x = "Age (years)", y = "Number of visitors") +
  theme_bw()

ggsave("pretext/assets/images/ch7_age_bins.png", width = 9, height = 5, dpi = 150)

# 4. Export the ages for the interactive page -------------------------------
cat(toJSON(clinic_visits$age), "\n", file = "ages_sim.json")
