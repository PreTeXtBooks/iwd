# Measuring Variability in R
# Measuring variability within different groups is a common task in data analysis.
# In this document, we illustrate some approaches to measuring variability in R using
# group-wise analysis. The group_by function in the dplyr package can be particularly
# useful for this purpose.

# 1. The packages and data
# Install and load necessary packages
# install.packages(c("tidyverse"))
# Load the installed packages
library(tidyverse)
library(gapminder)

# we use some data here
# you can pick whichever continent of your choice. We will pick Africa for this tutorial
africa <- gapminder %>% filter(continent == "Africa")

# A snippet of our sample data.
# We can look at the overall summaries in the data using the summary() function.

head(africa)

# country continent  year lifeExp      pop gdpPercap
# <fct>   <fct>     <int>   <dbl>    <int>     <dbl>
#   1 Algeria Africa     1952    43.1  9279525     2449.
# 2 Algeria Africa     1957    45.7 10270856     3014.
# 3 Algeria Africa     1962    48.3 11000948     2551.
# 4 Algeria Africa     1967    51.4 12760499     3247.
# 5 Algeria Africa     1972    54.5 14760787     4183.
# 6 Algeria Africa     1977    58.0 17152804     4910.
# explain this through

# Display a summary of the data
summary(africa$lifeExp)

# TODO: briefly explain them all. 
# country       continent        year         lifeExp           pop              gdpPercap      
# Algeria     : 12   Africa  :624   Min.   :1952   Min.   :23.60   Min.   :    60011   Min.   :  241.2  
# Angola      : 12   Americas:  0   1st Qu.:1966   1st Qu.:42.37   1st Qu.:  1342075   1st Qu.:  761.2  
# Benin       : 12   Asia    :  0   Median :1980   Median :47.79   Median :  4579311   Median : 1192.1  
# Botswana    : 12   Europe  :  0   Mean   :1980   Mean   :48.87   Mean   :  9916003   Mean   : 2193.8  
# Burkina Faso: 12   Oceania :  0   3rd Qu.:1993   3rd Qu.:54.41   3rd Qu.: 10801490   3rd Qu.: 2377.4  
# Burundi     : 12                  Max.   :2007   Max.   :76.44   Max.   :135031164   Max.   :21951.2  
# (Other)     :552        
# then 

# 1. Variance and Standard Deviation (SD)
#' Variance is a measure of statistical dispersion or variability, providing insights into
#' how spread out a set of values is from the mean (average).
#' ● Larger variance values indicate greater variability in the data
#' 
#' Variance is the average of the squared differences from the mean.
#' It quantifies the extent to which each data point in a dataset deviates from the mean.
#' 
#' TODO: give an illustration explaining this
#' 
#' Pros:
#' The variance is sensitive to outliers.
#' Extreme values can significantly impact its value.
#' It takes all data into account
#' 
#' Cons:
#' It’s sensitive to outliers, so extreme values
#' can disproportionately impact it
#' It is not expressed in the same units as the
#' original data, making it less intuitive.
#' 
#' Standard deviation is the square root of the variance.
#' ● Like variance, standard deviation is also a measure of statistical dispersion or
#' variability, providing insights into how spread out a set of values is from the mean.
#' ● Larger values indicate greater variability in the data.
#' Pros:
#' It is sensitive to the extreme values so can capture the influence of outliers. It takes all data into account.
#' It is a more interpretable than variance, as it is expressed in the same units as the original data.
#' 
#' Cons:
#' It’s sensitive to outliers, so extreme values can disproportionately impact it.

# Calculate the Variance and SD for each group
africa %>%
  group_by(year) %>%
  summarise(SD = sd(lifeExp),
            variance = var(lifeExp))

# # A tibble: 12 × 3
# year    SD variance
# <int> <dbl>    <dbl>
#   1  1952  5.15     26.5
# 2  1957  5.62     31.6
# 3  1962  5.88     34.5
# 4  1967  6.08     37.0
# 5  1972  6.42     41.2
# 6  1977  6.81     46.4
# 7  1982  7.38     54.4
# 8  1987  7.86     61.8
# 9  1992  9.46     89.5
# 10  1997  9.10     82.9
# 11  2002  9.59     91.9
# 12  2007  9.63     92.8

# Interpret this!
# sd genraelly increases as year increases
# put into context. What does htis mean? 

# 2. Coefficient of Variation (CV)
#' The CV is the ratio of the standard deviation to the mean, expressed as a percentage.
#' This provides a standardised measure of variability, allowing you to compare the relative spread of different datasets regardless of their scales.
#'  A lower CV suggests less relative variability, while a higher CV indicates greater relative variability in the dataset.
#'  
#' If the mean of a dataset is 10 and the standard deviation is 2, the CV would be 20%.
#' This means that, on average, each data point is expected to deviate from the mean
#' by approximately 20%.
#' 
#' Pros:
#' As a percentage, it is easy to compare the relative variability of different datasets, even if they have different units or scales.
#' Cons:
#' CV assumes a symmetric distribution so should not be used with unsymmetric data.
#' For datasets with very small means, small changes can result in relatively large CV values, potentially magnifying the variability.
#' 
#' You can get the CV in R by sd(Value)/mean(Value) * 100.
# Calculate the CV for each group
africa %>%
  group_by(year) %>%
  summarise(CV = sd(lifeExp) / mean(lifeExp) * 100)

# # A tibble: 12 × 2
# year    CV
# <int> <dbl>
#   1  1952  13.2
# 2  1957  13.6
# 3  1962  13.6
# 4  1967  13.4
# 5  1972  13.5
# 6  1977  13.7
# 7  1982  14.3
# 8  1987  14.7
# 9  1992  17.6
# 10  1997  17.0
# 11  2002  18.0
# 12  2007  17.6

#' TODO: INTERPRET

# 3. Boxplots to Visualise Variability
# But, these are "point" statistics. [explain what we mean by that]
# A great way to visaulise variability is with a boxplot

# # TODO: don't give them this code, it is too confusing
africa_2007 <- gapminder %>%
  filter(year == 2007)

# Calculate the five-number summary
# Calculate the five-number summary
stats <- africa_2007 %>%
  summarise(
    min    = min(lifeExp),
    q1     = quantile(lifeExp, 0.25),
    median = median(lifeExp),
    q3     = quantile(lifeExp, 0.75),
    max    = max(lifeExp)
  )

# Find the outlier country (lowest life expectancy)
min_country <- africa_2007 %>%
  filter(lifeExp == min(lifeExp)) %>%
  pull(country)

# Labels for the five-number summary
labels_df <- data.frame(
  y     = c(stats$min, stats$q1, stats$median, stats$q3, stats$max),
  label = c(
    paste0("Min: ",    round(stats$min,    1)),
    paste0("Q1: ",     round(stats$q1,     1)),
    paste0("Median: ", round(stats$median, 1)),
    paste0("Q3: ",     round(stats$q3,     1)),
    paste0("Max: ",    round(stats$max,    1))
  ),
  # x position of label
  x_label = 0.55,
  # x position of arrow tip (edge of box)
  x_arrow = 0.21
)

ggplot(africa_2007, aes(y = lifeExp)) +
  geom_boxplot(width = 0.4, fill = "#F37021", colour = "#44575E",
               outlier.colour = "#F37021", outlier.size = 2, coef = 0.8) +
  # Arrows from label to box
  geom_segment(data = labels_df,
               aes(x = x_label - 0.02, xend = x_arrow,
                   y = y, yend = y),
               arrow = arrow(length = unit(0.2, "cm"), type = "closed"),
               colour = "grey40", linewidth = 0.4) +
  # Labels
  geom_label(data = labels_df,
             aes(x = x_label, y = y, label = label),
             hjust = 0, size = 3.2, fill = "white",
             colour = "black", label.size = 0.3) +
  scale_x_continuous(limits = c(-0.6, 1.2)) +
  labs(
    title    = "Life expectancy across African countries, 2007",
    subtitle = "Each point represents one country.",
    y        = "Life expectancy (years)",
    x        = NULL
  ) +
  theme_bw() +
  theme(
    axis.text.x        = element_blank(),
    axis.ticks.x       = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

# Explain the boxplot: Max, Min, Quartiles, Median, etc.
# max - 82.6; q3 - 76.4; median 71.0, q1 - 57.2, min = 39.6
# dot at bottom = outlier
#' "The country at the minimum in 2007 is Swaziland (now Eswatini) at around 39 years,
#' driven almost entirely by the HIV/AIDS epidemic. That is worth naming — it is a real cause,
#' not a data error — but the framing matters.
africa_2007 %>% arrange(lifeExp)

africa_2007 %>% filter(continent == "Africa") %>% arrange(desc(lifeExp))

#' Boxplots provide a visual representation of the distribution of data, including the
#' median, quartiles, and potential outliers.
#' there are also measures of variability in there too, such as the IQR, which is the Q3 - Q1 (here, 76.4-57.2 = ...),
#' and the range, which is the max - min = 82.6 -  39.6 = ...
#' 
# Get a boxplot of the data of the different continents in 2007
lifeexp_2007 <- gapminder %>% filter(year == 2007)

ggplot(lifeexp_2007, aes(y = lifeExp, x = continent)) +
  geom_boxplot(width = 0.4, fill = "#F37021", colour = "#44575E",
               outlier.colour = "#F37021", outlier.size = 2) +
  labs(
    title    = "Life expectancy across different continents in 2007",
    subtitle = "Each point represents one country.",
    y        = "Life expectancy (years)",
    x        = "Continent"
  ) +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

#' We can see that the minimum - lowest in africa.
#' we can see the data is most spread out in africa too, with the exception of asia due to an outlier 
#' (what is that outlier?)
lifeexp_2007 %>% filter(continent == "Asia") %>% arrange(lifeExp)
# it's Afghanistan, and there is a war on in 2007 (right???)
#'
#' some big low ones
#' 


# RANGE:

# 3a. Can measure Variability with the Range
#' The range is the difference between the maximum and minimum value.
#' ● The range provides an indication of how spread out the values in a dataset are.
#' ● Larger ranges indicate greater variability in the data
#' It is a simple and straightforward way to quantify the spread or variability of a set of
#' observations. 
#' However, it is sensitive to extreme values or outliers because it directly
#' involves the maximum and minimum values. Larger ranges indicate greater
#' variability in the data.
#' Pros: It is a simple and straightforward way to quantify the spread or variability of a set of observations.
#' Cons: It is sensitive to extreme values or outliers because it directly involves the maximum and minimum values.
#' 
#' This can be calculated in R using the functions min()and max().
# Calculate the range for each of our year points (1952 to 2007, in 5 year blocks)
# get the country with the smallest life expectancy, and the largest, and find the range. 
africa %>%
  group_by(year) %>%
  summarise(min = min(lifeExp),
            max = max(lifeExp),
            range = max - min)

# GIVE OUTPUT
# A tibble: 12 × 4
# year   min   max range
# <int> <dbl> <dbl> <dbl>
#   1  1952  30    52.7  22.7
# 2  1957  31.6  58.1  26.5
# 3  1962  32.8  60.2  27.5
# 4  1967  34.1  61.6  27.4
# 5  1972  35.4  64.3  28.9
# 6  1977  36.8  67.1  30.3
# 7  1982  38.4  69.9  31.4
# 8  1987  39.9  71.9  32.0
# 9  1992  23.6  73.6  50.0
# 10  1997  36.1  74.8  38.7
# 11  2002  39.2  75.7  36.6
# 12  2007  39.6  76.4  36.8

# We can see from the output that the range of life expectancy initially increase as year increases.
# suggests some discrepancy right? like, okay, initially, african countries are not so varied
# but then they get more varied in life expectancy. Is that because some increase and others don't?
# we would want everyone to increase lifeexp. 
#
# actually, looking at minimums, we see that it tends to generally increase, except in 1992, where there is a big decrease
# we identified this before when visualising the data through ggplot2, and foudn thsi was rwanda and links to the rwandan genocide / political issues
# so, it's more that the range has a big leap there because of a big decrease in life expectancy in rwanda.
#
# other than 1992, the min age tends to increase, and the max age tends to increase as years go on. good!
# the range has some increase, suggesting more inequalities???? or something? like, idk. you know? please help.

# we can see the range with boxplots too
# the range is the whole length from top point to bottom point --> max to min.  
library(gapminder)
library(ggplot2)
library(dplyr)

kenya <- africa %>%
  filter(country == "Kenya")

ggplot(africa, aes(y = lifeExp, x = factor(year))) +
  geom_boxplot(width = 0.4, fill = "#F37021", colour = "#44575E",
               outlier.colour = "#F37021", outlier.size = 2) +
  # Kenya points
  geom_point(data = kenya,
             aes(y = lifeExp, x = factor(year)),
             colour = "#44575E", size = 3, shape = 18) +
  # Kenya line connecting the points
  geom_line(data = kenya,
            aes(y = lifeExp, x = as.numeric(factor(year))),
            colour = "#44575E", linewidth = 0.8) +
  # Label on the last point only
  geom_label(data = kenya %>% filter(year == max(year)),
             aes(y = lifeExp, x = factor(year), label = "Kenya"),
             hjust = -0.1, size = 3.2, fill = "white",
             colour = "#44575E", label.size = 0.3) +
  labs(
    title    = "Life expectancy across African countries",
    subtitle = "Each point represents one country. Kenya highlighted in dark teal.",
    y        = "Life expectancy (years)",
    x        = "Year"
  ) +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

# wow okay
# we can see the variability within a year, and then the variability across years, and how that changes
# TODO: interpret.
# TODO: metnion that rwanda outlier in 1992. 
# TODO: account for that variability within country
# TODO: account for that variability across years
# TODO: what might be natural variability? What might be unaccounted for variability? etc

# TODO: discuss that variability in Kenya
# it increases until 1992. And then there's a plummet. AIDS?

# add in population too!
ggplot(africa, aes(y = lifeExp, x = factor(year))) +
  geom_boxplot(width = 0.4, fill = "#F37021", colour = "#44575E",
               outlier.colour = "#F37021", outlier.size = 2, coef = 1.6) +
  # Kenya points
  geom_point(data = kenya,
             aes(y = lifeExp, x = factor(year)),
             colour = "#44575E", size = 3, shape = 18) +
  # Kenya line connecting the points
  geom_line(data = kenya,
            aes(y = lifeExp, x = as.numeric(factor(year))),
            colour = "#44575E", linewidth = 0.8) +
  # Label on the last point only
  geom_label(data = kenya %>% filter(year == max(year)),
             aes(y = lifeExp, x = factor(year), label = "Kenya"),
             hjust = -0.1, size = 3.2, fill = "white",
             colour = "#44575E", label.size = 0.3) +
  labs(
    title    = "Life expectancy across African countries",
    subtitle = "Each point represents one country. Kenya highlighted in dark teal.",
    y        = "Life expectancy (years)",
    x        = "Year"
  ) +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

# 3b Can measure Variability with the Interquartile Range (IQR)
# can see this in our boxplots too. 
#' The IQR is the range covered by the middle 50% of the data, calculated as the difference between the third quartile (Q3) and the first quartile (Q1).
#' 
#' Pros:
#' It is less sensitive to extreme values or outliers than the range or standard deviation. The IQR
#' is particularly useful when the dataset is not symmetrically distributed.
#' 
#' Cons:
#' The IQR ignores data points outside the IQR. This means that outliers or extreme values, which might be important in certain analyses, are excluded.
#' The IQR does not provide information about the symmetry or skewness of the distribution.
#' 
#' The function to get the IQR in R is IQR().
# Calculate the IQR for each group
africa %>%
  group_by(year) %>%
  summarise(IQR = IQR(lifeExp))
# OUTPUT

# # A tibble: 12 × 2
# year   IQR
# <int> <dbl>
#   1  1952  6.31
# 2  1957  7.42
# 3  1962  8.28
# 4  1967  8.16
# 5  1972  8.25
# 6  1977  9.36
# 7  1982 11.0 
# 8  1987 12.6 
# 9  1992 11.9 
# 10  1997 11.9 
# 11  2002 11.9 
# 12  2007 11.6 

# IQR increases. What does this mean? TODO: interpret. 


africa %>%
  group_by(year) %>%
  summarise(IQR = IQR(lifeExp))

#' Least Squares
#' 
#' Is it too weird that we suddenly go to population here? 
#' 
#' In simple terms, least squares is a method used to find the best-fitting line through a set of points on a graph
#' give illustration of this - or gif. 
#' 
#' Pros:
# It is robust and widely accepted in various
# applications.
# Least squares is a well-established and widely
# accepted method.
# It is easy computationally to calculate.
# Cons:
#   Least Squares is less appropriate if you have
# skewed or otherwise unsymmetric data.
# Least squares is sensitive to outliers. Outliers
# can disproportionately influence the line, leading to biases

# let's do year vs life expectancy for Kenya

# ok but no need to give code here, ok:
kenya <- gapminder %>% dplyr::filter(country == "Kenya")

# TODO: We are doing this for population instead of lifeExp though. Should we explain why?
# (I am doing this, because the lifeExp is more of a curve, so a straight line doesn't show it as nicely)
# Fit the linear model to get predicted values
model <- lm(pop ~ year, data = kenya)
kenya <- kenya %>%
  mutate(predicted = fitted(model),
         residual  = pop - predicted)

#' We have a bunch of data points
# scattered on a graph (right).
# ● Say you want to draw a straight line
# that comes as close as possible to all
# those points.
ggplot(kenya, aes(x = year, y = pop)) +
  # Arrows from observed point to fitted line
  geom_segment(aes(xend = year, yend = predicted),
               colour = "#F37021",
               arrow = arrow(length = unit(0.2, "cm"), type = "closed"),
               linewidth = 0.5) +
  # Line of best fit
  geom_smooth(method = "lm", se = FALSE, colour = "#44575E",
              linewidth = 1) +
  # Observed points on top
  geom_point(colour = "#44575E", size = 3) +
  labs(
    title    = "Population in Kenya, 1952–2007",
    subtitle = "Orange arrows show the distance from each observed value to the line of best fit",
    x        = "Year",
    y        = "Life expectancy (years)"
  ) +
  theme_bw()


# ● We can aim to make the squares of the
# vertical distances between the points
# and the line as small as possible.
# ● In other words, it minimises the errors
# between the actual data points and the
# points predicted by the line.
# ● Higher values suggest more variability in the data.

library(gapminder)
library(ggplot2)
library(dplyr)

kenya <- gapminder %>%
  dplyr::filter(country == "Kenya")

# Fit the linear model to get predicted values
model <- lm(pop ~ year, data = kenya)
kenya <- kenya %>%
  mutate(predicted = fitted(model),
         residual  = pop - predicted)

# Create square corners for each residual
# Each square has 4 corners: 
# (year, observed), (year + size, observed), 
# (year + size, predicted), (year, predicted)
# where size = abs(residual) scaled to look square on the plot

squares <- kenya %>%
  mutate(size = abs(residual)) %>%
  rowwise() %>%
  mutate(
    data = list(data.frame(
      x = c(year, year + size * 0.4, year + size * 0.4, year),
      y = c(pop, pop, predicted, predicted)
    ))
  ) %>%
  tidyr::unnest(data)

ggplot(kenya, aes(x = year, y = pop)) +
  # Squares showing squared residuals
  geom_polygon(data = squares,
               aes(x = x, y = y, group = interaction(year, predicted)),
               fill = "#F37021", alpha = 0.4, colour = "#F37021",
               linewidth = 0.3) +
  # Line of best fit
  geom_smooth(method = "lm", se = FALSE, colour = "#44575E",
              linewidth = 1) +
  # Observed points on top
  geom_point(colour = "#44575E", size = 3) +
  labs(
    title    = "Life expectancy in Kenya, 1952–2007",
    subtitle = "Orange squares show the squared distance from each observed value to the line of best fit",
    x        = "Year",
    y        = "Life expectancy (years)"
  ) +
  theme_bw()

# then next, 


kenya <- gapminder %>%
  dplyr::filter(country == "Kenya")

# Fit the linear model to get predicted values (good fit)
model_good <- lm(pop ~ year, data = kenya)

# Create a deliberately bad line - use a line with wrong slope/intercept
# e.g. a flat horizontal line at the mean, or a line with wrong slopelibrary(gapminder)
library(ggplot2)
library(dplyr)
library(patchwork)

kenya <- gapminder %>%
  dplyr::filter(country == "Kenya")

model_good <- lm(pop ~ year, data = kenya)
model_bad  <- lm(pop ~ 1,   data = kenya)

kenya_good <- kenya %>%
  mutate(predicted = fitted(model_good),
         residual  = pop - predicted)

kenya_bad <- kenya %>%
  mutate(predicted = fitted(model_bad),
         residual  = pop - predicted)

# x range and y range of the data
x_range <- diff(range(kenya$year))      # ~55 years
y_range <- diff(range(kenya$pop))   # ~18 years

# ratio: how many years = 1 year of life expectancy on screen
# we want the square side in x-units to equal the residual in y-units
# aspect correction: x_range / y_range gives the stretch factor
aspect_correction <- x_range / y_range  # ~3

make_squares <- function(df, aspect) {
  df %>%
    mutate(size_x = abs(residual) * aspect) %>%
    rowwise() %>%
    mutate(
      data = list(data.frame(
        x = c(year, year + size_x, year + size_x, year),
        y = c(pop, pop, predicted, predicted)
      ))
    ) %>%
    tidyr::unnest(data)
}

squares_good <- make_squares(kenya_good, aspect_correction)
squares_bad  <- make_squares(kenya_bad,  aspect_correction)

p_bad <- ggplot(kenya_bad, aes(x = year, y = pop)) +
  geom_polygon(data = squares_bad,
               aes(x = x, y = y, group = interaction(year, predicted)),
               fill = "#F37021", alpha = 0.4, colour = "#F37021",
               linewidth = 0.3) +
  geom_hline(yintercept = mean(kenya$pop),
             colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 3) +
  coord_fixed(ratio = aspect_correction) +
  labs(
    title    = "A worse line",
    subtitle = "Flat line at the mean: large squares",
    x        = "Year",
    y        = "Population"
  ) +
  theme_bw()

p_good <- ggplot(kenya_good, aes(x = year, y = pop)) +
  geom_polygon(data = squares_good,
               aes(x = x, y = y, group = interaction(year, predicted)),
               fill = "#F37021", alpha = 0.4, colour = "#F37021",
               linewidth = 0.3) +
  geom_smooth(method = "lm", se = FALSE,
              colour = "#44575E", linewidth = 1) +
  geom_point(colour = "#44575E", size = 3) +
  coord_fixed(ratio = aspect_correction) +
  labs(
    title    = "The line of best fit",
    subtitle = "Minimises the total area of the squares",
    x        = "Year",
    y        = "Population"
  ) +
  theme_bw()

p_bad + p_good

# In other words, it minimises the errors
# between the actual data points and the
# points predicted by the line.

# This method is commonly used when
# you're trying to understand or predict
# the relationship between two things.
# For example, you might use least
# squares to find the best line that
# represents how ... 
# The result is a line that fits the data in
# the most balanced way, reducing the
# overall error between the line and the
# actual data points.

# Why do we square it and not just find
# the distance?
#   ○ Least distance is a sensible
# measure, but doesn’t penalise
# extreme values.
# ○ In many applications, we want
# to give more weight to points
# that deviate significantly from
# the fitted line

# Least Squares may not be
# appropriate if you have skewed
# data. In one direction you might
# never get a big distance, and in
# another you could have a small
# distance.
# ● There are other measures of
# variability where the distance is
# measured differently.
# ○ You might do this, for example,
# if you have skewed data or
# binomial data. This is
# measuring variability.

# Least Squares is a method to measure variability
# ● It minimises the squares of vertical distances between the points and the line.
# ● It is robust and widely accepted in various applications.


#' Conclusion
#' These measures provide different perspectives on variability. Choose the one(s) that
#' best suit your data and the information you want to extract. Additionally,
#' visualisation tools like boxplots can complement these numerical measures. Adjust
#' these examples based on the characteristics of your specific dataset.





####

y <- rep(1, 10)
df0 <- data.frame(x, y)

ggplot(df0, aes(x = x, y = y)) +
  geom_point() +
  geom_line() +
  labs(title = "No variability: y is always 1",
       y = "y", x = "x") +
  theme_bw()

x <- 1:10
y <- x
df1 <- data.frame(x, y)

ggplot(df1, aes(x = x, y = y)) +
  geom_point() +
  geom_line() +
  labs(title = "Accounted for variability only: y = x",
       y = "y", x = "x") +
  theme_bw()



x <- 1:10
y <- x + rnorm(10)
df2 <- data.frame(x, y)

ggplot(df2, aes(x = x, y = y)) +
  geom_point() +
  geom_line(data = df1, aes(x = x, y = y),
            linetype = "dashed", colour = "grey50") +
  labs(title = "Accounted for + natural variability: y = x + error",
       subtitle = "Dashed line shows y = x",
       y = "y", x = "x") +
  theme_bw()


x  <- 1:10
z  <- c(rep(1, 5), rep(10, 5))  # hidden variable
y  <- x + z + rnorm(10)
df3 <- data.frame(x, y)

ggplot(df3, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE,
              colour = "#44575E", linewidth = 0.8) +
  labs(title = "Accounted for, unaccounted for, and natural variability",
       subtitle = "The line fits poorly because z is not in the data",
       y = "y", x = "x") +
  theme_bw()
