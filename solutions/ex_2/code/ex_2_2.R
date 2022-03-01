# Problem 2: Saratoga Houses
library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)

# use base R dataset on saratoga houses
data(SaratogaHouses)

# split into training and testing sets
saratoga_split = initial_split(SaratogaHouses, prop = 0.8)
saratoga_train = training(saratoga_split)
saratoga_test = testing(saratoga_split)

# model specification
lm_medium = 
  lm(price ~ 
       lotSize + age + livingArea + 
       pctCollege + bedrooms + fireplaces + 
       bathrooms + rooms + heating + 
       fuel + centralAir, 
     data=saratoga_train)

lmcrush = 
  lm(price ~ . + 
       lotSize*bedrooms*bathrooms, 
     data = saratoga_test)

lmcrush_step = 
  step(lmcrush, scope=~(.)^3)

# view coefficients used by each model
coef(lm_medium)
coef(lmcrush)
coef(lmcrush_step)

# evaluate model fit using rmse
rmse(lm_medium, saratoga_test)
rmse(lmcrush, saratoga_test)
rmse(lmcrush_step, saratoga_test)