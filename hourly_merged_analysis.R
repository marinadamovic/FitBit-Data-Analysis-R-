View(hourlyCalories)
View(hourlySteps)

# Spajamo tabele:
merged_hourly <- inner_join(hourlyCalories, hourlySteps, by=c('id', 'activity_hour'))
View(merged_hourly)

# Proveravamo frekvencije:
n_unique(merged_hourly$id)
View(table(merged_hourly$id))

# Dodajemo kolonu hour:
merged_hourly$hour <- hour(merged_hourly$activity_hour)

# Postoji značajna povezanost izmedju koraka i kalorija, 
# što smo i očekivali, a koeficijent je 0.8148579 
correlation <- cor.test(merged_hourly$step_total, merged_hourly$calories, method = 'pearson')
correlation


# Plotujemo: steps per hour
grouped_by_hour <- merged_hourly %>% group_by(hour) %>% summarise(
  average_steps = round(mean(step_total)),
  average_calories = round(mean(calories)))

ggplot(grouped_by_hour, aes(x = hour, y = average_steps)) +
  geom_bar(stat = "identity", fill = "#99CC99") + 
  labs(title = "Steps per Hour",
       x = "Hour",
       y = "Average Steps") +
  theme_bw() +
  theme(plot.title = element_text(size = 20),  
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16)) +
  scale_x_continuous(breaks = grouped_by_hour$hour, labels = grouped_by_hour$hour)

# Plotujemo: cals per hour
ggplot(grouped_by_hour, aes(x = hour, y = average_calories)) +
  geom_bar(stat = "identity", fill = "#99CC99") + 
  labs(title = "Calories per Hour",
       x = "Hour",
       y = "Average Calories") +
  theme_bw() +
  theme(plot.title = element_text(size = 20),  
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16)) +
  scale_y_continuous(limits = c(0, 125)) +
  scale_x_continuous(breaks = grouped_by_hour$hour, labels = grouped_by_hour$hour)

# Modelujemo zavisnost po satima: svaka tačka je jedan sat u danu i postavljen je 
# na svojim prosecima na obe ose
ggplot(grouped_by_hour, aes(x = average_steps, y = average_calories)) +
  geom_point() +
  theme_bw() +
  labs(title = "Steps-Calories Correlation",
       x = "Average Steps per Hour",
       y = "Average Calories per Hour") +
  theme(plot.title = element_text(size = 20),  
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16)) +
  geom_smooth(method = "lm", se = FALSE, color = "#99CC99")

linear_model <- lm(average_calories ~ average_steps, data = grouped_by_hour)
linear_model
