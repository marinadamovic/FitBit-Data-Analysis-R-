library(tidyverse)
library(janitor)
library(skimr)
library(here)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(reshape2)
library(gridExtra)

# Učitavanje podataka:
dailyActivity <- read_csv(file = "dailyActivity_merged.csv")
dailySleep <- read_csv(file = "sleepDay_merged.csv")
hourlyCalories <- read_csv(file ="hourlyCalories_merged.csv")
hourlySteps <- read_csv(file = "hourlySteps_merged.csv")

# Pregled tabela:
# View(dailyActivity)
# View(dailySleep)
# View(hourlyCalories)
# View(hourlySteps)

# Standardizovanje imena kolona:
dailyActivity <- clean_names(dailyActivity)
dailySleep <- clean_names(dailySleep)
hourlyCalories <- clean_names(hourlyCalories)
hourlySteps <- clean_names(hourlySteps)

# Brišemo kolone koje nećemo posmatrati:
dailyActivity <- dailyActivity %>% select(-tracker_distance, -logged_activities_distance,
                                          -very_active_distance, -moderately_active_distance, 
                                          -light_active_distance, -sedentary_active_distance,
                                          -fairly_active_minutes, -lightly_active_minutes)
dailySleep <- dailySleep %>% select(-total_sleep_records) %>% 
  mutate(total_minutes_not_asleep = total_time_in_bed - total_minutes_asleep)

# Pregled strukture svake tabele:
# summary(dailyActivity)
# summary(dailySleep)
# summary(hourlyCalories)
# summary(hourlySteps)

# Formatiranje datuma:
dailyActivity <- dailyActivity %>% mutate(activity_date = as.POSIXct(dailyActivity$activity_date, format = "%m/%d/%Y"))
dailySleep <- dailySleep %>% mutate(sleep_day = as.POSIXct(dailySleep$sleep_day, format = "%m/%d/%Y"))
hourlyCalories <- hourlyCalories %>% mutate(activity_hour = as.POSIXct(hourlyCalories$activity_hour, format = "%m/%d/%Y %I:%M:%S %p", tz = Sys.timezone()))
hourlySteps <- hourlySteps %>% mutate(activity_hour = as.POSIXct(hourlySteps$activity_hour, format = "%m/%d/%Y %I:%M:%S %p", tz = Sys.timezone()))

# Lociranje NA vrednosti kako bismo ih na odgovarajući način dopunili/obrisali: (nije ih bilo)
sum(is.na(dailyActivity))
sum(is.na(dailySleep))
sum(is.na(hourlyCalories))
sum(is.na(hourlySteps))

# Lociranje duplikata (bilo je 3 identična zapisa u dailySleep)
nrow(distinct(dailyActivity)) == nrow(dailyActivity)
nrow(distinct(dailySleep)) == nrow(dailySleep)
nrow(distinct(hourlyCalories)) == nrow(hourlyCalories)
nrow(distinct(hourlySteps)) == nrow(hourlySteps)

dailySleep <- dailySleep %>% distinct()   

# Kako frekvencije nisu u potpunosti konzistentne, brišemo one profile koji 
# imaju znatno manje zapisa:
dailyActivity <- dailyActivity %>%
  group_by(id) %>%
  filter(n() >= 15) %>%
  ungroup()

dailySleep <- dailySleep %>%  # iznad 3 ne predstavljaju outliere, ne kvare prosek
  group_by(id) %>%
  filter(n() >= 3) %>%
  ungroup()

hourlyCalories <- hourlyCalories %>%
  group_by(id) %>%
  filter(n() >= 360) %>%
  ungroup()

hourlySteps <- hourlySteps %>%
  group_by(id) %>%
  filter(n() >= 360) %>%
  ungroup()

# Filtriramo nerelevantne zapise:
dailyActivity <- dailyActivity %>% filter(total_steps >= 100) %>% 
  filter(calories >=1000)

# Frekvencije pojavljivanja ID-jeva u tabelama 
n_unique(dailyActivity$id)
n_unique(dailySleep$id)
n_unique(hourlyCalories$id)
n_unique(hourlySteps$id)

#View(table(dailyActivity$id))
#View(table(dailySleep$id))
#View(table(hourlyCalories$id))
#View(table(hourlySteps$id))

# Menjamo ime kolone za datum u prve dve tabele zbog kasnijeg spajanja:
names(dailyActivity)[names(dailyActivity) == "activity_date"] <- "date"
names(dailySleep)[names(dailySleep) == "sleep_day"] <- "date"
