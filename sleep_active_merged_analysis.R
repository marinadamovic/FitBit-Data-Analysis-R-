View(dailyActivity)
View(dailySleep)

# Spajanje ove dve tabele:
merged_sleep_activity <- inner_join(dailyActivity, dailySleep, by = c("id", "date"))
View(merged_sleep_activity)

# T-test: ispod i iznad 10k koraka da li utiče na spavanje (p>0.05, ne utice)
under_10k <- merged_sleep_activity %>% filter(total_steps < 10000)
over_10k <- merged_sleep_activity %>% filter(total_steps >= 10000)
t_test_result <- t.test(under_10k$total_minutes_not_asleep, over_10k$total_minutes_not_asleep,
                         paired = FALSE, conf.level = 0.95)
print(t_test_result)

# T-test: da li 45 minuta fizicke aktivnosti u toku dana utice na budne minute?
# (0.002206<0.05 - H0 odbacena, u proseku zaspimo brze za 13,5 minuta ako smo 45 min aktivni u toku dana)
under_45min <- merged_sleep_activity %>% filter(very_active_minutes < 45) 
over_45min <- merged_sleep_activity %>% filter(very_active_minutes >= 45)
t_test_result <- t.test(over_45min$total_minutes_not_asleep, under_45min$total_minutes_not_asleep, paired = FALSE, conf.level = 0.95)
print(t_test_result)

# Fiserov test: kategorije dana po aktivnosti (vise od 5k koraka) i po snu (dovoljno/nedovoljno), da li postoji zavisnost
# H0:ne postoji zavisnost izmedju ovih kategorija - odbacena, p<0.05 dakle postoji zavisnost
merged_sleep_activity <- merged_sleep_activity %>% mutate(sleep_duration = case_when(
  total_minutes_asleep < 420 ~ 'enough sleep',
  total_minutes_asleep >= 420 ~ 'not enough sleep'), 
  enough_steps = case_when(total_steps < 5000 ~ 'enough steps', 
                           total_steps >= 5000 ~ 'not enough steps'))

cont_table <- table(merged_sleep_activity$sleep_duration, merged_sleep_activity$enough_steps)
result <- fisher.test(cont_table)
result

