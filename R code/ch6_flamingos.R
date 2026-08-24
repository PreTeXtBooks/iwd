# 1. Wide to Long to Wide to Long to Wide to Long to...
flamingos <- read.csv("C:/Users/lclem/Downloads/kenya_flamingos.csv")
View(kenya_flamingos)

library(dplyr)
library(tidyr)

counts_long <- flamingos %>%
  count(lake, species)

head(counts_long)

#>          lake          species  n
#> 1     Bogoria Greater Flamingo 10
#> 2     Bogoria  Lesser Flamingo 114
#> 3 Elementaita Greater Flamingo 30
#> 4 Elementaita  Lesser Flamingo 38
#> 5      Nakuru Greater Flamingo 26
#> 6      Nakuru  Lesser Flamingo 126

counts_wide <- counts_long %>%
  pivot_wider(names_from = species, values_from = n)

counts_wide

#>          lake Greater Flamingo Lesser Flamingo
#> 1     Bogoria               10             114
#> 2 Elementaita               30              38
#> 3      Nakuru               26             126


counts_long <- counts_wide %>%
  pivot_longer(cols = -lake, names_to = "species", values_to = "n")
counts_long

ggplot(counts_long, aes(x = lake, y = n, fill = species)) + 
  geom_bar(stat = "identity") +
  labs(x = "Lake", y = "Count", fill = "Species")
