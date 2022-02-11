# exercise 1, 2 billboard
# author: David Scolari
# instructor: James Scott
# date started: 2/8/22
# due date: 2/11/22

#read in billboard data
billboard <- read.csv(file.path(path_data, "billboard.csv"))

# Prompt
# Part A: Make a table of the top 10 most popular songs since 1958, 
# as measured by the total number of weeks that a song spent on the 
# Billboard Top 100.

# Give your table a short caption describing what is shown in the table
top10_1958_2021 <- billboard%>%
  group_by(song, performer) %>%
  summarise(count = length(song), .groups = 'drop')%>%
  arrange(desc(count))%>%
  slice_head(n = 10)

# Part B: Is the "musical diversity" of the Billboard Top 100 changing 
# over time? Let's find out. 
# 

# Give the figure an informative caption in which you explain what is 
#shown in the figure and comment on any interesting trends you see.
musical_diversity <- billboard %>%
  filter(year > 1958 & year < 2021)%>%
  group_by(year)%>%
  summarise(unique_hits = length(unique(song_id)))

musical_diversity_tplot <- ggplot(musical_diversity) +
  geom_line(aes(x=year, y=unique_hits), size = 1,  color = '#8668FF') +
  labs(x = "Year", y = "Unique Hits", title = "Number of Unique Hits in Each Year: 1958 - 2020")

# Part C: Let's define a "ten-week hit" as a single song that appeared on the 
# Billboard Top 100 for at least ten weeks.
# There are 19 artists in U.S. musical history since 1958 who have had at least 
# 30 songs that were "ten-week hits." 

# Give the plot an informative caption in which you explain what is shown. 

tenwk_hits <- billboard %>%
  group_by(song, performer) %>%
  summarise(count = length(song), .groups = 'drop') %>%
  filter(count >= 10) %>%
  group_by(performer) %>%
  summarise(tenweek_hits = length(performer), .groups = 'drop') %>%
  filter(tenweek_hits >= 30) %>%
  arrange(desc(tenweek_hits))

tenwk_hits_bplot <- ggplot(tenwk_hits) +
  geom_col(aes(fct_reorder(performer,
                                   tenweek_hits),
               tenweek_hits), fill = '#9980FD') +
  labs(x = "Artist",
       y = "Ten-Week Hits", 
       title = "Artists with more than 30 Ten-Week Hits") +
  coord_flip() 





