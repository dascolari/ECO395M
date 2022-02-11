# exercise 1, 3 olympics_top20

#read in olympics_top20 data
olympics <- read.csv(file.path(path_data, "olympics_top20.csv"))


# The data in olympics_top20.csv contains information on every Olympic medalist in the top 20 sports by participant count, all the way back to 1896. Use these data to answer the following questions. (The names of the columns should be self-explanatory.)
# 
# A) What is the 95th percentile of heights for female competitors across all Athletics events (i.e., track and field)? Note that sport is the broad sport (e.g. Athletics) whereas event is the specific event (e.g. 100 meter sprint).

sport_heights <- olympics %>%
  filter(sex == "F")%>%
  group_by(sport)%>%
  summarise(height = mean(height), .groups = 'drop')%>%
  arrange(desc(height))%>%
  mutate(q95 = quantile(height, .95))%>% # it's either this mutated var
  slice_tail(prop = .95) # or the height of the first obs
sport_heights$height[1]

# depending on the definition of percentile
  
# B) Which single women's event had the greatest variability in competitor's heights across the entire history of the Olympics, as measured by the standard deviation?

event_sdheights <- olympics %>%
  filter(sex == "F")%>%
  group_by(event)%>%
  summarise(sd_height = sd(height))%>%
  arrange(desc(sd_height))


#   C) How has the average age of Olympic swimmers changed over time? Does the trend look different for male swimmers relative to female swimmers? Create a data frame that can allow you to visualize these trends over time, then plot the data with a line graph with separate lines for male and female competitors. Give the plot an informative caption answering the two questions just posed.

swim_age <- olympics %>%
  group_by(year, sex)%>%
  summarise(age = mean(age), .groups = 'drop')%>%
  mutate(sex = case_when(sex == "M" ~"Male", 
                         sex == "F" ~"Female"))

swim_age_tplot <- ggplot(swim_age) +
  geom_line(aes(x = year, y = age, group = sex, color = sex), size = 1) +
  labs(x = "Year", y = "Average Age", title = "Average Swimmer Age at the Olympics: 1896 - 2016") +
  scale_colour_manual(
    values = c("#FF9241", "#8668FF"),
    aesthetics = "colour",
    breaks = waiver(),
    na.value = "grey50"
  )
