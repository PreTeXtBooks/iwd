library(tidyverse)

# Load the Berkeley admissions data
berkeley <- read.csv("C:/Users/lclem/Downloads/berkeley.csv")
berkeley$Admission <- factor(berkeley$Admission)

berkeley <- berkeley %>%
  mutate(Admission = forcats::fct_relevel(Admission, "Rejected", "Accepted"))

# Male applicants: 8,442 total — 44% Accepted
# Female applicants: 4,321 total — 35% Accepted

# Calculate totals and admission rates
plot_data <- berkeley %>%
  group_by(Sex, Admission) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Sex) %>%
  mutate(
    total = sum(n),
    rate = n[Admission == "Accepted"] / total,
    percentage = scales::percent(rate, accuracy = 0.1)
  ) %>%
  ungroup()

plot_data

ggplot(plot_data, aes(x = Sex, y = n)) +
  # Bars
  geom_col(
    aes(fill = Admission),
    width = 0.65
  ) +
  
  # Number Accepted
  geom_text(
    data = plot_data %>% filter(Admission == "Accepted"),
    aes(label = paste0(
      scales::comma(n),
      " Accepted"
    )),
    colour = "white",
    fontface = "bold",
    size = 6,
    lineheight = 0.9,
    vjust = 2
  ) +
  
  # Percentage labels
  geom_label(
    data = plot_data %>% filter(Admission == "Accepted"),
    aes(
      label = percentage,
      y = n / 2
    ),
    colour = "#8B0000",
    fill = "white",
    fontface = "bold",
    size = 6,
    label.padding = unit(0.3, "lines"),
    vjust = 1
  ) +
  
  # Total applicants above each bar
  geom_text(
    data = plot_data %>%
      group_by(Sex) %>%
      summarise(total = first(total)),
    aes(
      y = total,
      label = paste0(
        scales::comma(total),
        "\nTotal applicants"
      )
    ),
    vjust = -0.25,
    fontface = "bold",
    size = 5
  ) +
  
  scale_fill_manual(
    values = c(
      "Accepted" = "#8B0000",
      "Rejected" = "#ffdcdc"
    )
  ) +
  
  scale_y_continuous(
    limits = c(0, 9000),
    breaks = seq(0, 9000, 1500),
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  
  scale_x_discrete(labels = c("Female", "Male")) +
  
  labs(
    title = "Berkeley Graduate Admissions (1973)",
    subtitle = "Overall admission rates hide the full story",
    x = NULL,
    y = "Number of applicants",
    fill = NULL
  ) +
  
  theme_minimal(base_size = 16) +
  
  theme(
    plot.title = element_text(
      size = 28,
      face = "bold",
      hjust = 0.5
    ),
    plot.subtitle = element_text(
      size = 18,
      hjust = 0.5,
      colour = "grey30",
      margin = margin(b = 25)
    ),
    axis.title.y = element_text(
      face = "bold",
      margin = margin(r = 10)
    ),
    axis.text.x = element_text(
      size = 20,
      face = "bold"
    ),
    axis.text.y = element_text(size = 13),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 30, 20, 20)
  )


# By Department
plot_data <- berkeley %>%
  group_by(Sex, Admission, Major) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Sex, Major) %>%
  mutate(
    total = sum(n),
    rate = n[Admission == "Accepted"] / total,
    percentage = scales::percent(rate, accuracy = 0.1)
  ) %>%
  ungroup()

plot_data

ggplot(plot_data, aes(x = Sex, y = n)) +
  # Bars
  geom_col(
    aes(fill = Admission),
    width = 0.65
  ) +
  
  # Percentage labels
  geom_label(
    data = plot_data %>% filter(Admission == "Accepted"),
    aes(
      label = percentage,
      y = n / 2
    ),
    colour = "#8B0000",
    fill = "white",
    fontface = "bold",
    size = 6,
    vjust = -2
    #label.padding = unit(0.3, "lines")
  ) +
  
  scale_fill_manual(
    values = c(
      "Accepted" = "#8B0000",
      "Rejected" = "#ffdcdc"
    )
  ) +
  
  scale_y_continuous(
    #limits = c(0, 9000),
    #breaks = seq(0, 9000, 1500),
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  
  scale_x_discrete(labels = c("Female", "Male")) +
  
  labs(
    title = "The numbers weren't telling the whole story",
    subtitle = "Breaking the data down by department reveals a very different pattern of admissions.",
    x = NULL,
    y = "Number of applicants",
    fill = NULL
  ) +
  
  theme_minimal(base_size = 16) +
  
  theme(
    plot.title = element_text(
      size = 28,
      face = "bold",
      hjust = 0.5
    ),
    plot.subtitle = element_text(
      size = 18,
      hjust = 0.5,
      colour = "grey30",
      margin = margin(b = 25)
    ),
    axis.title.y = element_text(
      face = "bold",
      margin = margin(r = 10)
    ),
    axis.text.x = element_text(
      size = 20,
      face = "bold"
    ),
    axis.text.y = element_text(size = 13),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 30, 20, 20)
  ) +
  facet_wrap(vars(Major), scales = "free")

