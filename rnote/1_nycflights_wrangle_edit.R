##### needed packages:
library(tidyverse)
library(mosaic)

#load nyc data set
nycflights13 = read.csv("/Users/davidscolari/Dropbox/grad_school/3_Spring22/datmin/nycflights13.csv")

##### summarize variables  #####
nycflights13 %>%
  summarize(mean_dep_delay = mean(dep_delay))

# Why NA? because 8255 flights have missing (NA) values
nycflights13 %>% 
  summarize(favstats(dep_delay))

# we can add na.rm=TRUE to summaries to ignore these missing values
# what's the specifics of na.rm=TRUE
nycflights13 %>%
  summarize(mean_dep_delay = mean(dep_delay, na.rm=TRUE))


##### Grouping by more than one variable #####

by_origin_monthly = nycflights13 %>% 
  group_by(origin, month) %>% 
  summarize(count = n(),
            mean_dep_delay = mean(dep_delay, na.rm=TRUE))
by_origin_monthly

# now let's make a bar plot
# factor tells R to treat month as a categorical variable,
# even though it's labeled with numbers
ggplot(by_origin_monthly) + 
  geom_col(aes(x=factor(month), y=mean_dep_delay)) + 
  facet_wrap(~origin)

# all three airports worst in summer and winter holidays,
# best in the fall

#####  mutate existing variables  #####

# create 'gain' variable from two existing variables
nycflights13 = nycflights13 %>%
  mutate(gain = dep_delay - arr_delay)

# Histogram of gain variable
ggplot(nycflights13) +
  geom_histogram(aes(x = gain), binwidth=5)

# which routes from NYC gained the most time in the air, on average?
# need na.rm=TRUE because of missing values
nycflights13 %>%
  group_by(dest) %>%
  summarize(mean_gain = mean(gain, na.rm=TRUE)) %>%
  arrange(desc(mean_gain))

# create multiple new variables at once in the same mutate() 
# within same mutate() code we can refer to new variables just created
nycflights13 = nycflights13 %>% 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )

# now which routes gained the most per hour?
nycflights13 %>%
  group_by(dest) %>%
  summarize(mean_gain_per_hour = mean(gain_per_hour, na.rm=TRUE)) %>%
  arrange(desc(mean_gain_per_hour))

billboard = read.csv("/Users/davidscolari/Dropbox/grad_school/3_Spring22/datmin/billboard.csv")


#which songs spent the most weeks on the billboard hot 100

bill_count = billboard %>%
  filter(year == 2020) %>%
  group_by(song_id) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

bill_check = billboard %>%
  filter(year == 2020) %>%
  group_by(song_id) %>%
  summarise(count = max(weeks_on_chart))%>%
  arrange(desc(count))

top_songs_2020 = billboard %>%
  filter(year == 2020)%>%
  group_by(song_id)%>%
  filter(n()>45)

#making some line graphs of the songs that were on billboard for more than 45 weeks
ggplot(top_songs_2020) +
  geom_line(aes(x=week, y=week_position)) +
  facet_wrap(~song_id) +
  ylim(100, 1)
