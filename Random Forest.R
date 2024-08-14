# Tidyverse packages
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

# Tidymodels packages, spelled out individually for clarity
library(parsnip)
library(yardstick)
library(recipes)
library(rsample)
library(tune)
library(workflows)
library(rpart)
library(tune)
library(broom)
library(caret)
library(tibble)


#Additional libaries
library(tune)
library(vip)
library(corrplot)
library(themis)
library(progress)
library(xgboost)
library(baguette)
library(kknn)
library(car)


## ----message=FALSE, warning=FALSE-------------------------------------------------------------------------------
setwd("C:\\Users\\nayrb\\OneDrive - London School of Economics\\Stanford Summer School\\Summer Session\\Stats 202\\Project")
test_data <- read_csv("data/test.csv",show_col_types = FALSE)
train_data <- read_csv("data/training.csv",show_col_types = FALSE)
train_data$relevance <- as.factor(train_data$relevance) # Setting the target variable as a factor
train_data$is_homepage <- as.factor(train_data$is_homepage)
test_data$is_homepage <- as.factor(test_data$is_homepage)


## ----message=FALSE, warning=FALSE,purl=TRUE---------------------------------------------------------------------
# Fold validation
folds <- vfold_cv(train_data, v=5)


## ----purl=TRUE--------------------------------------------------------------------------------------------------
# Creating the RF recipe
# Creating the RF recipe
rec_rf <- 
    recipe(relevance ~., data = train_data) %>% 
    step_normalize(all_numeric_predictors()) %>%
    step_dummy(is_homepage) %>% #is_homepage as a categorical variable
    step_zv(all_nominal_predictors()) %>%
    step_nzv(all_nominal_predictors())

# Building the RF model
forest_model <- 
  rand_forest(mtry = tune()) %>% 
  set_engine("randomForest", trees = tune() ,tree_depth = tune()) %>% 
  set_mode("classification")

# Creating the workflow

wflow_rf <- 
  workflow() %>% 
  add_recipe(rec_rf) %>% 
  add_model(forest_model)

set.seed(2)
#Creating a gridsearch to tune
tune_tree1 <- seq(2, 16, by = 2)
tune_tree2 <- seq(3, 8, by = 2)
tune_tree3 <- seq(1, 10, by = 1)

grid_search <- expand_grid(
  trees = tune_tree1,
  tree_depth = tune_tree2,
  mtry = tune_tree3
  
)

rf_result_tune <- tune_grid(
  wflow_rf,
  resamples = folds,
  grid = grid_search,
  control = control_grid(verbose = FALSE, save_pred = TRUE)
)

#Find the best hyperparameter for ROC AUC
show_best(rf_result_tune, metric = "roc_auc")




