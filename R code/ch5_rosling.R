# <introduction>
#   <p>
#   Hans Rosling's Gapminder data make the same point as the elephants, with
#         a dataset you can actually hold in your hands.
#         The data are completely open, and a cleaned excerpt is bundled directly
#         into R as the <c>gapminder</c> package: 1,704 observations covering 142
#         countries from 1952 to 2007, with one row per country per year and
#         columns for <c>country</c>, <c>continent</c>, <c>year</c>,
#         <c>lifeExp</c> (life expectancy), <c>pop</c> (population), and
#         <c>gdpPercap</c> (GDP per person).
#       </p>
# 
#       <p>
#         A single row tells you almost nothing interesting.
#         What made Rosling's presentation of this data famous was building it up,
# one variable at a time, into a single animated chart <mdash/> the exact
# idea behind <xref ref="sec-following-the-giants"/>, with a dataset small
# enough to work through by hand.
# </p>
#   </introduction>
  
# subsection:
  # Two dimensions: does money buy a longer life?</title>

# we want this to be useful in teaching grammar of graphics, as well as how to do it in R.

# Install packages if needed
install.packages("gapminder")

library(gapminder)
library(ggplot2)

# Let's take just 2007 data
gapminder_2007 <- subset(gapminder, year == 2007)

# can look at info on this
?gapminder

# Excerpt of the Gapminder data on life expectancy, GDP per capita, and population by country.
# 
# Usage
# gapminder
# Format
# The main data frame gapminder has 1704 rows and 6 variables:
#   
#   country
# factor with 142 levels
# 
# continent
# factor with 5 levels
# 
# year
# ranges from 1952 to 2007 in increments of 5 years
# 
# lifeExp
# life expectancy at birth, in years
# 
# pop
# population
# 
# gdpPercap
# GDP per capita (US$, inflation-adjusted)

# then we should look at the data a bit, briefly. 
dim(gapminder_2007)
#[1] 142   6

head(gapminder_2007)
# country     continent  year lifeExp      pop gdpPercap
# <fct>       <fct>     <int>   <dbl>    <int>     <dbl>
#   1 Afghanistan Asia       2007    43.8 31889923      975.
# 2 Albania     Europe     2007    76.4  3600523     5937.
# 3 Algeria     Africa     2007    72.3 33333216     6223.
# 4 Angola      Africa     2007    42.7 12420476     4797.
# 5 Argentina   Americas   2007    75.3 40301927    12779.
# 6 Australia   Oceania    2007    81.2 20434176    34435.

#

# ok and now ggplot2. works with layers etc etc (please explain it better)
# so this just gives a blank canvas
ggplot(gapminder_2007)

# okay and now we can add in x and y variables
ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp))

# and we can then pick which "geom" (explain what a geom is please)
# geom_point is for scatter points
ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point()

# ok we see it is exponential, lets then rescale it (explain more, what skew, what rescaling?)
# why should we rescale? -- explain.
ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  scale_x_log10()

# now on a linear scale
# easier to interpret -- I think?

# then, add in labels
ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  scale_x_log10() +
  labs(x = "GDP per capita (log scale)", y = "Life expectancy")


#       </program>
#       <p>
#         Even this bare scatterplot shows a clear upward trend, though income is
#         logged on the x-axis because a handful of very rich countries would
#         otherwise crush the rest of the points into one corner.
#         But every point is currently the same colour and the same size <mdash/>
#         a Norwegian point and a Nigerian point are visually identical except for
#         position.
#       </p>
#     </subsection>
# 
#     <subsection xml:id="ss-gapminder-3d">
#       <title>Three dimensions: adding continent</title>
# 
#       <p>
#         Map <c>continent</c> onto colour, and a third variable appears in the
#         same chart without adding a single new axis.
#  so we simply just add in colour =, to add a new dimension (variable) into our plot. 
# now we have three dimesnions: on x we have .., y we have ..., then colour is by ...
#       </p>
# 
#       <program language="r">
        ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp, colour = continent)) +
          geom_point() +
          scale_x_log10() +
          labs(x = "GDP per capita (log scale)", y = "Life expectancy")
#       </program>
#       <p>
#         The trend from <xref ref="ss-gapminder-2d"/> is still there, but now it
#         has structure: African countries cluster toward the lower left, European
#         countries toward the upper right, and the spread within each continent
#         becomes visible for the first time.
#         Nothing about the underlying data changed.
#         One aesthetic mapping did.
#       </p>
        # then what if colourblind, etc. how about we use shape and color to make it clear?
        # or a colorblind friendly colours?
        ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp, colour = continent,
                                   shape = continent)) +
          geom_point() +
          scale_x_log10() +
          labs(x = "GDP per capita (log scale)", y = "Life expectancy")
#     </subsection>
# 
#     <subsection xml:id="ss-gapminder-4d">
#       <title>Four dimensions: adding population</title>
# 
#       <p>
#         Map <c>pop</c> onto point size, and the chart gains a fourth variable,
#         turning a scatterplot into a bubble chart.
        # we add a fourth dimension now (if we say that continent having two aes's is one dimension)
        # and we add in alpha = 0.7. What is alpha -- explain. 
        #       </p>
# 
#       <program language="r">
        ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp,
                                   colour = continent, shape = continent,
                                   size = pop)) +
          geom_point(alpha = 0.7) +
          scale_x_log10() +
          scale_size_continuous(range = c(1, 15)) +
          labs(x = "GDP per capita (log scale)", y = "Life expectancy",
               size = "Population")
#       </program>
#       <p>
#         China and India, similar in income and life expectancy to several
#         smaller countries, now visibly dominate the chart by sheer size.
#         That is real information <mdash/> population <mdash/> that a plain
#         scatterplot could not have shown without a second, separate chart.
#       </p>
#     </subsection>
# 
# 
        # but where is kenya? how to see beyond China/India which are recognisable just because of their population size?
        
        #   # add in labels too for some of them, 
        # show that and adding in labels for Kenya, and other stand out ones
        ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp,
                              colour = continent, shape = continent,
                              size = pop)) +
          geom_point(alpha = 0.7) +
          scale_x_log10() +
          scale_size_continuous(range = c(1, 10)) +
          labs(x = "GDP per capita (log scale)", y = "Life expectancy",
               size = "Population")
        
        # how to add in labels for some of them, e.g., Kenya, what else? 
        # this is for a kenya course, so ones of interest.
        
        
        
        
#     <subsection xml:id="ss-gapminder-5d">
#       <title>Five dimensions: adding time</title>
# 
#       <p>
#         The chart so far is a single snapshot, 2007 only.
#         Rosling's original animated the chart across every year in the data,
# letting countries move as their income and life expectancy changed.
# Without animation software, the same fifth dimension <mdash/> time
# <mdash/> can be shown as small multiples, one panel per year.
# </p>
#   
#   <program language="r">
  ggplot(gapminder, aes(x = gdpPercap, y = lifeExp,
                        colour = continent, shape = continent,
                        size = pop)) +
  geom_point(alpha = 0.7) +
  scale_x_log10() +
  scale_size_continuous(range = c(1, 10)) +
  facet_wrap(~ year) +
  labs(x = "GDP per capita (log scale)", y = "Life expectancy",
       size = "Population")
# </program>
#   <p>
#   Read left to right, top to bottom, and entire countries visibly migrate
# across the panel: life expectancy climbing steadily almost everywhere,
# even where income barely moves; the occasional sharp reversal, a bubble
# dropping backward in a single panel, worth investigating rather than
# dismissing as noise.
  
# themes: show off adding some themes in.
  # some given already: theme_bw
  # some that you can play and add in
  ggplot(gapminder, aes(x = gdpPercap, y = lifeExp,
                        colour = continent, shape = continent,
                        size = pop)) +
    geom_point(alpha = 0.7) +
    scale_x_log10() +
    scale_size_continuous(range = c(1, 10)) +
    facet_wrap(~ year) +
    labs(x = "GDP per capita (log scale)", y = "Life expectancy",
         size = "Population") + 
    theme_bw()
  
  # and colours you can change them too
  # show changing the colours to a better palette.
  
# (If you have the <c>gganimate</c> package installed, the same five
#   variables can be drawn as a single moving chart,
#   <c>transition_time(year)</c>, closer to Rosling's original.)
#       </p>
#     </subsection>
  
  # show with gganimate
  # if needed: install.packages("gganimate")
  library(gganimate)
  
  gapminder <- gapminder %>%
    arrange(continent, country, year)
  
  # hmm something is not right with china. It flips to be in the wrong place at one point. 
  
  ggplot(gapminder, aes(x = gdpPercap, y = lifeExp,
                        colour = continent, shape = continent,
                        size = pop)) +
    geom_point(alpha = 0.7) +
    scale_x_log10() +
    scale_size_continuous(range = c(1, 10)) +
    labs(x = "GDP per capita (log scale)", y = "Life expectancy",
         size = "Population") + 
    transition_time(year)
  
# 
#     <subsection xml:id="ss-gapminder-summary">
#       <title>What just happened</title>
# 
#       <p>
#         Five variables, five aesthetics, and not one extra table.
#       </p>
# 
#       <table xml:id="table-gapminder-dimensions">
#         <title>Dimensions added to the Gapminder chart, one at a time</title>
# 
#         <tabular halign="left">
#           <row header="yes" bottom="minor">
#             <cell>Dimension</cell>
#             <cell>Aesthetic</cell>
#             <cell>Variable</cell>
#           </row>
# 
#           <row>
#             <cell>1st &amp; 2nd</cell>
#             <cell>x, y position</cell>
#             <cell><c>gdpPercap</c>, <c>lifeExp</c></cell>
#           </row>
# 
#           <row>
#             <cell>3rd</cell>
#             <cell>colour</cell>
#             <cell><c>continent</c></cell>
#           </row>
# 
#           <row>
#             <cell>4th</cell>
#             <cell>size</cell>
#             <cell><c>pop</c></cell>
#           </row>
# 
#           <row>
#             <cell>5th</cell>
#             <cell>facet / animation frame</cell>
#             <cell><c>year</c></cell>
#           </row>
#         </tabular>
#       </table>
# 
#       <p>
#         Each new variable was added as a new <term>aesthetic mapping</term>, not
#         a new chart, a new axis, or a new table.
#         That is the whole technique this chapter is teaching, and
#         <xref ref="sec-following-the-giants"/> was the same idea before it had a
#         name: GPS location, land cover, protection status, sex and season, held
#         together in one analysis rather than one table per variable, is what
#         turned 834,138 rows of coordinates into a finding about forest
#         preference, sex differences and a corridor gone quiet.
#         Five variables again, in substance if not in a single ggplot call
#         <mdash/> the same move as <xref ref="ss-gapminder-4d"/>, just with a
#         resource-selection model standing in for <c>colour =</c> and
#         <c>size =</c>.
#       </p>
# 
#       <p>
#         <term>Source:</term> Bryan, J.
#         <c>gapminder</c> R package, data curated by the Gapminder Foundation (
#         <url href="https://www.gapminder.org" visual="gapminder.org"/> ), based
#         on the work of Hans Rosling.
#       </p>
#     </subsection>
#   </section>