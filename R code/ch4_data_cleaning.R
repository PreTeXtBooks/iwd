# we need code too for if they need to install rpivotTable from CRAN (it will be back on there by the time this book goes out)
library(rpivotTable)
library(dplyr)
library(readxl)

#use the same data as in ch3
kenya_accidents_database <- read_excel("C:/Users/lclem/Downloads/kenya-accidents-database.xlsx")
#sheet = "2017")

# look at the first few rows to get a feel
head(kenya_accidents_database)

# or the whole data set
View(kenya_accidents_database)

# see the dimensions
dim(kenya_accidents_database)
# we can see there are 378 rows, 13 columns

# check the data names
names(kenya_accidents_database)
kenya_accidents_database$`...13` <- NULL

# ok, how about using a pivot table to explore it then?
rpivotTable(kenya_accidents_database)

# TIME 24 HOURS:
# implausible values? Or values that need fixing anyway
# NULL - what is NULL? - Those NULLs have happened here because they're NA in the sheet
# UNKNOWN TIME - these are put in as UNKNOWN TIME.
# What is 140 - is this 1400, or 1:40am? (Or 1:40pm?), or something else
# Aha! In excel if you put "0" as your first number, it removes it.
# So, perhaps then 140 is meant to be 0140, and 10 is meant to be 0010. 
# in fact, any missing initial numbers we can assume to be "0" until it is four digits
# so perhaps NULL is 0000
# but then, how do we know? We need to go to the original source and check.
# TODO: r code to fix this (tidyverse), and to convert it to a time-type.
kenya_accidents_database <- kenya_accidents_database %>%
  mutate(
    # Treat "UNKNOWN TIME" as NA
    `TIME 24 HOURS` = na_if(`TIME 24 HOURS`, "UNKNOWN TIME"),
    
    # Pad to 4 digits with leading zeros
    # e.g. "140" -> "0140", "10" -> "0010", NA -> "0000"
    `TIME 24 HOURS` = case_when(
      is.na(`TIME 24 HOURS`) ~ "0000",
      TRUE ~ str_pad(`TIME 24 HOURS`, width = 4, 
                     side = "left", pad = "0")
    ),
    
    # Convert to a proper time type (hhmm format)
    TIME_PARSED = hm(paste0(
      str_sub(`TIME 24 HOURS`, 1, 2), ":",
      str_sub(`TIME 24 HOURS`, 3, 4)
    ))
  )

# BASE/SUB BASE:
rpivotTable(kenya_accidents_database,
            rows = "COUNTY")

# in alphabetical order
# we can see some errors: KERCHO, and KERICHO
# MURANG'A	and MURANGA	
# etc. these are clear to us that they are meant to be the same, but the software
# will treat them differently. So we need to fix them. 

kenya_accidents_database <- kenya_accidents_database %>%
  mutate(COUNTY = case_when(
    COUNTY == "KERCHO" ~ "KERICHO",
    COUNTY == "MURANGA" ~ "MURANG'A",
    TRUE ~ COUNTY
  ))

# then verify it
rpivotTable(kenya_accidents_database,
            rows = "COUNTY")

# similarly for BASE/SUB BASE
rpivotTable(kenya_accidents_database,
            rows = "BASE/SUB BASE")

# like above, we see some errors.
# DAGORETI and DAGORETTI
# DTEO DAGORETI	 -- is that the same as DAGORETTI? (in reality we should check with someone who knows it well)
# we should check this with original data source / holders, but let's have some license here for illustrative purposes.
# MOI'S BRIDGE	and MOIS BRIDGE	
# MURANG'A	and MURANGA
# SALGA and SALGAA
kenya_accidents_database <- kenya_accidents_database %>%
  mutate(`BASE/SUB BASE` = str_trim(`BASE/SUB BASE`),
         `BASE/SUB BASE` = str_remove(`BASE/SUB BASE`, 
                                      regex("^DTEO\\s+", ignore_case = TRUE)),
         `BASE/SUB BASE` = case_when(
           `BASE/SUB BASE` == "DAGORETTI"  ~ "DAGORETI",
           `BASE/SUB BASE` == "MOI'S BRIDGE"  ~ "MOIS BRIDGE",
           `BASE/SUB BASE` == "MAKINGENI"  ~ "MAKONGENI",
           `BASE/SUB BASE` == "MURANGA" ~ "MURANG'A",
           `BASE/SUB BASE` == "SALGAA"  ~ "SALGA",
           TRUE ~ `BASE/SUB BASE`
         ))
# verify it
rpivotTable(kenya_accidents_database,
            rows = "BASE/SUB BASE")

# Now we can also do some cleaning to see how they affect each other
# base/sub-base is a subset of the county. So, let's check they are unique across counties

rpivotTable(kenya_accidents_database,
            rows = "BASE/SUB BASE",
            cols = "COUNTY")
# Let's place by increasing order. We immediately see that
# NAKURU has 12 cases. 11 in NAKURU county and 1 in MAKURU county.
# So, let's set MAKURU to be NAKURU as it is safe to assume this is an error!
kenya_accidents_database <- kenya_accidents_database %>%
  mutate(`COUNTY` = case_when(
           `COUNTY` == "MAKURU" ~ "NAKURU",
           TRUE ~ `COUNTY`
         ))
# all of STAREHE, EMBAKASI	 are in NAIROBI, correct.
# NYANDO	has 4 in HOMA BAY and 4 in KISUMU.
# is this due to 2 NYANDOs?
# from a quick look up NYANDO	is meant to be in Kisumu county.
# and so forth, so we can do some more quality control checking here.

# DATES: Convert to a datetype and let's plot numbers a day to see if errors
# We have April and June! Not May
kenya_accidents_database <- kenya_accidents_database %>%
  mutate(`Date DD/MM/YYYY` = as.Date(`Date DD/MM/YYYY`))
# check conversion by viewing it
# then lets plot 

ggplot(kenya_accidents_database,
       aes(x = `Date DD/MM/YYYY`)) +
  geom_bar()

# interesting. Appears there were no crashes in May.
# That's very unlikely. Perhaps then, we don't have May incidents. Just April and June!
# So, we can't fix that, but, we can go to the original authors, try to see if the data can be given. Or at least, this is useful information.

# let's also have a lok here at the missing dates in April and June. They are often followed by a large amount the next day
# so, when were these missing dates?
# how about we plot this by day of the week

kenya_accidents_database <- kenya_accidents_database %>%
  mutate(`weekday` = lubridate::wday(`Date DD/MM/YYYY`, label = TRUE))

ggplot(kenya_accidents_database,
       aes(x = `weekday`)) +
  geom_bar()
# interesting that we get more crashes on Fridays and Saturdays, and fewer on Mondays.
# Is this from more movement these dates? We don't have enough data to tell. 
# spoiler alert: in rainfall data, you might find no rainfall on a sunday, and often a spike of rainfall on a monday.
# so, that can be from people recording it the next day.
# however, in traffic data, this could be down to movement in the days. We can't assume every day to have an average same number of crashes because (a) only two months of data, and (b) likely that more are on the roads commuting on Friday/Saturday
# 
# "Friday is widely considered the busiest and most congested day of the week on Kenyan roads"
# we are seeing saturday as the most crashiest. 
# wouldn't we expect monday to have crashes? But there isn't. 
# Unless these are reported the next day. so the friday spike is actually saturdays, etc.
# and also "End of month" is busier too. But, we are seeing blanks on 27th and 28th of both months
# (these are weekdays in both April and June 2016. Very interesting.)
# is there really no crashes in two consecutive days in both April and June? Or is there something else happening with the data?
# (although we don't have any data after June 26th 2016, so maybe the data just cuts off there.)
kenya_accidents_database <- kenya_accidents_database %>%
  mutate(`day` = lubridate::day(`Date DD/MM/YYYY`))

ggplot(kenya_accidents_database,
       aes(x = `day`)) +
  geom_bar()

# is this what we expect? Let's look it up (although presumably this has come from data like this one, as it is NRSA, and so it may be that they need to clean it too!)
#"According to Kenya's National Road Safety Action Plan 2024???2028,
# nearly half of all fatal road crashes happen between Friday and
# Sunday. Evening and night hours are the most dangerous, driven by speeding, 
# drink-driving, and fatigue."









# NEXT ONE
# ADVANCED HERE - LINKS TO DATA SHAPES LATER TOO. BUT LINKS TO MULTI LEVEL DATA FROM EARLIER.
# we've done relabelling, we've done times
# we can check plausible values too - AGE
# but look, sometimes we have multiple ages, and sometimes we have months, and sometimes letters.
# so we want to sort this.
# similar issue with GENDER. We can see that there is M, F, and someitmes a mix. "NO." shows the numbers of deaths, as this is by incidents. 
# maybe then we create a new data frame, at the individual level.
# maybe that is easier for one for analysis is to have the individual level, not the incident level.
# that is useful for some variables. which variables make sense at that level?
# TIME, ROAD, PLACE, BRIEF ACCIDENT DETAILS, BASE/SUB BASE, COUNTY, CAUSE CODE, DATE belong at the incident-level.
# AGE, GENDER, VICTIM belong at the individual level. Then we can add some form of ID for the crash. We append that ID to the original data, and to this new data frame, to link them.
# todo: sort that. 

kenya_accidents_database <- kenya_accidents_database %>%
  mutate(incident_id = 1:nrow(kenya_accidents_database))

kenya_individual_level <- kenya_accidents_database %>%
  dplyr::select(c(incident_id,
                  AGE,
                  GENDER,
                  `NO.`,
                  VICTIM))

# look at it
# wantt o be consistent
# so, set 2F & 2M to be F F M M etc
# so we can ask GenAI to help with that sort of code, as that is quite advanced

library(purrr)
library(tidyr)
# sometimes separated by , sometimes by &
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

# Flexible splitting helper
split_flexible <- function(x) {
  str_split(x, "\\s*(?:[,&]|and)\\s*")
}

# Example data with mixed delimiters
kenya_individual_level <- kenya_individual_level %>%
  mutate(
    AGE = split_flexible(AGE),
    GENDER = split_flexible(GENDER),
    VICTIM = split_flexible(VICTIM)
  ) %>%
  mutate(
    AGE = map2(AGE, `NO.`, rep_len),
    GENDER = map2(GENDER, `NO.`, rep_len),
    VICTIM = map2(VICTIM, `NO.`, rep_len)
  ) %>%
  unnest(cols = c(AGE, GENDER, VICTIM))
# id 290, we can't know if it's M or F for the different ages. so, maybe we have a secondary gender, where we make it a new column. This is to look at the 
# gender stuff. But, we can't assume a certain gender matches a certain age.
# now, notice things like 5 MONTHS. We need to correct any that say MONTHS/months/etc to be 12/NUMBER of months
# we use gen AI for this. 
# but we need to ensure we check this

# Function to clean and convert months to numeric years or fractions
clean_months <- function(df, column_name, format = "decimal") {
  col <- sym(column_name)
  pattern <- "(?i)(\\d+(?:\\.\\d+)?)\\s*(?:months?|mth|mths)"
  
  df %>%
    mutate(
      # Extract numeric month value
      .months = as.numeric(str_match(!!col, pattern)[, 2]),
      
      # Convert based on requested format
      !!col := case_when(
        !is.na(.months) & format == "decimal"  ~ as.character(round(.months / 12, 2)),
        !is.na(.months) & format == "fraction" ~ paste0(.months, "/12"),
        TRUE ~ as.character(!!col)
      )
    ) %>%
    select(-.months)
}

# Convert to Decimal Years (e.g., 5 MONTHS -> "0.42")
kenya_individual_level <- clean_months(kenya_individual_level, "AGE", format = "decimal")
View(kenya_individual_level)

# id 66, we see all M and no age, but 8 people
# 7 passengers, 1 driver
# so we can separate this one into different columns as it doesn't matter which is the passenger, and which is the driver
# there's now only a handful of cases (as we only look at NO. > 2), so we can consider these indiviudally rather than overall.
# just need to make sure we don't attribute age to a new gender
# there are only a handful of cases, so I suggest doing this manually here to ensure it is all understood well. e.g., 
# id66 we just set 7 of those rows to be PASSENGERS to 1 to be DRIVER
# etc.

# And we can look at AGE now too. we hav e217 under "A". This is code for "ADULT"
# And J, which is "JUNIOR". So, let's set them
kenya_individual_level <- kenya_individual_level %>%
  mutate(
    # Create temporary numeric age variable to evaluate numeric entries safely
    .age_num = suppressWarnings(as.numeric(AGE)),
    
    AGE_GROUP = case_when(
      AGE %in% c("A", "ADULT") ~ "ADULT",
      AGE %in% c("J", "JUNIOR") ~ "JUNIOR",
      !is.na(.age_num) & .age_num >= 18 ~ "ADULT",
      !is.na(.age_num) & .age_num < 18  ~ "JUNIOR",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-`.age_num`)

# now let's also add in just an AGE numeric variable. this will set our J's and A's to be NA as there is no clear number to convert them to.
kenya_individual_level$AGE <- as.numeric(kenya_individual_level$AGE)

# so now, let's look at gender
rpivotTable(kenya_individual_level, rows = "AGE", cols = "AGE_GROUP")
# easy.
# we can see it's correctly moved into the new categories so we have not lost those A and J's in the conversion process
# but also, we have converted the ages to numeric correctly. 

# we can look for extreme, implausible ages (e.g., negative values, or ages extremely high) by looking at
summary(kenya_individual_level$AGE)
boxplot(kenya_individual_level$AGE)
# min/max looks all fine. no implausible values. Good. 

# VICTIM needs cleaning: P/PASSENGER, P/PASENGER, PASSENGERS, 2 PASSENGERS to be PASSENGER	
# 2 PEDESTRIANS to be PEDESTRIAN
# etc etc. Some we may have to do manually, like we discussed above with 7 PASSENGERS 1 DRIVER.





# note how it's doesn't go exploring then cleaning. But actually it is a cycle. The exploring can motivate hte cleaning, and vice versa.
# e.g., given what we read there, how about we look at the cause of accidents, and look at it by weekend.
# so, cause of accident:

unique(kenya_accidents_database$`CAUSE CODE`)

#Traffic and police crash reports categorize driver and road user errors using specific numeric cause codes, which include:Code 7: Driver proceeding with high speed / over-speedingCode 8: Driver failing to keep to the proper laneCode 10: Driver improperly overtakingCode 26: Driver losing control of the vehicleCode 29: Driver misjudging clearance, distance, or speedCode 30: Driver's general error of judgment or negligenceCode 68: Pedestrian's error of judgment or negligenceCode 98: Cause not traced or undetermined
# I can't find the cause codes beyond that. Maybe you can!
# The paper we looked at did say "There is a ???CAUSE CODE??? column appended for each entry of fatal accident report incidences. However, we could not ascertain its significance anywhere in the database. "

rpivotTable(kenya_accidents_database, rows = c("CAUSE CODE", "BRIEF ACCIDENT DETAILS"))
# cannot ascertain the cause codes from this. 
# but we can try to clean the cause codes somewhat. 

rpivotTable(kenya_accidents_database, rows = c("BRIEF ACCIDENT DETAILS"))
# ok we can see a lot of cleaning is needed here. 

# these are all the same. Let's change to "HEAD ON COLLISION"
#HEAD ON COLLISION
#HEAD ON COLLISION WITH A PEDAL CYCLIST
#HEAD ON COLLISION WITH AN ONCOMING VEHICLE
#HEAD ON COLLISION WITH ANOTHER TRAILER
#HEAD ON COLLISION WITH M/CYCLE

# these are all the same. Let's change to "HIT AND RUN"
# HIT & RAN
# HIT & RUN
# HIT AND RAN
# HIT AND RUN

# etc etc
# I'll be honest here. I used AI to categorise all 148 of these
# and then I checked it, of course. 

library(dplyr)
library(stringr)

kenya_accidents_database <- kenya_accidents_database %>%
  mutate(ACCIDENT_CATEGORY = case_when(
    
    # HEAD ON COLLISION
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("HEAD ON|HEAD-ON", ignore_case = TRUE)) ~ "Head on collision",
    
    # HIT AND RUN
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("HIT.*R(A|U)N|HIT & R(A|U)N", ignore_case = TRUE)) ~ "Hit and run",
    
    # LOST CONTROL
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("LOST CONTROL|LOSE CONTROL|TYRE BURST|STEERING ROD|POWER FAIL", 
                     ignore_case = TRUE)) ~ "Lost control",
    
    # PEDESTRIAN KNOCKED DOWN
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("KNOCKED DOWN|KNOCK DOWN|RAN OVER|RUN OVER|KNOCKED PEDESTRIAN", 
                     ignore_case = TRUE)) ~ "Pedestrian knocked down",
    
    # REAR COLLISION
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("REAR|FROM BEHIND|FAILED TO KEEP DISTANCE", 
                     ignore_case = TRUE)) ~ "Rear collision",
    
    # VEHICLE HIT MOTORCYCLE/CYCLIST
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("HIT.*M/CYCLE|HIT.*MOTOR CYCLE|HIT.*CYCLIST|HIT.*CYCLE", 
                     ignore_case = TRUE)) ~ "Vehicle hit motorcycle/cyclist",
    
    # OVERTAKING
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("OVERTOOK|OVERTAKING|OVERTAK", 
                     ignore_case = TRUE)) ~ "Overtaking incident",
    
    # ROLLED/OVERTURNED
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("ROLL|OVERTURN", 
                     ignore_case = TRUE)) ~ "Rolled/overturned",
    
    # VEERED OFF ROAD
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("VEERED OFF|VEER OFF|LANDED INTO A DITCH|LANDED IN A DITCH|PLUNGED|PLUGGED INTO", 
                     ignore_case = TRUE)) ~ "Veered off road",
    
    # ALIGHTING/BOARDING INCIDENT
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("ALIGHT|ALIGHTED|JUMPED OFF|FELL DOWN AND WAS", 
                     ignore_case = TRUE)) ~ "Alighting/boarding incident",
    
    # RAMMED INTO
    str_detect(`BRIEF ACCIDENT DETAILS`, 
               regex("RAMMED INTO|RAMMED", 
                     ignore_case = TRUE)) ~ "Vehicle rammed into another",
    
    # UNKNOWN/OTHER
    TRUE ~ "Other/unknown"
    
  ))

# neat way we can check we are happy:
rpivotTable(kenya_accidents_database, rows = c("ACCIDENT_CATEGORY", "BRIEF ACCIDENT DETAILS"))
# perhaps
# "THE VICTIM FELL DOWN AND WAS OVER RAN BY THE VEHICLE	" should be instead in idk. Other?
# "THE VEHICLE OVERTOOK A M/CYCLE AND LOST CONTROL VEERING OFF THE ROAD & ROLLED" would go into "Overtaking incident" instead of "Lost control"?
# Note the other/unknown: 
# THE MOTOR CYCLE HIT THE UNKNOWN M/V LOOSING CONTROL AND HIT THE TRAILER	 -- this would go into "LOSING CONTROL"
# THE VEHICLE COLLIDED WITH A M/CYCLE	 - goes into "HEAD ON COLLISION"
# THE VEHICLE HIT A PEDESTRIAN WHO WAS CROSSING THE ROAD	goes into "Pedestrian knocked down"
# Pedestrian knocked down	 should be "Knocked down"
# "THE CYCLE KNOCKED DOWN THE VEHICLE" is in "Pedestrian knocked down". perhaps belongs in Vehicle rammed into another	
# THE VEHICLE VEERED OFF THE ROAD AND KNOCKED DOWN THE VICTIM	 should be in "Veered off road" instead of the current category


# After reviewing the initial categorisation, we make the following refinements:
# After reviewing the initial categorisation, we make some refinements.
# We update specific cases that were miscategorised or need adjustment.

kenya_accidents_database <- kenya_accidents_database %>%
  mutate(ACCIDENT_CATEGORY = case_when(
    
    # Overtaking incident takes priority over Lost control
    # e.g. "THE VEHICLE OVERTOOK A M/CYCLE AND LOST CONTROL VEERING OFF THE ROAD & ROLLED"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("OVERTOOK|OVERTAKING|OVERTAK", ignore_case = TRUE)) ~ "Overtaking incident",
    
    # Veered off road + knocked down victim should stay in Veered off road
    # e.g. "THE VEHICLE VEERED OFF THE ROAD AND KNOCKED DOWN THE VICTIM"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("VEERED OFF|VEER OFF", ignore_case = TRUE)) &
      str_detect(`BRIEF ACCIDENT DETAILS`,
                 regex("KNOCKED DOWN|KNOCK DOWN", ignore_case = TRUE)) ~ "Veered off road",
    
    # Lost control - now catches "LOOSING CONTROL" typo too
    # e.g. "THE MOTOR CYCLE HIT THE UNKNOWN M/V LOOSING CONTROL AND HIT THE TRAILER"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("LOST CONTROL|LOSE CONTROL|LOOSING CONTROL|LOSING CONTROL|
                      TYRE BURST|STEERING ROD|POWER FAIL", 
                     ignore_case = TRUE)) ~ "Lost control",
    
    # Vehicle collided with motorcycle goes to Head on collision
    # e.g. "THE VEHICLE COLLIDED WITH A M/CYCLE"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("COLLIDED WITH", ignore_case = TRUE)) ~ "Head on collision",
    
    # Knocked down (renamed from Pedestrian knocked down)
    # Excludes "THE CYCLE KNOCKED DOWN THE VEHICLE" - goes to Vehicle rammed into another
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("KNOCKED DOWN|KNOCK DOWN|RAN OVER|RUN OVER", 
                     ignore_case = TRUE)) &
      !str_detect(`BRIEF ACCIDENT DETAILS`,
                  regex("CYCLE KNOCKED DOWN THE VEHICLE", ignore_case = TRUE)) ~ "Knocked down",
    
    # Vehicle rammed into another - now includes cycle knocking down a vehicle
    # e.g. "THE CYCLE KNOCKED DOWN THE VEHICLE"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("RAMMED|CYCLE KNOCKED DOWN THE VEHICLE", 
                     ignore_case = TRUE)) ~ "Vehicle rammed into another",
    
    # Victim fell and was run over goes to Other
    # e.g. "THE VICTIM FELL DOWN AND WAS OVER RAN BY THE VEHICLE"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("FELL DOWN AND WAS OVER RAN", ignore_case = TRUE)) ~ "Other/unknown",
    
    # Pedestrian knocked down from crossing road
    # e.g. "THE VEHICLE HIT A PEDESTRIAN WHO WAS CROSSING THE ROAD"
    str_detect(`BRIEF ACCIDENT DETAILS`,
               regex("HIT.*PEDESTRIAN|HIT A PEDESTRIAN", ignore_case = TRUE)) ~ "Knocked down",
    
    # Keep everything else as previously categorised
    TRUE ~ ACCIDENT_CATEGORY
    
  ))

rpivotTable(kenya_accidents_database, rows = c("ACCIDENT_CATEGORY", "BRIEF ACCIDENT DETAILS"))

# still some corrections we can make, possibly. but, regardless. Let's look now at our days a week crashes, by accident category.

ggplot(kenya_accidents_database,
       aes(x = `weekday`, fill = ACCIDENT_CATEGORY)) +
  geom_bar(position = "fill")

# this gives a proportion. This is now exploring, but it seems a higher proportion of weekend crashes occur from "Vehicle rammed into another"
# could that be due to drink driving?

# or we look at it this way around!
ggplot(kenya_accidents_database,
       aes(x = ACCIDENT_CATEGORY, fill = weekday)) +
  geom_bar(position = "fill")

ggplot(kenya_accidents_database,
       aes(x = `weekday`)) +
  geom_bar() +
  facet_wrap(vars(ACCIDENT_CATEGORY)) 

# look at the numbers
rpivotTable(kenya_accidents_database,
            cols = "weekday",
            rows = "ACCIDENT_CATEGORY")

# ok anyway, I'm "exploring" too much now. But see how the data cleaning has really helped this exploration!
# because weekday and ACCIDENT CATEGORY are both things we created via data cleaning. 

# point perhaps for earlier:::: 
# or look at NO. (no. of incidences in that incidence) against ACCIDENT_CATEGORY
rpivotTable(kenya_accidents_database,
            cols = "NO.",
            rows = "ACCIDENT_CATEGORY")
# boarding incident - just one. 
# a Hit and Run has 2 people injured. Could be the case.
# etc etc. good to find these flags. 

