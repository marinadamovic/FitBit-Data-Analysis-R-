View(dailyActivity)

# Boxplot, da vidimo osnovne numeričke karakteristike i granice podataka:
plot_list <- list()

for (col in names(dailyActivity[, -c(1,2)])) {
  p <- ggplot(dailyActivity[, -c(1,2)], aes_string(y = col)) + 
    geom_boxplot(fill = "skyblue", color = "darkblue", width=0.3) + 
    labs(title = col, y = col) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      axis.title.y = element_text(face = "bold", size = 12),
      axis.text.y = element_text(size = 10),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    )
  plot_list[[col]] <- p
}

do.call(grid.arrange, c(plot_list, ncol = 5))

# Grupišemo po ID-jevima:
Activity_Summary_Id <- dailyActivity %>% 
  group_by(id) %>% 
  summarize(
    average_steps = round(mean(total_steps), 0),
    average_distance = round(mean(total_distance), 2),
    average_calories = round(mean(calories), 0),
    average_very_active = round(mean(very_active_minutes), 2),
    average_sedentary = round(mean(sedentary_minutes), 2)
  )
#View(Activity_Summary_Id)

# Kategorišemo ispitanike po nivoima aktivnosti definisane preko prosečnog broja 
# pređenih koraka po danu:
Activity_Summary_Id <- Activity_Summary_Id %>% 
  mutate(step_activity_level = case_when(
    average_steps < 5000 ~ "sedentary", 
    average_steps >= 5000 & average_steps < 7500 ~ "low active",
    average_steps >= 7500 & average_steps < 10000 ~ "moderately active",
    average_steps >= 10000 & average_steps < 12500 ~ "active",
    average_steps >= 12500 ~ "highly active"
  ))
Activity_Summary_Id$step_activity_level <- factor(Activity_Summary_Id$step_activity_level,
                                               levels = c('sedentary', 'low active','moderately active', 
                                                          'active', 'highly active'))
#View(Activity_Summary_Id)

# Kružni dijagram - distribucija korisnika po nivoima aktivnosti
steps_pie <- Activity_Summary_Id %>% 
  group_by(step_activity_level) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(perc = `n` / sum(`n`)) %>% 
  arrange(perc) %>%
  mutate(labels = scales::percent(perc))

num_categories <- 5
color_palette <- colorRampPalette(c("#FF6600", "#FFC300", "#FFFF99", "#99CC99", "#006699"))(num_categories)

steps_pie %>% 
  ggplot(mapping = aes(x = "", y = perc, fill = step_activity_level)) +
  geom_col(color = "grey40") +
  geom_label(aes(label = labels),
             position = position_stack(vjust = 0.5),
             show.legend = FALSE) +
  guides(fill = guide_legend(title = "Steps Activity")) +
  coord_polar(theta = "y") +
  scale_fill_manual(values = color_palette) +
  theme_void() +
  theme(legend.key.size = unit(1, "cm"), legend.key.width = unit(1, "cm"), 
        legend.text = element_text(size = 13), legend.title = element_text(size = 15))

# Grupisanje po datumima:
Activity_Summary_Date <- dailyActivity %>% 
  group_by(date) %>% 
  summarise(
    average_steps = round(mean(total_steps), 0),
    average_distance = round(mean(total_distance), 2),
    average_calories = round(mean(calories), 0),
    average_very_active = round(mean(very_active_minutes), 2),
    average_sedentary = round(mean(sedentary_minutes), 2)) %>%
  mutate(weekday = weekdays(date))

# Faktorizacija dana u nedelji:
Activity_Summary_Date$weekday <- factor(Activity_Summary_Date$weekday, 
                                        levels = c("Monday", "Tuesday",
                                                   "Wednesday", "Thursday",
                                                   "Friday", "Saturday", "Sunday"))

#View(Activity_Summary_Date)

# Hi-kvadratni test fitovanja: da li se svakim danom pređe isti broj koraka?
# Poredi posmatrane frekvencije sa očekivanom (srednja vrednost) i odlučuje da li
# značajno odstupaju od nje
# H0: prosečan broj koraka isti je svakim danom u nedelji
# Kada plotujemo, izgleda kao da je to istina, međutim...

Steps_Days <- Activity_Summary_Date %>% 
  group_by(weekday) %>% 
  summarise(avg_steps = round(mean(average_steps), 0)) %>%
  mutate(expected_steps = round(mean(Steps_Days$avg_steps)))
#View(Steps_Days)

ggplot(Steps_Days, aes(x = weekday, y = avg_steps)) +
  geom_bar(stat = "identity", fill = "#99CC99") + 
  labs(title = "Steps per Weekday",
       x = "Weekday",
       y = "Average Steps") +
  theme_bw() +
  theme(plot.title = element_text(size = 20),  
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16)) +
  geom_hline(yintercept = 8386, linetype = "dashed", color = "black")+
  ylim(0,10000)

cont_table <- matrix(c(Steps_Days$avg_steps, Steps_Days$expected_steps), ncol = 2, byrow = FALSE)
#View(cont_table)

chi_squared_test <- chisq.test(cont_table)
chi_squared_test 

# Odbacujemo H0 jer je p-vrednost manja od 0.05
