# exercise 1, 4 sclass

#read in olympics_top20 data
sclass <- read.csv(file.path(path_data, "sclass.csv"))

sclass_350 <- filter(sclass, trim == "350")
sclass_63amg <- filter(sclass, trim == "63 AMG")

set.seed(30)
sc350_split <-  initial_split(sclass_350, prop=0.8)
sc350_train <- training(sc350_split)
sc350_test  <- testing(sc350_split)

sc350_rmse <- foreach(n = 2:100, .combine = 'rbind') %dopar% {
  knn_sc350 = knnreg(price ~ mileage, data = sc350_train, k = n)
  modelr::rmse(knn_sc350, sc350_test)
} %>% as.data.frame%>%
  mutate(k=row_number())%>%
  arrange(V1)%>%
  mutate(kmin = k[1])

# add optimal knn model predictions to the test set, calling now plot
knn_sc350 = knnreg(price ~ mileage, data = sc350_train, k = sc350_rmse$k[1])
sc350_plot <- sc350_test %>%
  mutate(kmin_fit = predict(knn_sc350, sc350_test))

# plot rmse vs. difference values of k to visualize optimal 
rmse_350 <- ggplot(sc350_rmse) +
  geom_line(aes(x = k, y = V1)) +
  geom_vline(xintercept = sc350_rmse$k[1], color = "#FF9241", size = 1) +
  labs(y = "RMSE", title = "Trained Model RMSE \n with Testing Data: S-Class 350")

# plot optimal knn model for optimal k with test set data 
fit_350 <- ggplot(sc350_plot) +
  geom_line(aes(x = mileage, y = kmin_fit), color='#8668FF', size = 1) + 
  geom_point(aes(x = mileage, y = price)) +
  labs(x = "Mileage", y = "Price($)", title = "Prices by Mileage Data and \n Predictions: S-Class 350")


set.seed(40)
sc63amg_split <-  initial_split(sclass_63amg, prop=0.8)
sc63amg_train <- training(sc63amg_split)
sc63amg_test  <- testing(sc63amg_split)

sc63amg_rmse <- foreach(n = 2:150, .combine = 'rbind') %dopar% {
  knn_sc63amg = knnreg(price ~ mileage, data = sc63amg_train, k = n)
  modelr::rmse(knn_sc63amg, sc63amg_test)
} %>% as.data.frame%>%
  mutate(k=row_number())%>%
  arrange(V1)%>%
  mutate(kmin = k[1])

# add optimal knn model predictions to the test set, calling now plot
knn_sc63amg = knnreg(price ~ mileage, data = sc63amg_train, k = sc63amg_rmse$k[1])
sc63amg_plot <- sc63amg_test %>%
  mutate(kmin_fit = predict(knn_sc63amg, sc63amg_test))

# plot rmse vs. difference values of k to visualize optimal 
rmse_63amg <- ggplot(sc63amg_rmse) +
  geom_line(aes(x = k, y = V1)) +
  geom_vline(xintercept = sc63amg_rmse$k[1], color = '#FF9241', size = 1) +
  labs(y = "RMSE", title = "Trained Model RMSE with \n Testing Data: S-Class 63 AMG")

# plot optimal knn model for optimal k with test set data 
fit_63amg <- ggplot(sc63amg_plot) +
  geom_line(aes(x = mileage, y = kmin_fit), color = '#8668FF', size = 1) + 
  geom_point(aes(x = mileage, y = price)) +
  labs(x = "Mileage", y = "Price($)", title = "Prices by Mileage Data and \n Predictions: S-Class 63 AMG")

scfit_knn_plots <- ggarrange(fit_350, fit_63amg)

scrmse_knn_plots <- ggarrange(rmse_350, rmse_63amg)
