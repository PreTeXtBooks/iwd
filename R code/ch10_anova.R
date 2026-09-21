# # ch 10 -     <p> ANOVA STUFF </p>
#
library(gapminder)
data(gapminder)

head(gapminder)

# # accounting for variability using an ANOVA
#
# # We dive into ANOVA tables, a tool to analyse differences in variability in
# the outcome that different variables account for.
# In an ANOVA, the total variability in the data is split into two components:
# ● The variation due to the differences between group means (accounted-for variation)
# ● The variation within the groups themselves (a mix of the unaccounted-for variation
# #                                               and the natural variability).
# # This division allows for assessing whether the means of different groups are substantially
# # different from each other while accounting for the variability within each group,
# #
# # ANOVA tables are used to investigate variation. It shows how much
# # variability is accounted for by a variable.

# SUBSECTION: NUMERICAL VARIABLE (gdpPercap)
mod <- lm(lifeExp ~ gdpPercap, data = gapminder)
anova(mod)

# Df Sum Sq Mean Sq F value    Pr(>F)
# gdpPercap    1  96813   96813  879.58 < 2.2e-16 ***
#   Residuals 1702 187335     110
#   Total     1703 284148
# # ● We first input the numerical variable: gdpPercap
# #
# # effect of gdpPercap is: 96813
#   # leftover is: 187335
# SO: 96813   / (96813    + 187335     )= 0.3407133 = 34.1% of variability in the
# life expectancy is accounted for by GDP per capita!
# That's huge. [explain what that means]
#
# # degrees of freedom is the number of choices we have
# # numerical variable = 1
# # total = total rows - 1 = 1704 - 1 = 1703
# residuals = leftover = 1703 - 1 = 1702
#
# # sums of squares
# # give a visual on it
# #
# # Plot gdpPercap against lifeexp
# # 2. Fit a line of best fit
# # 3. This looks at the distance (squared)
# # from log gbp per cap to the line of best fit.
# # 4. In our case, this value is 96813

ggplot(gapminder, aes(x = gdpPercap, y = lifeExp)) +
  geom_point()
# ah yes, remember earlier in visualising multidimensionality we saw skewness
# decided to log it. Let's do that here.
gapminder$log_gdpPercap <- log(gapminder$gdpPercap)

mod <- lm(lifeExp ~ log_gdpPercap, data = gapminder)
anova(mod)

# Response: lifeExp
# Df Sum Sq Mean Sq F value    Pr(>F)
# log_gdpPercap    1 185335  185335  3192.3 < 2.2e-16 ***
#   Residuals     1702  98814      58
#   Total         1703  284149
# # 185335/284149 * 100 = 0.6522458
# 65.2% of variability in life expectancy is accounted for by GDP Per Capita.
# THAT IS HUGE!!!!
# fuck that's scary.

ggplot(gapminder, aes(x = log_gdpPercap, y = lifeExp)) +
  geom_point(color = "#636363") +
  geom_segment(
    aes(
      xend = log_gdpPercap,
      yend = predict(lm(lifeExp ~ log_gdpPercap, data = gapminder))
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_smooth(se = FALSE, method = "lm", color = "black") +
  theme_bw() +
  labs(x = "GDP Per Capita (log)", y = "Life Expectancy")

# add graphic in
# explain graphic:
# # Accounted for SS
# # Plot log gdp percap against lifeExp
# # 2. Fit a line at the mean (orange line)
# # 3. This looks at the distance (squared)
# # from actual value to the mean.
# # 4. In our case, all the differences, squared, added together are 185335

ggplot(gapminder, aes(x = log_gdpPercap, y = lifeExp)) +
  geom_point(color = "#636363") +
  geom_segment(
    aes(
      xend = log_gdpPercap,
      yend =  59.47444,
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_hline(yintercept = 59.47444, color = "black", linewidth = 1) +
theme_bw() +
  labs(x = "GDP Per Capita (log)", y = "Life Expectancy")

# show plot here

# # this is the Total SS
# # Plot log gdpcap against lifeexp
# # 2. Fit a line at the mean (black line)
# # 3. This looks at the distance (squared)
# # from actual value to the mean.
# # 4. In our case, all the differences, squared, added together are 284149

# # Residual Sums of Squares@ This is the “leftover” bit.
# # The difference
# # between the line of
# # best fit and the mean
# # We haven’t
# # accounted for this
# # variability yet.

ggplot(gapminder, aes(x = log_gdpPercap, y = lifeExp)) +
  geom_point(color = "#636363") +
  geom_segment(
    aes(
      x = log_gdpPercap,
      xend = log_gdpPercap,
      y = 59.47444,
      yend = predict(lm(lifeExp ~ log_gdpPercap, data = gapminder))
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_smooth(se = FALSE, method = "lm", color = "black") +
  geom_hline(yintercept = 59.47444, color = "black", linewidth = 1) +
  theme_bw() +
  labs(x = "GDP Per Capita (log)", y = "Life Expectancy")

# give plot in here
#
# # The squared-difference between the
# # line of best fit and the mean
# # measured at every time that there is a lifeExp point.
# #  In our case, this value is 98814
#

# Now for MS:
# # MS = Sum Sq / Df
# # RMS = SD
# ● This is the average variation within each “df”
#
# # F value
# is the the variance between the “group” means by the variance in the residuals
# ● This helps ascertain whether the observed variability in the outcome (lifeExp) are due to
# random chance or due to log gbp per cap itself.
#
# This tells us: How much
# variation is accounted for by
# `log gbp per cap` compared to the
# residuals.
# This is much greater than 1.
# What does that tell us?
#   That a high amount of
# variability in the outcome is
# accounted for by `log gbp per cap`
# compared to the residuals.
#
# what if approx. 1, or lt 1?
#

# OK nice.

# now what if a factor - like continent

mod <- lm(lifeExp ~ continent, data = gapminder)
anova(mod)

# Df Sum Sq Mean Sq F value    Pr(>F)
# continent    4 139343   34836  408.73 < 2.2e-16 ***
#  Residuals 1699 144805      85
#    Total    1703   284149
#
# continent accounts for  139343/(139343+284149) = 32.9% of variability in lifeexp.
# same idea here: DF is ... [explain DF and all we get out of it]
# [ todo -- listen to podcast by me and david on DF? ]
#
# SS is the same idea.
# continent SS:
set.seed(123)

gapminder_jitter <- gapminder %>%
  mutate(
    x_jitter = as.numeric(continent) + runif(n(), -0.2, 0.2),
    continent_mean = ave(lifeExp, continent, FUN = mean)
  )

ggplot(gapminder_jitter, aes(x = x_jitter, y = lifeExp)) +
  geom_segment(
    aes(
      xend = x_jitter,
      yend = continent_mean
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_point(color = "#636363") +
  geom_segment(
    data = gapminder_jitter %>%
      group_by(continent) %>%
      summarise(
        x = first(as.numeric(continent)) - 0.3,
        xend = first(as.numeric(continent)) + 0.3,
        y = mean(lifeExp),
        yend = mean(lifeExp)
      ),
    aes(x = x, xend = xend, y = y, yend = yend),
    color = "black",
    linewidth = 1
  ) +
  scale_x_continuous(
    breaks = 1:length(levels(gapminder$continent)),
    labels = levels(gapminder$continent)
  ) +
theme_bw() +
  labs(x = "Continent", y = "Life Expectancy")

# give plot
# explain the SS in it this time -- we have a mean for life exp for each continent.

mean(gapminder_jitter$lifeExp, na.rm = TRUE)

# total SS
ggplot(gapminder_jitter, aes(x = x_jitter, y = lifeExp)) +
  geom_segment(
    aes(
      xend = x_jitter,
      yend = 59.47444
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_point(color = "#636363") +
  geom_hline(yintercept = 59.47444,
    color = "black",
    linewidth = 1
  ) +
  scale_x_continuous(
    breaks = 1:length(levels(gapminder$continent)),
    labels = levels(gapminder$continent)
  ) +
  theme_bw() +
  labs(x = "Continent", y = "Life Expectancy")

# then the difference
ggplot(gapminder_jitter, aes(x = x_jitter, y = lifeExp)) +
  geom_segment(
    aes(
      x = x_jitter,
      xend = x_jitter,
      y = 59.47444,
      yend = continent_mean
    ),
    color = "orange",
    alpha = 0.5
  ) +
  geom_point(color = "#636363") +
  geom_segment(
    data = gapminder_jitter %>%
      group_by(continent) %>%
      summarise(
        x = first(as.numeric(continent)) - 0.3,
        xend = first(as.numeric(continent)) + 0.3,
        y = mean(lifeExp),
        yend = mean(lifeExp)
      ),
    aes(x = x, xend = xend, y = y, yend = yend),
    color = "black",
    linewidth = 1
  ) +
  scale_x_continuous(
    breaks = 1:length(levels(gapminder$continent)),
    labels = levels(gapminder$continent)
  ) +
  theme_bw() +
  labs(x = "Continent", y = "Life Expectancy") +
  geom_hline(yintercept = 59.47444,
             color = "black",
             linewidth = 1
  )

# give plot, adn explain it.

###########################################################

# # then show them together in a table
mod3 <- lm(lifeExp ~ continent + log_gdpPercap, data = gapminder)
anova(mod3)

# Df Sum Sq Mean Sq F value    Pr(>F)
# continent        4 139343   34836  703.24 < 2.2e-16 ***
#   log_gdpPercap    1  60693   60693 1225.22 < 2.2e-16 ***
#   Residuals     1698  84113      50
# total           1703 284149

# look how log_gdpPercap has decreased. This is becaus ea lot of the variability it accounts
# for is also accounted for my continent. and continent being in there first takes it first.
# if you swap it, you'd see the other way.
# doesn't matter here - both v. sig.

# continent + log gdp per capita account for (139343+60693)/284149 = 70.4% of variability in the life expectancy variable
# wow.
# that's a lot.

# mod4 <- lm(lifeExp ~ log_gdpPercap + continent, data = gapminder)
# anova(mod4)


# unidentified variability
# ● 70.4% of variability in lifeExp is accounted for by log gbp per cap and continent
# ● The other 29.6% is unaccounted-for variability.
# This is split into:
#   ● Random (natural) variability.
# ● Unidentified variability.
# This is variability that could be accounted for, but has not been, either because
# we do not have those variables in the data set, or because we have not put them
# in the data (other variables in the data set or interactions).
# The aim is to reduce the unidentified variability.

# if we put in country, then continent would be auto taken out as continent and country are nested (or something like that idk)
# we used continent for illustrative purposes, but, country would be better to use here
# then let's also put in year  and population
mod4 <- lm(lifeExp ~ log_gdpPercap + country + year + pop, data = gapminder)
anova(mod4)

# Df Sum Sq Mean Sq   F value    Pr(>F)
# log_gdpPercap    1 185335  185335 15165.874 < 2.2e-16 ***
#   country        141  55179     391    32.023 < 2.2e-16 ***
#   year             1  24205   24205  1980.712 < 2.2e-16 ***
#   pop              1    378     378    30.923 3.154e-08 ***
#   Residuals     1559  19052      12
# TOTAL           1703  284149

# accounted for: 265097/284149 = 93.3% of variability in life expectancy is accounted for


# # conclusion
# ANOVA tables help find real differences between groups.
# ● They're a key tool in exploring data to help determine variables that
# account for variability
# ● The aim is to reduce the unidentified variability



#### GRAPHS
mean_lifeExp <- mean(gapminder$lifeExp)

ggplot(gapminder, aes(x = log_gdpPercap, y = lifeExp)) +
  geom_segment(aes(xend = log_gdpPercap, yend = mean_lifeExp),
               colour = "orange", alpha = 0.5) +
  geom_point(colour = "#636363") +
  geom_hline(yintercept = mean_lifeExp,
             colour = "black", linewidth = 1) +
  labs(title = "Total sum of squares",
       subtitle = "Orange: distance from each point to the overall mean",
       x = "Log GDP per capita",
       y = "Life expectancy (years)") +
  theme_bw()
