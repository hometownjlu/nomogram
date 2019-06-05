all_data %>% 
  dplyr::count(Match_Status, Year) %>% 
  spread(key = Match_Status, value = n) %>% 
  mutate(sum = `0`+`1`,
         `0` = `0`/sum,
         `1` = `1`/sum) %>% 
  select(-sum) %>% 
  tidyr::gather(value=match_proportion, key = Match_Status, `0`, `1`) %>% 
  ggplot(aes(x = Year, y = match_proportion, fill = Match_Status,
             label = paste(round(100 * match_proportion,1),"%"))) +
  # geom_bar(col="black", stat = "identity") +
  geom_col(col="black", position="fill") +
  geom_text(position = "stack",  vjust=1.5, size = 3) +
  labs(x="Year", y="Matching proportion in %", fill = "Matching") +
  theme_minimal()+
  scale_y_continuous(breaks = seq(0,1, by=0.25), labels = seq(0,1, by=0.25)*100)


  summarise(prop_match =)

class(all_data)

temp <- tibble(x = c(rep(1,4), rep(2,4)),
               y = sample(c(0,1), 8, replace = TRUE))
library(tidyverse)
temp %>% 
  dplyr::count(y)


str(lm.fit3)
