## ----message=FALSE, warning=FALSE-------------------------------------------------------------------------------
# Tidyverse packages
library(readr)
library(tidyr)
library(dplyr)
library(lubridate)
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
library(purrr)
library(caret)
library(dials)
library(forcats)
library(tibble)


#Additional libaries
library(knitr)
library(kableExtra)
library(tune)
library(stringr)
library(vip)
library(corrplot)
library(themis)
library(progress)
library(xgboost)
library(baguette)
library(kknn)
library(brulee)


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

# Recipe
rec_dl <- recipe(relevance~., data = train_data) %>% 
  step_naomit(all_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  update_role(id,url_id, new_role = "id") %>%
  step_dummy(is_homepage) %>%
  step_bs(sig2) %>%
  step_YeoJohnson(all_numeric_predictors()) %>% 
  step_interact(terms = ~ all_predictors() ^ 2) 

# Model

mlp_mod <- mlp(hidden_units = tune(), penalty = tune(), learn_rate = tune()) %>%
    set_engine("brulee",rate_schedule = tune(),stop_iter = tune(),step_size = tune(),) %>%
    set_mode("classification")
# Gridsearch

grid_hidden_units <- tribble(
    ~hidden_units,
    c(10, 5),
    c(20, 10, 5),
    c(5,5),
    c(10,10),
    c(30, 20),
    c(15, 10, 5),
)

grid_rate_schedule <- tibble(rate_schedule=c("cyclic", "step"))
grid_step_size <- tibble(step_size= seq(5, 15, by = 5))
grid_stop_iter <- tibble(stop_iter= seq(5, 15, by = 5))
grid_penalty <- tibble(penalty= seq(0.0001, 0.001,by= 0.01))
grid_learn_rate <- tibble(learn_rate= seq(0.01, 0.05,by= 0.05))


grid <- grid_hidden_units %>%
    crossing(grid_rate_schedule,grid_step_size,grid_stop_iter,grid_penalty,grid_learn_rate)

mlp_workflow <- workflow() %>%
    add_recipe(rec_dl) %>%
    add_model(mlp_mod)

mlp_tune <- tune_grid(
        mlp_workflow,
        resamples = folds,
        grid = grid,
        control =control_grid(
    verbose = TRUE
)
    )

# Finding the best hyperparameter
print(show_best(mlp_tune, metric = "roc_auc"))




