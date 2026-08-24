# <p>
#   in chapter 3 and 4, we introduced the Kenya road safety data. We look back at that data here to illustrate appending. 
# So, we downloaded that data for exploring, and for cleaning. But fun fact, there are two sheets! So, here, appending that.
# </p>
  
library(dplyr)
library(tidyr)
library(readxl)

#use the same data as in ch3
kenya_accidents_2016 <- read_excel("C:/Users/lclem/Downloads/kenya-accidents-database.xlsx")
kenya_accidents_2017 <- read_excel("C:/Users/lclem/Downloads/kenya-accidents-database.xlsx",
                                   sheet = "2017")

# ordinarily a lot mroe data cleaning would be needed to tidy up both sheets. but let's have a look at them to get an idea

head(kenya_accidents_2016)

# # A tibble: 6 × 13
# `TIME 24 HOURS` `BASE/SUB BASE` COUNTY       ROAD            PLACE BRIEF ACCIDENT DETAI…¹ GENDER AGE   `CAUSE CODE` VICTIM   NO. `Date DD/MM/YYYY`   ...13
# <chr>           <chr>           <chr>        <chr>           <chr> <chr>                  <chr>  <chr>        <dbl> <chr>  <dbl> <dttm>              <chr>
#   1 630             KITUI           MAKUENI      KITUI-ITHOKWE   KITU… HEAD ON COLLISION      M      26               7 M/CYC…     1 2016-06-25 00:00:00 so M…
# 2 830             VOI             TAITA TAVETA MOMBASA-NAIROBI IKAN… HEAD ON COLLISION      M      28              25 M/CYC…     1 2016-06-25 00:00:00 NA   
# 3 1330            MARIAKANI       KILIFI       MOMBASA-NAIROBI KATO… THE UNKNOWN M/V HIT T… M      A & J           98 M/CYC…     1 2016-06-25 00:00:00 NA   
# 4 2100            ONGATA RONGAI   NAKURU       NAKURU-NAIROBI  MAAS… THE VEHICLE KNOCKED D… M      65              29 PEDES…     1 2016-06-25 00:00:00 NA   
# 5 1900            MATUU           MACHAKOS     MATUU-MWINGI    KIVA… THE VEHICLE OVERTOOK … M      A               10 PASSE…     1 2016-06-25 00:00:00 NA   
# 6 2130            NYANDO          HOMA BAY     KATITO-KENDU B… PAP … HIT & RUN              M      A               98 PEDES…     1 2016-06-25 00:00:00 NA  


head(kenya_accidents_2017)
# # A tibble: 6 × 15
# `TIME 24 HOURS` `BASE/SUB BASE` COUNTY  ROAD  PLACE `MV INVOLVED` BRIEF ACCIDENT DETAI…¹ `NAME OF VICTIM` GENDER AGE   `CAUSE CODE` VICTIM   NO. `Date DD/MM/YYYY`  `...15`
# <chr>           <chr>           <chr>   <chr> <chr> <chr>         <chr>                  <chr>            <chr>  <chr>        <dbl> <chr>  <dbl> <dttm>             <dttm>
#   1 745             KISUMU          KISUMU  NAIR… KASA… KBS 163T/ZD … THE VEHICLE LOST CONT… UNKNOWN          F      A               29 PASSE…     1 2017-11-06 00:00:00    2017-06-11
# 2 1430            NAROK           NAROK   NARO… NARO… KBS 518A HON… THE VEHICLE KNOCKED D… UNKNOWN          M      80              68 PEDES…     1 2017-11-06 00:00:00     NA
# 3 1515            LONDIANI        KERICHO KERI… JUBE… KTCB 472K JO… THE VEHICLE LOST CONT… UNKNOWN          M      25              26 DRIVER     1 2017-11-06 00:00:00     NA
# 4 1600            KIMILILI        BUNGOMA BOKO… BITU… KBW 374M TOY… THE VEHICLE KNOCKED D… UNKNOWN          M      31               7 PEDES…     1 2017-11-06 00:00:00     NA
# 5 1747            NAKURU          NAKURU  PIPE… PIPE… KMDQ 433R DA… THE VEHICLE HIT THE M… UNKNOWN          M      23              29 M/CYC…     1 2017-11-06 00:00:00     NA
# 6 1830            ONGATA RONGAI   KAJIADO MAGA… CHAP… KBG 936M T/M… THE VEHICLE RAMMED IN… UNKNOWN          F      30              18 P/PAS…     1 2017-11-06 00:00:00     NA


# similarities and differences
# 12/13 cols in 2016 data are in 2017 data, all the same data classes, and the same names (e.g., TIME 24 HOURS is chr in both, and named that in both)
# only ..13 is in one and not the other. but established in data cleaning that this column is not needed
# 2017 has some extra columns: MV INVOLVED, NAME OF VICTIM, and ...15
# so what happens when we append?

kenya_accidents_2016$`...13` <- NULL
kenya_accidents_2017$`...15` <- NULL

# so, let's append them. let's just simply make them into one data frame, by placing the 2017 data after the 2016 data set
bind_rows(kenya_accidents_2016, kenya_accidents_2017)


# `TIME 24 HOURS` `BASE/SUB BASE` COUNTY ROAD  PLACE BRIEF ACCIDENT DETAI…¹ GENDER AGE   `CAUSE CODE` VICTIM   NO. `Date DD/MM/YYYY`   `MV INVOLVED` `NAME OF VICTIM`
# <chr>           <chr>           <chr>  <chr> <chr> <chr>                  <chr>  <chr>        <dbl> <chr>  <dbl> <dttm>              <chr>         <chr>           
#   1 630             KITUI           MAKUE… KITU… KITU… HEAD ON COLLISION      M      26               7 M/CYC…     1 2016-06-25 00:00:00 NA            NA              
# 2 830             VOI             TAITA… MOMB… IKAN… HEAD ON COLLISION      M      28              25 M/CYC…     1 2016-06-25 00:00:00 NA            NA              
# 3 1330            MARIAKANI       KILIFI MOMB… KATO… THE UNKNOWN M/V HIT T… M      A & J           98 M/CYC…     1 2016-06-25 00:00:00 NA            NA              
# 4 2100            ONGATA RONGAI   NAKURU NAKU… MAAS… THE VEHICLE KNOCKED D… M      65              29 PEDES…     1 2016-06-25 00:00:00 NA            NA              
# 5 1900            MATUU           MACHA… MATU… KIVA… THE VEHICLE OVERTOOK … M      A               10 PASSE…     1 2016-06-25 00:00:00 NA            NA              
# 6 2130            NYANDO          HOMA … KATI… PAP … HIT & RUN              M      A               98 PEDES…     1 2016-06-25 00:00:00 NA            NA              
# 7 1200            MWEA            KIRIN… MAKU… MUMA… HEAD ON COLLISION      M & F  J/A             10 2 PAS…     3 2016-06-25 00:00:00 NA            NA              
# 8 1330            NAKURU          NAKURU KENY… NEAR… HEAD ON COLLISION      M      A               26 M/CYC…     1 2016-06-24 00:00:00 NA            NA              
# 9 1930            KAYOLE          NAIRO… EAST… NEAR… THE VEHICLE KNOCKED D… F      15              63 PEDES…     1 2016-06-24 00:00:00 NA            NA              
# 10 2030            THIKA           KIAMBU NYER… BLUE… THE MOTOR CYCLE HIT T… M      17              26 P/PAS…     1 2016-06-24 00:00:00 NA            NA    

# it works nicely. we can see that MV INVOLVED and NAME OF VICTIM (our new cols from 2017) are in there, and just as NAs from the old data. Easy
# how else can I show this is in there nicely? ideas? 
# maybe plot of the date to show we have 2016 and 2017 dates now.



# illustarte: what if a different variable name?
# lets rename a variable and look at it if we have the same column, but a different name.
kenya_accidents_2016 <- dplyr::rename(kenya_accidents_2016, "SEX" = GENDER)
names(kenya_accidents_2016)
# [1] "TIME 24 HOURS"          "BASE/SUB BASE"          "COUNTY"                 "ROAD"                   "PLACE"                  "BRIEF ACCIDENT DETAILS"
# [7] "SEX"                    "AGE"                    "CAUSE CODE"             "VICTIM"                 "NO."                    "Date DD/MM/YYYY"      
# now lets append
bind_rows(kenya_accidents_2016, kenya_accidents_2017)
# todo - show output and give them output

# `TIME 24 HOURS` `BASE/SUB BASE` COUNTY ROAD  PLACE BRIEF ACCIDENT DETAI…¹ SEX    AGE   `CAUSE CODE` VICTIM   NO. `Date DD/MM/YYYY`   `MV INVOLVED` `NAME OF VICTIM`  GENDER
# <chr>           <chr>           <chr>  <chr> <chr> <chr>                  <chr>  <chr>        <dbl> <chr>  <dbl> <dttm>              <chr>         <chr>             <chr>           
#   1 630             KITUI           MAKUE… KITU… KITU… HEAD ON COLLISION      M      26               7 M/CYC…     1 2016-06-25 00:00:00 NA            NA              NA
# 2 830             VOI             TAITA… MOMB… IKAN… HEAD ON COLLISION      M      28              25 M/CYC…     1 2016-06-25 00:00:00 NA            NA              NA
# 3 1330            MARIAKANI       KILIFI MOMB… KATO… THE UNKNOWN M/V HIT T… M      A & J           98 M/CYC…     1 2016-06-25 00:00:00 NA            NA              NA
# 4 2100            ONGATA RONGAI   NAKURU NAKU… MAAS… THE VEHICLE KNOCKED D… M      65              29 PEDES…     1 2016-06-25 00:00:00 NA            NA              NA
# 5 1900            MATUU           MACHA… MATU… KIVA… THE VEHICLE OVERTOOK … M      A               10 PASSE…     1 2016-06-25 00:00:00 NA            NA              NA
# 6 2130            NYANDO          HOMA … KATI… PAP … HIT & RUN              M      A               98 PEDES…     1 2016-06-25 00:00:00 NA            NA              NA
# 7 1200            MWEA            KIRIN… MAKU… MUMA… HEAD ON COLLISION      M & F  J/A             10 2 PAS…     3 2016-06-25 00:00:00 NA            NA              NA
# 8 1330            NAKURU          NAKURU KENY… NEAR… HEAD ON COLLISION      M      A               26 M/CYC…     1 2016-06-24 00:00:00 NA            NA              NA
# 9 1930            KAYOLE          NAIRO… EAST… NEAR… THE VEHICLE KNOCKED D… F      15              63 PEDES…     1 2016-06-24 00:00:00 NA            NA              NA
# 10 2030            THIKA           KIAMBU NYER… BLUE… THE MOTOR CYCLE HIT T… M      17              26 P/PAS…     1 2016-06-24 00:00:00 NA            NA              NA

# huh. GENDER is back in as a column. 
# todo -- explain why, because this is a variable in the 2017 data, and the data doesn't know that is the same column.


# illustarte: what if a different variable class?
class(kenya_accidents_2016$`Date DD/MM/YYYY`)
#"POSIXct" "POSIXt"
# says "POSIXct" "POSIXt", which means ....

kenya_accidents_2016 <- kenya_accidents_2016 %>%
  mutate(`Date DD/MM/YYYY` = as.Date(`Date DD/MM/YYYY`))

class(kenya_accidents_2016$`Date DD/MM/YYYY`)
# [1] "Date"
# Now a date class. which means ...

class(kenya_accidents_2017$`Date DD/MM/YYYY`)
# [1] "POSIXct" "POSIXt" 
# but that variable in 2017 data is a different "type" (class)

bind_rows(kenya_accidents_2016, kenya_accidents_2017)
# huh, it works. and it's converted (silently) to dttm. I think this is OK?

# ok what if age is numeric then
kenya_accidents_2016 <- kenya_accidents_2016 %>%
  mutate(AGE = as.numeric(AGE))

class(kenya_accidents_2016$AGE)
#[1] "numeric"
class(kenya_accidents_2017$AGE)
#[1] "character"

bind_rows(kenya_accidents_2016, kenya_accidents_2017)

# Error in `bind_rows()`:
#   ! Can't combine `..1$AGE` <double> and `..2$AGE` <character>.
# Run `rlang::last_trace()` to see where the error occurred.

# explain that error and bits. 
