# Stats-202
---

**Kaggle Leaderboard name: Nayrbnat**

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

# Understanding the Data (EDA)

Given that the data comes from search queries and matching url_ids to see if they are relevant, I explored the data to see if there were any common url_ids that appeared. In particular I found that although there were 0 common query ids in the training and testing set, there were 1067 common URL ids that were present in both the training and testing data set. I proceeded then to find out in the training dataset 

On top of this initially analysis, i checked the data for:
1. Missingness (MCAR,MAR,NMAR)
3. Skewed distribution of features
4. Checking for multi-collinearity between features
5. Balance of the target variable in the training data set (56.3% non-relevant queries compared to relevant)

# Final Model
---
Testing out each model individually, the XGBoost Model and Neural Networks model performed the best on the Kaggle Test Set. I therefore decided to use them together in an ensemble model. 

**Selection**
---
I first dropped features that were clearly not relevant. For example, I removed the ID column from being a predictor as this was just a combination of the query and URL_ID columns. I removed the URL_ID column from being a predictor. (Reason?)

Other than the features above, I believe that all the other features would be relevant in making the prediction. I did not specifically pick out features to use in the models, rather I provided all features to the model and allowed the model to pick and choose which to utilize. I used Variance Importance Plots to visualize the relevance of different factors in each model, and found that certain features were very important/good signals. In particular: sig2 and sig7 were very important features for XGBoost.

**Pre-processing**
---

Looking at the different features, I decided to set is_homepage as a dummy variable. In my opinion, it was a categorical variable given that it only contained 2 binary outcomes - 1 if its in the hompage and 0 if not. Hence, I did not want to scale it with numerical transformations.
I pre-processed the numerical data by first looking at its underlying distribution. Data that was skewed I would then normalize based on standardization or the Yeo-Johnson scaling.
I tried the following data pre-processing steps throughout different models:
1. Step up/down sampling
2. Normalizing
3. Log() transformation (for features that showed to have a polynomial relationship)
4. Yeo-Johson

**Transformation**
---

**Data Mining**
---


<ins>Ensemble Methods</ins>
I devised 3 different ways that the 2 models could be "ensembled" together, drawing on different techniques

1) Majority Voting
- Classify the prediction based on a majority vote.
- E.g. amongst 5 predictors, if 3 predictors predict 1, the final classification will be 1. Given there are an odd number of models, there will never be a tie
2) Probability Voting (Max)
- Append the probabilities of the classifiers together
- For each row, the classification is based on the model which has the highest probability of a certain class
3) Probability Voting (Additive)
- Append the probabilities of the classifiers together
- For each row, sum up the combined probabilities of each class. The classification is based on which class has the highest combined probability

<ins>Evaluation of Ensemble Techniques</ins>

The #3 ensemble technique gave me the best results when I combined XGBoost and Neural Network models. The other ensembled models which included random forest, svm, etc did not give me good results, likely due to the inaccuracies of the base models. 


**Interpretation/Evaluation**
---

**Future Work/Reflection**
---

<ins>Reflection</ins>

There are some major takeaways that I got from this project. Initially, my models struggled because I did not think of expanding the feature space through interaction terms, basis splines, natural splines, etc. As a result, my models were training on ~80,000 datapoints with only 11 - 12 features. The second mistake I made was blindly following data pre-processing steps without consideration of the model. Whilst generally normalizing data helps improve machine learning models, for a boosted decision tree, it actually hampered the accuracy of the model. This stems from the fact that the decision trees split features based on a certain threshold and hence any monotonic transformation has no impact on the split of trees. This was reaffirmed by the developers of XGboost in their documentation. Contrast this to neural networks whereby normalization of the data was very important in achieving better accuracy. This is because for data that is not normalized that is fed into the activation function, the beta coefficient of one of the variables would buch larger, which would hamper weight initialization. This could lead to poorer convergence to a local extrema.

I also realized that less is sometimes more. In the case of data-preprocessing, there were some steps that when added would lead to poorer model performance. I believe this could be due to an increase in variance of the model which is trained on a dataset which has too many features/with too many transoformations that it no longer reflects the true distribution of the data.

My struggle in this project was mainly understanding the bias-variance trade-off in every step of the data-mining process. When adding a data pre-processing step, I was asking myself if this would lower bias or variance. In some cases, it was more obvious than others - increasing the regularizing term would clearly decrease variance and increase bias. But understanding the current performance of the model and what it lacked was harder. I tried to visualize the underlying distribution of the data and identify any underlying latent trends but I was unsure of how to apply that directly to the model. Several attempts at normalizing skewed features were made, with no significant improvement in performance.

<ins>Future Work</ins>

Due to time constraints, I was not able to implement all the ideas I had to improve the model. Although I improved the model through data-preprocessing and tuning hyper parameters, I believe that fundamentally there was an aspect of the data generating process that I needed to capture in order to better predict.
