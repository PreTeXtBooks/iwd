# ch6_join
library(dplyr)
library(tidyr)
library(readxl)

#use the same data as in ch3
kenya_accidents_2016 <- read_excel("C:/Users/lclem/Downloads/kenya-accidents-database.xlsx")

kenya_census_2019 <- read_excel("C:/Users/lclem/Downloads/2019-Kenya-population-and-Housing-Census-Population-households-density-by-county.xlsx")
# important learning point firstly on data rectangles. 

head(kenya_census_2019)
# A tibble: 6 × 10
# Population by Sex, Househo…¹ ...2  ...3  ...4  ...5  ...6  ...7  ...8  ...9  ...10
# <chr>                        <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#   1 NA                           NA    NA    NA    NA    NA    NA    NA    NA    NA   
# 2 NA                           Total Sex   NA    NA    Hous… NA    NA    Land… Dens…
# 3 County                       NA    Male  Fema… Inte… Total Conv… Grou… Sq Km Pers…
# 4 KENYA                        4756… 2354… 2401… 1524  1214… 1204… 1008… 5808… 81.8…
# 5 MOMBASA                      1208… 6102… 5980… 30    3784… 3762… 2127  219.… 5495…
# 6 KWALE                        8668… 4251… 4416… 18    1731… 1728… 374   8253… 105.…

# okay our data doesn't start until row 4! There are multiple row headings on row 2 and 3.

# explain the issue with that -- R expects just one.
# So, we will call in from row 3, and then, we will rename

kenya_census_2019 <- read_excel("C:/Users/lclem/Downloads/2019-Kenya-population-and-Housing-Census-Population-households-density-by-county.xlsx", 
                                skip = 3)
# [1] "County"             "...2"               "Male"              
# [4] "Female"             "Intersex"           "Total"             
# [7] "Conventional"       "Group quarters"     "Sq Km"             
# [10] "Persons per Sq. Km"

names(kenya_census_2019) <- c("County", "Population", "Male", "Female",
                              "Intersex", "Households",
                              "Households_Conventional",
                              "Households_Group Quarters",
                              "Land Area",
                              "Density")
# land area is  (sq km),
# density is persosn per sq km

tail(kenya_census_2019)
# County       Population    Male  Female Intersex Households Households_Conventio…¹
# <chr>             <dbl>   <dbl>   <dbl>    <dbl>      <dbl>                  <dbl>
#   1 HOMA BAY        1131950  539560  592367       23     262036                 260290
# 2 MIGORI          1116436  536187  580214       35     240168                 238133
# 3 KISII           1266860  605784  661038       38     308054                 307254
# 4 NYAMIRA          605576  290907  314656       13     150669                 150499
# 5 NAIROBI CITY    4397073 2192452 2204376      245    1506888                1494676
# 6 Source: 201…         NA      NA      NA       NA         NA                     NA

# remove last row
kenya_census_2019 <- kenya_census_2019 %>%
  filter(!is.na(Population))


# note that it is wide format. One row = one county
# but that means that male and female are separate columns
# so in a way, this is more a table for display information, than a data set. We may want to rearrange this later using pivot_wider.

# okay but now let's join our two tables together.
# so we join by COUNTY in kenya_accidents_2016
# and County in kenya_census_2019

kenya_accidents_join <- full_join(kenya_accidents_2016, kenya_census_2019)
# Error in `full_join()`:
#   ! `by` must be supplied when `x` and `y` have no common variables.
# ℹ Use `cross_join()` to perform a cross-join.
# explain error

kenya_accidents_join <- full_join(kenya_accidents_2016, kenya_census_2019,
                                  c("COUNTY" = "County"))
View(kenya_accidents_join)



# we joined the census data into the accidents data
# but how have we gained rows?
# let's scroll to the bottom to see. 

# Ah look, some of the counties never match!

# we also see this in the previous table -- row 2, e..g, "TAITA TAVETA" has NAs in the population
# but we can see "TAITA/TAVETA". 
# we need to have the names match identically. 
# so let's see which ones failed to match. 
# if population is NA, then they are rows that were in there, but haven't got data merged into them

# or can look by
unique(kenya_accidents_2016$COUNTY)
unique(kenya_census_2019$County)
# and compare

kenya_accidents_join %>% 
  dplyr::filter(is.na(Population)) %>%
  dplyr::pull(COUNTY) %>%
  unique()

#[1] "TAITA TAVETA"    "NAIROBI"         "KERCHO"          "MURANGA"        
#[5] "MWINGI"          "ELGEYO MARAKWET" "MAKURU"          "NYAHURURU"      
#[9] NA                "MARAKWET"       

# then let's look at ones that are in county but NA in Date -- these are cols that were in census data, but not matched to any counties in here
kenya_accidents_join %>% 
  dplyr::filter(is.na(`Date DD/MM/YYYY`)) %>%
  dplyr::pull(COUNTY) %>%
  unique()
# [1] "KENYA"           "TANA RIVER"      "LAMU"            "TAITA/TAVETA"   
# [5] "WAJIR"           "MANDERA"         "MARSABIT"        "ISIOLO"         
# [9] "THARAKA-NITHI"   "TURKANA"         "WEST POKOT"      "SAMBURU"        
# [13] "ELGEYO/MARAKWET" "NAIROBI CITY"   

# ok what to match:

# "TAITA TAVETA" --> "TAITA/TAVETA"
# "NAIROBI" --> "NAIROBI CITY"
# ELGEYO MARAKWET --> "ELGEYO/MARAKWET"
# MARAKWET --> "ELGEYO/MARAKWET"
# "MAKURU" --> remember from our data cleaning this is actually NAKURU
# "KERCHO" --> remember from our data cleaning this is actually KERICHO
# MURANGA --> from our data cleaning, this should match to "MURANG'A"
# NYAHURURU --> this is sa town, not a county - should be "LAIKIPIA
# MWINGI --> this is a town not a county, should be KITUI

# need to change those counties names

# then we will merge again. 
# Before we can join the accidents data to the census population data,
# we need to make sure the county names match between the two datasets.
# The census uses official county names, which differ in some cases from
# how counties were recorded in the accidents data.

# lets also check for if county is NA for any of them
kenya_accidents_2016 %>% filter(is.na(COUNTY)) %>% View()
# KINANGOP county should be is NYANDARUA
# BASE == "NANYUKI"   ~ "LAIKIPIA",

kenya_accidents_2016 <- kenya_accidents_2016 %>%
  mutate(COUNTY = case_when(
    
    # Spelling and formatting corrections to match census names
    COUNTY == "TAITA TAVETA"    ~ "TAITA/TAVETA",
    COUNTY == "NAIROBI"         ~ "NAIROBI CITY",
    COUNTY == "ELGEYO MARAKWET" ~ "ELGEYO/MARAKWET",
    COUNTY == "MARAKWET"        ~ "ELGEYO/MARAKWET",
    COUNTY == "MURANGA"         ~ "MURANG'A",
    
    # Corrections carried forward from data cleaning in Chapter 4
    COUNTY == "MAKURU"          ~ "NAKURU",
    COUNTY == "KERCHO"          ~ "KERICHO",
    
    # Towns incorrectly recorded as counties
    # Nanyuki and Nyahururu are both towns in Laikipia County
    `BASE/SUB BASE` == "NANYUKI"         ~ "LAIKIPIA",
    COUNTY == "NYAHURURU"       ~ "LAIKIPIA",
    # Mwingi is a town in Kitui County
    COUNTY == "MWINGI"          ~ "KITUI",
    # Kinangop is a sub-county in Nyandarua County
    `BASE/SUB BASE` == "KINANGOP"        ~ "NYANDARUA",
    
    # Everything else stays as is
    TRUE ~ COUNTY
  ))

# Verify no unmatched counties remain
setdiff(unique(kenya_accidents_2016$COUNTY), kenya_census_2019$County)
#> character(0)

# lets see what names are in kenya_accidents_2016 that are not in 
# kenya_census_2019
# Check which county names in the accidents data do NOT appear in the census data

setdiff(unique(kenya_accidents_2016$COUNTY), unique(kenya_census_2019$County))
# character(0)

# character(0) means the result is an empty character vector — there are no county names in the accidents data that are missing from the census data. Every county name now has a match. If there were still mismatches, they would appear here as a list of the unmatched names, telling you exactly what still needs fixing.

# You can also run it in the other direction — census counties that do not appear in the accidents data — though this is less critical for the join:

setdiff(unique(kenya_census_2019$County), unique(kenya_accidents_2016$COUNTY))
# [1] "KENYA"         "TANA RIVER"    "LAMU"          "WAJIR"         "MANDERA"      
# [6] "MARSABIT"      "ISIOLO"        "THARAKA-NITHI" "TURKANA"       "WEST POKOT"   
# [11] "SAMBURU" 
#This will return counties that exist in the census but have no crashes in the accidents data — which is expected, since the accidents data only covers April to June 2016 and not every county will have had a recorded fatal crash in that period.



## LEFT JOIN
# so let's merge it again
kenya_accidents_join <- full_join(kenya_accidents_2016,
                                  kenya_census_2019,
                                  c("COUNTY" = "County"))

nrow(kenya_accidents_2016)
# [1] 378

nrow(kenya_accidents_join)
#[1] 389

# an extra 11 columns. Hmm.
# this is from counties in kenya_census_2019 which do not have crash data in kenya_accidents_2016
# so these are just empty rows in the kenya_accidents_2016 side of the data.
# so we don't want these
# we don't want them to go in as empty rows, so what we can do is a left_join
# TODO: explain left_join

kenya_accidents_join <- left_join(kenya_accidents_2016, kenya_census_2019,
                                  c("COUNTY" = "County"))
View(kenya_accidents_join)

# Nice! we can see that row 2 is now correctly merged TAITA/TAVETA

# # any NAs in population?
kenya_accidents_join %>%
  filter(is.na(Population)) %>%
  nrow()
# [1] 0

# nope, no NAs in population,s o the merge was successful. Great!

# so then, now we can look at our data, and look at it with one of these new merged variables accounted for. 
ggplot(kenya_accidents_join, aes(x = COUNTY, fill = Population)) + geom_bar()

# idk. I want a great plot to show it, to really show off the power of what we've done. 
