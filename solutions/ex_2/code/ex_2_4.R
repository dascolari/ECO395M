# Problem 4: hotels_dev.csv and hotels_val.csv
hotels_dev <-  read.csv(file.path(path, "data", "raw", "hotels_dev.csv")) %>% 
  mutate(month = month(arrival_date), 
         distribution_channel = sub("/", "_", distribution_channel), 
         market_segment = sub("/", "_", market_segment), 
         customer_type = sub("-", "_", customer_type))%>% 
  select(- arrival_date) %>%
  dummy_cols() %>% 
  select_if(is.numeric)

set.seed(1134)
nfold = 5
hotels_dev_cv <- hotels_dev %>%
  mutate(fold_id = rep(1:nfold, length=nrow(hotels_dev)) %>% sample)

confusion <- foreach(fold = 1:nfold, .combine='rbind') %do% {
# assigns the 4 folds not equal to the current fold to train set
# assigns the 1 fold equal to the current fold to the test set
dev_train <- hotels_dev_cv %>% 
  filter(fold_id != fold) %>% 
  select(-fold_id)
dev_test <- hotels_dev_cv %>% 
  filter(fold_id == fold) %>% 
  select(-fold_id)

logit_children_small<- 
  glm(children ~ adults + is_repeated_guest +
        market_segment_Aviation + market_segment_Complementary + 
        market_segment_Corporate + market_segment_Direct + 
        market_segment_Groups + market_segment_Offline_TA_TO +  
        customer_type_Contract + customer_type_Group + 
        customer_type_Transient + customer_type_Transient_Party,
      data = dev_train, family=binomial)
phat_small <- 
  predict(logit_children_small, dev_test, type = 'response')
yhat_small <- 
  ifelse(phat_small > 0.2, 1, 0)

logit_children_big <- 
  glm(children ~ . - month, 
      data = dev_train)
phat_big <- 
  predict(logit_children_big, dev_test, type = 'response')
yhat_big <- 
  ifelse(phat_big > 0.2, 1, 0)

logit_children_best <- 
  glm(children ~ (month + adults) * (.) + 
        (average_daily_rate + 
           meal_BB + meal_FB + meal_HB + meal_SC + 
           hotel_City_Hotel  + 
           reserved_room_type_A + reserved_room_type_B + reserved_room_type_C + 
           reserved_room_type_D + reserved_room_type_E + reserved_room_type_F + 
           reserved_room_type_G + reserved_room_type_H) * 
        (lead_time + days_in_waiting_list  + 
           market_segment_Aviation + market_segment_Complementary +
           market_segment_Corporate + 
           market_segment_Direct + market_segment_Groups + 
           deposit_type_Non_Refund + 
           distribution_channel_Corporate + distribution_channel_Direct), 
      data = hotels_dev)
phat_best <- 
  predict(logit_children_best, dev_test, type = 'response')
yhat_best <- 
  ifelse(phat_best > 0.2, 1, 0)

bind_cols(y = dev_test$children, 
          small = yhat_small, 
          big = yhat_big, 
          best = yhat_best) %>% 
  pivot_longer(c(small, big, best), 
               names_to = "model", 
               values_to = "yhat") %>% 
  mutate(f = fold, 
       pos = ifelse(yhat == 1, 1, 0), 
       true = ifelse(yhat == y, 1, 0))
}

performance_matrix <- confusion %>% 
  group_by(model) %>% 
  summarise(true_pos = sum(ifelse(pos == 1 & true == 1, 1, 0)), 
            true_neg = sum(ifelse(pos == 0 & true == 1, 1, 0)), 
            false_pos = sum(ifelse(pos == 1 & true == 0, 1, 0)), 
            false_neg = sum(ifelse(pos == 0 & true == 0, 1, 0)), 
            tpr = round(true_pos/sum(ifelse(y == 1, 1, 0)), 3), 
            fpr = round(false_pos/sum(ifelse(y == 0, 1, 0)),3),
            fdr = round(false_pos/sum(pos), 3), .groups = "drop") %>% 
  kable(caption = "Out-of-Sample Performance")

hotels_val <-  read.csv(file.path(path, "data", "raw", "hotels_val.csv")) %>% 
  mutate(month = month(arrival_date), 
         distribution_channel = sub("/", "_", distribution_channel), 
         market_segment = sub("/", "_", market_segment), 
         customer_type = sub("-", "_", customer_type), 
         reserved_room_type_L = 0)%>% 
  select(- arrival_date) %>%
  dummy_cols() %>% 
  select_if(is.numeric)

phat_val_best <- predict.glm(logit_children_best, hotels_val, type = "response")
phat_val_big <- predict.glm(logit_children_big, hotels_val, type = "response")
phat_val_small <- predict.glm(logit_children_small, hotels_val, type = "response")

validation <- bind_cols(y = hotels_val$children, p_best = phat_val_best, p_big = phat_val_big, p_small = phat_val_small) 
foreach(i = 1:100) %do% {
  yhatbest <- ifelse(phat_val_best > i/100, 1, 0)
  yhatbig <- ifelse(phat_val_big > i/100, 1, 0)
  yhatsmall <- ifelse(phat_val_small > i/100, 1, 0)
  validation <- bind_cols(validation, yhatbest._ = yhatbest, yhatbig._ = yhatbig, yhatsmall._ = yhatsmall)
  colnames(validation) <- gsub("_", as.character(i), colnames(validation))
}

roc <- validation %>% 
  pivot_longer(starts_with("yhat"), 
               names_to = c("model","t"),
               names_sep = "\\.",
               names_prefix = "yhat",
               names_transform = list(t = as.integer),
               values_to = "yhat") %>% 
  mutate(pos = ifelse(yhat == 1, 1, 0), 
         true = ifelse(yhat == y, 1, 0)) %>% 
  group_by(t, model) %>% 
  summarise(true_pos = sum(ifelse(pos == 1 & true == 1, 1, 0)), 
            true_neg = sum(ifelse(pos == 0 & true == 1, 1, 0)), 
            false_pos = sum(ifelse(pos == 1 & true == 0, 1, 0)), 
            false_neg = sum(ifelse(pos == 0 & true == 0, 1, 0)), 
            tpr = round(true_pos/sum(ifelse(y == 1, 1, 0)), 3), 
            fpr = round(false_pos/sum(ifelse(y == 0, 1, 0)),3),
            fdr = round(false_pos/sum(pos), 3), .groups = "drop") 
  
roc_curve <- ggplot(roc) +
  geom_line(aes(x = fpr, y = tpr, color = model)) +
  labs(x = "False Positive Rate", 
       y = "True Positive Rate", 
       title = "Reservation with Children ROC")

set.seed(1134)
hotels_val_20fold <- bind_cols(y = hotels_val$children, p_best = phat_val_best) %>%
  mutate(fold_id = rep(1:20, length=nrow(hotels_val)) %>% sample, 
         yhat = ifelse(phat_val_best > 16/100, 1, 0), 
         pos = ifelse(yhat == 1, 1, 0), 
         true = ifelse(yhat == y, 1, 0)) %>%
  group_by(fold_id) %>% 
  summarise(total_children = sum(y),
            predicted_children = sum(yhat), 
            expected_chilren = sum(p_best),
            true_pos = sum(ifelse(pos == 1 & true == 1, 1, 0)), 
            true_neg = sum(ifelse(pos == 0 & true == 1, 1, 0)), 
            false_pos = sum(ifelse(pos == 1 & true == 0, 1, 0)), 
            false_neg = sum(ifelse(pos == 0 & true == 0, 1, 0)), 
            tpr = round(true_pos/sum(ifelse(y == 1, 1, 0)), 3), 
            fpr = round(false_pos/sum(ifelse(y == 0, 1, 0)),3),
            fdr = round(false_pos/sum(pos), 3), .groups = "drop") %>% 
  select(-starts_with("true", "false"))

hotels_20fold_bar <- hotels_val_20fold %>% 
  pivot_longer(c(total_children, predicted_children, expected_chilren), 
               names_to = "value", 
               values_to = "children") %>% 
ggplot() +
  geom_col(aes(x = value, y = children, fill = value)) +
  facet_wrap(~fold_id) +
  theme(axis.text.x = element_blank(), 
        axis.ticks = element_blank(),
        legend.title = element_blank()) +
  labs(title = "Children in 250 Reservations")

hotels_20fold <- 
  kable(hotels_val_20fold, caption = "20 Trials of 250 Reservations: Detailed Stats")
