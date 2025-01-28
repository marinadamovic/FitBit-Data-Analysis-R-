View(dailySleep)

# Preostaje nam 22 korisnika sa sledećim frekvencijama pojavljivanja:
View(table(dailySleep$id))
hist(table(dailySleep$id))

# Vreme spavanja prati približno normalnu raspodelu, očekivano, 
# i to sa više outlier-a kraćeg nego dužeg spavanja:
hist(dailySleep$total_minutes_asleep, breaks = 50, freq=FALSE)
set.seed(1)
dens <- density(dailySleep$total_minutes_asleep)
lines(dens)

# FIltriramo kratke sesije spavanja da vidimo koliko osoba je prisutno: 10
short_sessions <- dailySleep %>% filter(total_minutes_asleep < 200) 
nrow(table(short_sessions$id))

# Boxplots:
plot_list1 <- list()
for (col in names(dailySleep[, -c(1,2)])) {
  p <- ggplot(dailySleep[, -c(1,2)], aes_string(y = col)) + 
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
  plot_list1[[col]] <- p
}
do.call(grid.arrange, c(plot_list1, ncol = 3))

# Kategorizujemo ljude u 4 grupe po prosecnoj duzini spavanja:
Sleep_Summary_Id <- dailySleep %>% 
  group_by(id) %>% 
  summarize(average_asleep = round(mean(total_minutes_asleep), 0),
            average_awake = round(mean(total_minutes_not_asleep))) %>%
  mutate(type = case_when(
    average_asleep < 300 ~ "extreme short", 
    average_asleep >= 300 & average_asleep < 420 ~ "short",
    average_asleep >= 420 & average_asleep < 600 ~ "normal",
    average_asleep >= 600 ~ "long")) 
Sleep_Summary_Id$type <- factor(Sleep_Summary_Id$type,
                                levels = c('extreme short', 'short',
                                           'normal','long'))  

#View(Sleep_Summary_Id)

# Kruzni dijagram - distribucija korisnika po proseku spavanja:
sleep_pie <- Sleep_Summary_Id %>% 
  group_by(type) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(perc = `n` / sum(`n`)) %>% 
  arrange(perc) %>%
  mutate(labels = scales::percent(perc))

num_categories <- 4
color_palette <- colorRampPalette(c("#FFC300", "#FFFF99", "#99CC99", "#006699"))(num_categories)

sleep_pie %>% 
  ggplot(mapping = aes(x = "", y = perc, fill = type)) +
  geom_col(color = "grey40") +
  geom_label(aes(label = labels),
             position = position_stack(vjust = 0.5),
             show.legend = FALSE) +
  guides(fill = guide_legend(title = "Sleep Types")) +
  coord_polar(theta = "y") +
  scale_fill_manual(values = color_palette) +
  theme_void() +
  theme(legend.key.size = unit(1, "cm"), legend.key.width = unit(1, "cm"), 
        legend.text = element_text(size = 13), legend.title = element_text(size = 15))

# T-test: da li preporučeni broj sati sna implicira i kvalitetniji san?
under_7h <- Sleep_Summary_Id %>% filter(average_asleep < 420) 
over_7h <- Sleep_Summary_Id %>% filter(average_asleep >= 420)
result<-t.test(under_7h$average_awake, over_7h$average_awake)
result
