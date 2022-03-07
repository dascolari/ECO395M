# Problem 2: Saratoga Houses

# use base R dataset on saratoga houses
data(SaratogaHouses)


##############################
# CLEANING THE SARATOGA DATSET
##############################

# turning categorical var values into valid var names
# this will ensure model.matrix does not produce invalid var names
SaratogaHouses <- SaratogaHouses %>% 
  mutate(heating = 
           recode(heating, 
                  "hot air" = "hot_air", 
                  "hot water/steam"  = "hot_water_steam"), 
         sewer = 
           recode(sewer, 
                  "public/commercial" = "public_commercial"
                        ))

nfold = 5

set.seed(30)
saratoga_folds <- SaratogaHouses %>%
  mutate(fold_id = rep(1:nfold, length=nrow(SaratogaHouses)) %>% sample)

rmse_cv <- foreach(fold = 1:nfold, .combine='rbind') %dopar% {
 
  # filtering by fold_id according to the fold of current loop
  # assigns the 4 folds not equal to the current fold to train set
  # assigns the 1 fold equal to the current fold to the test set
  folds_train <- saratoga_folds %>% 
    filter(fold_id != fold)
  folds_test <- saratoga_folds %>% 
    filter(fold_id == fold)
  
  # separate out response from both the train and test sets
  ytrain = folds_train$price
  ytest = folds_test$price
  
  # separate out features for scaling by sd of TRAIN set
  xtrain = model.matrix(~ . - 1 - price, data=folds_train)
  xtest = model.matrix(~ . - 1 - price, data=folds_test)
  
  # set scale by the train set 
  scale_train = apply(xtrain, 2, sd)
  
  # TRAIN
  # a pipe that:
  #   scales TRAINING features by TRAINING sds
  #   recombines scaled features with un-scaled TRAIN y response 
  folds_train_scale <- xtrain %>% 
    scale(scale = scale_train) %>% 
    bind_cols(price = ytrain) %>% 
    as.data.frame(select(price, everything()))
  
  # TEST
  # a pipe that:
  #   scales TESTING features by TRAINING sds
  #   recombines scaled features with un-scaled TEST y response
  folds_test_scale <- xtest %>% 
    scale(scale = scale_train) %>%
    bind_cols(price = ytest) %>% 
    as.data.frame(select(price, everything()))
  
  # baseline lm_medium
  lm_medium = 
    lm(price ~ 
         lotSize + age + livingArea + 
         pctCollege + bedrooms + fireplaces + 
         bathrooms + rooms + heating + 
         fuel + centralAir, 
       data=folds_train)
  
  # stepwise selection to pick the best slate of tripple interactions
  lm_step = 
    step(lm_medium, scope=~(lotSize + age + livingArea + 
                              pctCollege + bedrooms + fireplaces + 
                              bathrooms + rooms + heating + 
                              fuel + centralAir)^2, direction = "both")
  
  # knn model specification
  klist <- foreach(K = 2:100, .combine = 'rbind') %dopar%{
  knn <- knnreg(price ~ 
           lotSize + age + landValue + livingArea +
           pctCollege + bedrooms + fireplaces +
           bathrooms + rooms + heatinghot_air +
           heatinghot_water_steam + heatingelectric +
           fuelelectric + fueloil + sewerpublic_commercial +
           sewernone + waterfrontNo + newConstructionNo +
           centralAirNo,
         data = folds_train_scale, k=K)
    bind_cols(rmse_knn = modelr::rmse(knn, data = folds_test_scale), k = K, f = fold) 
  }
  klist %>% 
    arrange(rmse_knn) %>% 
    slice_head(n = 1) %>% 
    bind_cols(rmse_lmstep = modelr::rmse(lm_step, data = folds_test), 
              rmse_lmmedium = modelr::rmse(lm_medium, data = folds_test)) %>% 
    select(f, k, everything())
}

fit <- rmse_cv %>% 
  pivot_longer(starts_with("rmse"), 
               names_to = "model",
               names_prefix = "rmse_",
               values_to = "rmse")%>% 
  group_by(model) %>% 
  summarise(rmse = mean(rmse), 
            k_optimal = round(mean(k), 0), .groups = 'drop') %>% 
  mutate(m = case_when(model == "knn"~3, 
                       model == "lmmedium"~1, 
                       model == "lmstep"~2), 
         model = fct_reorder(model, m), 
         k_optimal = ifelse(model != "knn", NA, k_optimal)) %>% 
  arrange(model) %>% 
  select(-m) %>% 
  kable(caption = "Model Fit Comparison")

fit

##########################################################

