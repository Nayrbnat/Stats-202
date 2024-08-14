## ----message=FALSE, warning=FALSE---------------------------------------------

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

## ----purl=TRUE----------------------------------------------------------------


set.seed(123)
rec_knn <- recipe(relevance ~., data = train_data) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(is_homepage) %>%
  step_zv(all_nominal_predictors())

# Model
model_knn <- nearest_neighbor(neighbors = tune()) %>% 
  set_engine("kknn") %>% 
  set_mode("classification")

# Workflow
wflow_knn <- 
  workflow() %>% 
  add_recipe(rec_knn) %>% 
  add_model(model_knn)

# Tuning the Model
tune_tree <- seq(500, 1000, by = 10) # Originally optimized for 1 to 30

grid_search <- expand_grid(
  neighbors = tune_tree
)

knn_result_tune <- tune_grid(
  wflow_knn ,
  resamples =folds,
  grid = grid_search,
  control = control_grid(verbose = TRUE, save_pred = TRUE)
)

#Find the best hyperparameter for ROC AUC
show_best(knn_result_tune, metric = "roc_auc")
