# Problem 3: german_credit.csv

german_credit <- read.csv(here(file.path("data", "raw", "german_credit.csv")))

german_split = initial_split(german_credit, prop = 0.8)
german_train = training(german_split)
german_test = testing(german_split)

german_credit %>% 
  group_by(history) %>% 
  summarise(default_probability = mean(Default)) %>% 
  ggplot() +
  geom_col(aes(x = history, y = default_probability))

logit_default <- 
  glm(Default ~ 
        duration + amount + installment + 
        age + history + purpose + foreign, 
      data = german_train, family=binomial)

phat_default_test <- predict(logit_default, german_test, type = 'response')
yhat_default_test <- ifelse(phat_default_test > 0.5, 1, 0)

confusion_default_logit <- table(y = german_test$Default, 
                                yhat = yhat_default_test)

cmatrix <- kable(confusion_default_logit, caption = "Confusion Matrix")

cmatrix

# What do you notice about the history variable vis-a-vis predicting defaults? What do you think is going on here? In light of what you see here, do you think this data set is appropriate for building a predictive model of defaults, if the purpose of the model is to screen prospective borrowers to classify them into "high" versus "low" probability of default? Why or why not---and if not, would you recommend any changes to the bank's sampling scheme?