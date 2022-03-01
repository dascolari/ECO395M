# Problem 1: capmetro_UT.csv

capmetro <- read.csv(here(file.path("data", "raw", "capmetro_UT.csv")))

# panel of line graphs that plots: 
  # average boardings grouped by hour of the day
  # facet by day of week.
  # color by month
capmetro %>% 
  group_by(hour_of_day, day_of_week, month) %>% 
  summarise(mean_boardings = mean(boarding), .groups = 'drop') %>% 
  mutate(day_num = case_when(day_of_week == "Sun" ~ 1, 
                             day_of_week == "Mon" ~ 2,
                             day_of_week == "Tue" ~ 3,
                             day_of_week == "Wed" ~ 4,
                             day_of_week == "Thu" ~ 5,
                             day_of_week == "Fri" ~ 6,
                             day_of_week == "Sat" ~ 7), 
         month_num = case_when(month == "Sep" ~ 9, 
                               month == "Oct" ~ 10, 
                               month == "Nov" ~ 11), 
         day_of_week = fct_reorder(day_of_week, day_num), 
         month = fct_reorder(month, month_num)) %>% 
  ggplot() +
  geom_line(aes(x = hour_of_day, y = mean_boardings, color = month)) +
  facet_wrap(~day_of_week, ncol = 1) +
  xlab("Hour of Day") +
  ylab("Mean Boardings") +
  ggtitle("UT CapMetro Rides: Average Boardings by Hour") +
  guides(color = guide_legend(NULL)) +
  theme(plot.background = element_rect(fill = "#000000", color = "#000000"), 
        panel.background = element_rect(fill = "#444444"), 
        legend.background = element_rect(fill = "#333333"),
        legend.key = element_rect(fill = "#333333"),
        strip.background = element_rect(fill = "#333333"),
        strip.text = element_text(color = "#FFFFFF"),
        panel.grid = element_line(color = "#696969"), 
        text = element_text(color = "#FFFFFF"))
  

  # theme(plot.background = element_rect(fill = "black"),
  #       panel.background = element_rect(fill = "darkgrey", color = "white"), 
  #       title = element_text(color = "white"))

ggsave("boardings_hour.png", 
       path = file.path(path, "output"), 
       height = 20, 
       width = 15, 
       units = "cm", 
       device = png)

# panel of scatter plots showing boardings (y) vs. temperature (x) in each 15-minute window
  # faceted by hour of the day
  # colored according to whether it is a weekday or weekend
capmetro %>% 
  ggplot() +
  geom_point(aes(x = temperature, y = boarding, color = weekend)) +
  facet_wrap(~hour_of_day) +
  guides(color = guide_legend(NULL)) +
  xlab("Temperature") +
  ylab("Boardings") +
  ggtitle("UT CapMetro Rides: Boardings by Temperature") +
  theme(plot.background = element_rect(fill = "#000000", color = "#000000"), 
        panel.background = element_rect(fill = "#444444"), 
        legend.background = element_rect(fill = "#333333"),
        legend.key = element_rect(fill = "#333333"),
        strip.background = element_rect(fill = "#333333"),
        strip.text = element_text(color = "#FFFFFF"),
        panel.grid = element_line(color = "#696969"), 
        text = element_text(color = "#FFFFFF"))

ggsave("boardings_temp.png", 
       path = file.path(path, "output"), 
       height = 20, 
       width = 15, 
       units = "cm", 
       device = png)

# Notes:
# All you need to turn in here are the two figures and their captions. Keep each figure + caption to a single page combined (i.e. two pages, one page for first figure + caption, a second page for second figure + caption).
