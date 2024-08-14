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


## ----message=FALSE, warning=FALSE,purl=TRUE---------------------------------------------------------------------
# Fold validation
folds <- vfold_cv(train_data, v=5)


## ----purl=TRUE--------------------------------------------------------------------------------------------------
#Boosted Trees

rec_boost <- recipe(relevance~., data = train_data) %>% 
  step_naomit(all_predictors()) %>%
  update_role(id,url_id, new_role = "id") %>%
  step_dummy(is_homepage) %>%
  step_bs(sig2) %>%
  step_interact(terms = ~ all_predictors() ^ 3) 

# Model for XG Boost
boost_model <- boost_tree(
  mode = "classification",
  trees = tune(),
  mtry = tune(),
  tree_depth = tune(),
  learn_rate = tune(),
  min_n = tune()
) %>% set_engine("xgboost", verbose = 1,nthread=16,validation=0.2)

# Workflow
boost_tree_wf <- 
    workflow() %>% 
    add_recipe(rec_boost) %>% 
    add_model(boost_model)

#grid_search
tune1 = seq(100, 1000, by = 50)
tune2 = seq(15,50, by = 5)
tune3 = seq(4, 8, by = 2)
tune4 = seq(0.001,0.004, by = 0.001)
tune5 = seq(10,50, by = 10)

grid_search <- expand_grid(
  trees = tune1,
  mtry = tune2,
  tree_depth = tune3,
  learn_rate = tune4,
  min_n = tune5
)

#Tuning
boost_tree_tune <- tune_grid(
  boost_tree_wf,
  resamples = folds,
  grid = grid_search,
  control = control_grid(verbose = TRUE, save_pred = TRUE)
)


#Find the best hyperparameter for ROC AUC
print(show_best(boost_tree_tune, metric = "roc_auc"))




