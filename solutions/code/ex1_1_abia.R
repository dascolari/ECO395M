# exercise 1, 1 ABIA
# author: David Scolari
# instructor: James Scott
# date started: 2/8/22
# due date: 2/11/22

#read in abia data
abia <- read.csv(file.path(path_data, "ABIA.csv"))

#counts the different types of delays
#not clear if there is overlap in the types of delays
abia_analysis <- abia %>%
  mutate(day_portion = case_when(CRSDepTime>=400 & CRSDepTime < 1100 ~ "morn", 
                                 CRSDepTime>=1100 & CRSDepTime < 1600 ~ "mid",
                                 CRSDepTime>=1600 & CRSDepTime < 2100 ~ "eve",
                                 CRSDepTime>=2100 | CRSDepTime < 400 ~ "night"),
         season = case_when(Month == 3 & DayofMonth >= 20 ~ "spring",
                            Month == 4 | Month == 5 ~ "spring",
                            Month == 6 & DayofMonth < 20 ~ "spring", 
                            Month == 6 & DayofMonth >= 20 ~ "summer",
                            Month == 7 | Month == 8 ~ "summer",
                            Month == 9 & DayofMonth < 22 ~ "summer",
                            Month == 9 & DayofMonth >= 22 ~ "fall",
                            Month == 10 | Month == 11 ~ "fall",
                            Month == 12 & DayofMonth < 21 ~ "fall", 
                            Month == 12 & DayofMonth >= 21 ~ "winter",
                            Month == 1 | Month == 2 ~ "winter",
                            Month == 3 & DayofMonth < 20 ~ "winter"))%>%
  group_by(day_portion, season)%>%
  summarise(mean_delay = mean(DepDelay, na.rm = TRUE), cancellations = sum(Cancelled), .groups = 'drop')%>%
  mutate(dp = case_when(day_portion == "morn" ~ 1, 
                        day_portion == "mid" ~ 2,
                        day_portion == "eve" ~ 3,
                        day_portion == "night" ~ 4), 
         s = case_when(season == "spring" ~ 1, 
                        season == "summer" ~ 2,
                        season == "fall" ~ 3,
                        season == "winter" ~ 4))%>%
  arrange(s, desc(dp))%>%
  mutate(day_portion = fct_reorder(day_portion, dp), season = fct_reorder(season, s))

mean_delay_season <- ggplot(abia_analysis) +
  geom_col(aes(x = day_portion, y = mean_delay), fill='#FDB580') +
  coord_flip() +
  facet_wrap(season~., ncol = 1) +
  labs(y = "Average Delay", x = "", title = "Average Flight Delay by Scheduled Time of Day and Season")

total_cancel_season <- ggplot(abia_analysis) +
  geom_col(aes(x = day_portion,y = cancellations), fill = '#9980FD') +
  coord_flip() +
  facet_wrap(season~., ncol = 1) +
  labs(y = "Total Cancellations", x = "", title = "Cancellations by Scheduled Time of Day and Season")

season_sofly <- ggarrange(mean_delay_season, total_cancel_season)

