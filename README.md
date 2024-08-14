# Stats-202

This repo contains the different optimized models that were trialled for the final project. It contains a QMD file outlining the tuning steps, EDA and data-processing steps as well as visualizations to better understand the underlying distribution of the data. 

Also included are the various optimized models with the hyperparameters tuned based on cross-validation. In particular, I attempted to tune the Neural Network and Boosted Trees model.

The models I tried include:

1. KNN
2. Random Forest
3. Logistic Regression
4. SVMs
5. Boosted Trees
6. Neural Networks

There are 2 objectives I hoped to achieve by trying out all these models:

1. Identify the best 2 - 3 models to build an ensemble from to classify
2. Analyze the classification error of each model to identify if certain models work better under certain conditions. (E.g. does a model perform better because it has lower type 1 error - wrongly classifies 1 as 0s? If so this can be bundled with a model that has lower type 2 error - wrongly classifies 0s as 1s to improve predictions)



# Final Model
---
Testing out each model individually, the XGBoost Model and Neural Networks model performed the best on the Kaggle Test Set. I therefore decided to use them together in an ensemble model. 

**Ensemble Methods**
I devised 3 different ways that the 2 models could be "ensembled" together, drawing on different techniques

1) Majority Voting
- Classify the prediction based on a majority vote.
- E.g. amongst 5 predictors, if 3 predictors predict 1, the final classification will be 1. Given there are an odd number of models, there will never be a tie
3) Probability Voting (Max)
- 
4) Probability Voting (Additive)

**Selection**
---

**Pre-processing**
---

**Transformation**
---

**Data Mining**
---

**Interpretation/Evaluation**
---

**Future Work**
---
