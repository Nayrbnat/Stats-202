## ----message=FALSE, warning=FALSE-------------------------------------------------------------------------------
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

# Fold validation
folds <- vfold_cv(train_data, v=5)


## ----purl=TRUE--------------------------------------------------------------------------------------------------

rec_svm <-  recipe(relevance ~., data = train_data) %>% 
    step_normalize(all_numeric_predictors()) %>%
    step_zv(all_nominal_predictors()) %>%
    step_nzv(all_nominal_predictors()) %>%
    step_dummy(is_homepage) %>% #is_homepage as a categorical variable
    step_interact(terms = ~ all_predictors() ^ 3)

# Model
svm_model_linear <- 
    svm_linear(mode = "classification", cost = tune()) %>% 
    set_engine("kernlab")
# Workflow
wflow_svm_linear <- 
  workflow() %>% 
  add_recipe(rec_svm) %>% 
  add_model(svm_model_linear)

#Creating a grid search
tune_svm1 <- seq(0, 1, by = 0.1)

grid_search <- expand_grid(
  cost = tune_svm1
)

#Tuning the hyperparameters
svm_result_tune <- tune_grid(
  wflow_svm_linear,
  resamples = folds,
  grid = grid_search,
  control = control_grid(verbose = FALSE, save_pred = TRUE)
)

#Find the best hyperparameter for ROC AUC
show_best(svm_result_tune, metric = "roc_auc")


