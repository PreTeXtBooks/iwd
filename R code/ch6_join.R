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

# so lets have a look
# add in a table of it joined:

# TIME 24 HOURS
# BASE/SUB BASE
# COUNTY
# ROAD
# PLACE
# BRIEF ACCIDENT DETAILS
# GENDER
# AGE
# CAUSE CODE
# VICTIM
# NO.
# Date DD/MM/YYYY
# ...13
# Population
# Male
# Female
# Intersex
# Households
# Households_Conventional
# Households_Group Quarters
# Land Area
# Density
# 1
# 630
# KITUI
# MAKUENI
# KITUI-ITHOKWE
# KITUI SCHOOL
# HEAD ON COLLISION
# M
# 26
# 7
# M/CYCLIST
# 1
# 2016-06-25
# so MM/DD/YYYY is the solution :)
# 987653
# 489691
# 497942
# 20
# 244669
# 243979
# 690
# 8176.6664
# 120.78920
# 2
# 830
# VOI
# TAITA TAVETA
# MOMBASA-NAIROBI
# IKANGA
# HEAD ON COLLISION
# M
# 28
# 25
# M/CYCLIST
# 1
# 2016-06-25
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 3
# 1330
# MARIAKANI
# KILIFI
# MOMBASA-NAIROBI
# KATOLANI
# THE UNKNOWN M/V HIT THE MOTOR CYCLE
# M
# A & J
# 98
# M/CYCLIST
# 1
# 2016-06-25
# NA
# 1453787
# 704089
# 749673
# 25
# 298472
# 297990
# 482
# 12553.2650
# 115.80947
# 4
# 2100
# ONGATA RONGAI
# NAKURU
# NAKURU-NAIROBI
# MAASAI LODGE
# THE VEHICLE KNOCKED DOWN A PEDESTRIAN WHO WAS CROSSING THE ROAD
# M
# 65
# 29
# PEDESTRIAN
# 1
# 2016-06-25
# NA
# 2162202
# 1077272
# 1084835
# 95
# 616046
# 598237
# 17809
# 7504.9054
# 288.10516
# 5
# 1900
# MATUU
# MACHAKOS
# MATUU-MWINGI
# KIVANDINI
# THE VEHICLE OVERTOOK A M/CYCLE AND LOST CONTROL VEERING OFF THE ROAD & ROLLED
# M
# A
# 10
# PASSENGER
# 1
# 2016-06-25
# NA
# 1421932
# 710707
# 711191
# 34
# 402466
# 399523
# 2943
# 6037.2695
# 235.52568
# 6
# 2130
# NYANDO
# HOMA BAY
# KATITO-KENDU BAY
# PAP ONDITI
# HIT & RUN
# M
# A
# 98
# PEDESTRIAN
# 1
# 2016-06-25
# NA
# 1131950
# 539560
# 592367
# 23
# 262036
# 260290
# 1746
# 3152.5262
# 359.06126
# 7
# 1200
# MWEA
# KIRINYAGA
# MAKUTANO-MWEA
# MUMATI AREA
# HEAD ON COLLISION
# M & F
# J/A
# 10
# 2 PASSENGERS & DRIVER
# 3
# 2016-06-25
# NA
# 610411
# 302011
# 308369
# 31
# 204188
# 203576
# 612
# 1478.3108
# 412.91115
# 8
# 1330
# NAKURU
# NAKURU
# KENYATTA AVENUE
# NEAR OILIBIA
# HEAD ON COLLISION
# M
# A
# 26
# M/CYCLIST
# 1
# 2016-06-24
# NA
# 2162202
# 1077272
# 1084835
# 95
# 616046
# 598237
# 17809
# 7504.9054
# 288.10516
# 9
# 1930
# KAYOLE
# NAIROBI
# EASTERN BY PASS
# NEAR GULF PETROL STATION
# THE VEHICLE KNOCKED DOWN A PEDESTRIAN WHO WAS CROSSING THE ROAD
# F
# 15
# 63
# PEDESTRIAN
# 1
# 2016-06-24
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA



nrow(kenya_accidents_2016)
# [1] 378

nrow(kenya_accidents_join)
#[1] 392

# we joined the census data into the accidents data
# but how have we gained rows?
# let's scroll to the bottom to see. 
# 
# 377
# 1830
# KAYOLE
# NAIROBI
# SPINE ROAD
# NEAR SHUJAA MALL
# THE VICTIM TRIED TO ALIGHT WHILE THE VEHICLE WAS IN MOTION
# M
# A
# 70
# PASSENGER
# 1
# 2016-04-01
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 378
# 2230
# MAKONGENI
# NAIROBI
# JOGOO ROAD
# NEAR BAMA STAGE
# HIT AND RUN
# M
# A
# 63
# PEDESTRIAN
# 1
# 2016-04-01
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 379
# NA
# NA
# KENYA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 47564296
# 23548056
# 24014716
# 1524
# 12143913
# 12043016
# 100897
# 580895.3636
# 81.881005
# 380
# NA
# NA
# TANA RIVER
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 315943
# 158550
# 157391
# 2
# 68242
# 66984
# 1258
# 37903.6221
# 8.335430
# 381
# NA
# NA
# LAMU
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 143920
# 76103
# 67813
# 4
# 37963
# 34231
# 3732
# 6283.0247
# 22.906165
# 382
# NA
# NA
# TAITA/TAVETA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 340671
# 173337
# 167327
# 7
# 96429
# 94468
# 1961
# 17152.0057
# 19.861875
# 383
# NA
# NA
# WAJIR
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 781263
# 415374
# 365840
# 49
# 127932
# 126878
# 1054
# 56773.8141
# 13.760974
# 384
# NA
# NA
# MANDERA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 867457
# 434976
# 432444
# 37
# 125763
# 123954
# 1809
# 25942.1509
# 33.438129
# 385
# NA
# NA
# MARSABIT
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 459785
# 243548
# 216219
# 18
# 77495
# 76689
# 806
# 70944.2665
# 6.480932
# 386
# NA
# NA
# ISIOLO
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 268002
# 139510
# 128483
# 9
# 58072
# 53217
# 4855
# 25349.1876
# 10.572410
# 387
# NA
# NA
# THARAKA-NITHI
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 393177
# 193764
# 199406
# 7
# 109860
# 109450
# 410
# 2564.3574
# 153.323793
# 388
# NA
# NA
# TURKANA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 926976
# 478087
# 448868
# 21
# 164519
# 162627
# 1892
# 68233.0758
# 13.585435
# 389
# NA
# NA
# WEST POKOT
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 621241
# 307013
# 314213
# 15
# 116182
# 115761
# 421
# 9123.2801
# 68.094040
# 390
# NA
# NA
# SAMBURU
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 310327
# 156774
# 153546
# 7
# 65910
# 63951
# 1959
# 21089.6855
# 14.714634
# 391
# NA
# NA
# ELGEYO/MARAKWET
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 454480
# 227317
# 227151
# 12
# 99861
# 99119
# 742
# 3032.0593
# 149.891529
# 392
# NA
# NA
# NAIROBI CITY
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# NA
# 4397073
# 2192452
# 2204376
# 245
# 1506888
# 1494676
# 12212
# 703.8700
# 6246.995450

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

# TODO: PRETEXT TABLE THIS::::
# TIME 24 HOURS
# BASE/SUB BASE
# COUNTY
# ROAD
# PLACE
# BRIEF ACCIDENT DETAILS
# GENDER
# AGE
# CAUSE CODE
# VICTIM
# NO.
# Date DD/MM/YYYY
# ...13
# 1
# 2205
# NANYUKI
# NA
# KINAMBA
# NGARUA
# THE VEHICLE OVERTURNED KILLING 6 VICTIMS
# 4F & INF
# A
# 26
# PASSENGER
# 6
# 2016-04-08
# NA
# 2
# 2142
# KINANGOP
# NA
# NJAMBINI OLKALAO
# KAMAGUTA
# THE VEHICLE HIT A PEDAL CYCLIST
# M
# 33
# 98
# P/CYCLIST
# 1
# 2016-04-08
# NA

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

# we don't want them to go in as empty rows, so what we can do is a left_join
# TODO: explain left_join

kenya_accidents_join <- left_join(kenya_accidents_2016, kenya_census_2019,
                                  c("COUNTY" = "County"))
View(kenya_accidents_join)

# GIVE AS PRETEXT TABLE: 
# TIME 24 HOURS
# BASE/SUB BASE
# COUNTY
# ROAD
# PLACE
# BRIEF ACCIDENT DETAILS
# GENDER
# AGE
# CAUSE CODE
# VICTIM
# NO.
# Date DD/MM/YYYY
# ...13
# Population
# Male
# Female
# Intersex
# Households
# Households_Conventional
# Households_Group Quarters
# Land Area
# Density
# 1
# 630
# KITUI
# MAKUENI
# KITUI-ITHOKWE
# KITUI SCHOOL
# HEAD ON COLLISION
# M
# 26
# 7
# M/CYCLIST
# 1
# 2016-06-25
# so MM/DD/YYYY is the solution :)
# 987653
# 489691
# 497942
# 20
# 244669
# 243979
# 690
# 8176.6664
# 120.78920
# 2
# 830
# VOI
# TAITA/TAVETA
# MOMBASA-NAIROBI
# IKANGA
# HEAD ON COLLISION
# M
# 28
# 25
# M/CYCLIST
# 1
# 2016-06-25
# NA
# 340671
# 173337
# 167327
# 7
# 96429
# 94468
# 1961
# 17152.0057
# 19.86188
# 3
# 1330
# MARIAKANI
# KILIFI
# MOMBASA-NAIROBI
# KATOLANI
# THE UNKNOWN M/V HIT THE MOTOR CYCLE
# M
# A & J
# 98
# M/CYCLIST
# 1
# 2016-06-25
# NA
# 1453787
# 704089
# 749673
# 25
# 298472
# 297990
# 482
# 12553.2650
# 115.80947
# 4
# 2100
# ONGATA RONGAI
# NAKURU
# NAKURU-NAIROBI
# MAASAI LODGE
# THE VEHICLE KNOCKED DOWN A PEDESTRIAN WHO WAS CROSSING THE ROAD
# M
# 65
# 29
# PEDESTRIAN
# 1
# 2016-06-25
# NA
# 2162202
# 1077272
# 1084835
# 95
# 616046
# 598237
# 17809
# 7504.9054
# 288.10516
# 5
# 1900
# MATUU
# MACHAKOS
# MATUU-MWINGI
# KIVANDINI
# THE VEHICLE OVERTOOK A M/CYCLE AND LOST CONTROL VEERING OFF THE ROAD & ROLLED
# M
# A
# 10
# PASSENGER
# 1
# 2016-06-25
# NA
# 1421932
# 710707
# 711191
# 34
# 402466
# 399523
# 2943
# 6037.2695
# 235.52568


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
